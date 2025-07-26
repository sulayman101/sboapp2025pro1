
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sboapp/Services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_model/notification_model.dart';
import '../routes_page.dart';
import '../screens/presentation/pdf_reader_page.dart';
import 'notify_db_helper.dart';
import 'notify_hold_service.dart';




Future<void> handleBackgroundMessaging(RemoteMessage? message) async {
  if (message == null) return;
  log(message.toMap().toString());
  String? lastProcessedMessageId;
  final messageId = message.messageId;
  if (messageId == null) return;
  lastProcessedMessageId = messageId;
  final link = message.data['link'];
  final bookLink = message.data['bookLink'];
  final imgLink = message.data['imgLink'];
  final title = message.notification!.title;
  final body = message.notification!.body;
  final date = DateTime.now();

  NotificationModel sqlNotifyModel = NotificationModel(
      id: messageId,
      title: title.toString(),
      subtitle: body.toString(),
      link: link,
      bookLink: bookLink,
      imgUrl: imgLink,
      date: date.toString(),
      isRead: false,
    uid: AuthServices().fireAuth.currentUser!.uid,
  );
  await ManageNotifyProvider().addNotification(sqlNotifyModel);
  SharedPreferences sp = await SharedPreferences.getInstance();
  sp.setBool('read', false);
}

class FireNotifyApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  void holdNotify(RemoteMessage? message) async {
    if (message == null) return;
    String? lastProcessedMessageId;
    final messageId = message.messageId;
    if (messageId == null || messageId == lastProcessedMessageId) {
      //print('Duplicate message detected, skipping...');
      return;
    }
    log(message.toMap().toString());

    lastProcessedMessageId = messageId;
    final link = message.data['link'];
    final bookLink = message.data['bookLink'];
    final imgLink = message.data['imgLink'];
    final title = message.notification!.title;
    final body = message.notification!.body;
    final date = DateTime.now();
    NotificationModel sqlNotifyModel = NotificationModel(
        id: messageId,
        title: title.toString(),
        subtitle: body.toString(),
        link: link,
        bookLink: bookLink,
        imgUrl: imgLink,
        date: date.toString(),
        isRead: false,
      uid: AuthServices().fireAuth.currentUser!.uid,
    );
    ManageNotifyProvider().addNotification(sqlNotifyModel);
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('read', false);
  }

  void handelMessage(RemoteMessage message) async{// Create the notifications table
    final messageId = message.messageId;
    final link = message.data['link'];
    final bookLink = message.data['bookLink'];
    final title = message.notification!.title;
    final imgLink = message.data['imgLink'];
    final body = message.notification!.body;
    final date = DateTime.now();
    NotificationModel sqlNotifyModel = NotificationModel(
        id: messageId.toString(),
        title: title.toString(),
        subtitle: body.toString(),
        link: link,
        bookLink: bookLink,
        imgUrl: imgLink,
        date: date.toString(),
        isRead: true,
      uid: AuthServices().fireAuth.currentUser!.uid,
    );
    ManageNotifyProvider().addNotification(sqlNotifyModel);
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('read', true);

    if (bookLink != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) =>
              ReadingPage(
                bookLink: link.toString(),
                title: title.toString(),
              ),
        ),
      );
    } else {
      navigatorKey.currentState?.pushNamed('/notifyList');
    }
  }

  final _channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'Notification', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessaging);
    FirebaseMessaging.onMessageOpenedApp.listen(handelMessage);
    FirebaseMessaging.onMessage.listen((message) {
      log("On main");
      holdNotify(message);
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(

            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: '@mipmap/ic_launcher',
              // other properties...
            ),
          ),
          payload: jsonEncode(message.toMap()));
    });
  }

  Future initLocalNotify() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        log("Payload Data $response");
        final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
        handelMessage(message);

      },
    );
    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_channel);
  }

//==============Main Function======================//
  Future<void> initNotification() async {
    final requestPermission = await _firebaseMessaging.requestPermission();
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      //log('User granted permission');
      final token = await _firebaseMessaging.getToken();
      //log(token.toString());
      NotificationProvider().updateToken(token);
    } else {
      if (settings.authorizationStatus == AuthorizationStatus.denied ||
          settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        requestPermission;
      }
    }

    initPushNotification();
    initLocalNotify();
  }

//============ end Main Function =====================//

}