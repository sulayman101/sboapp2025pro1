import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_model/notification_model.dart';
import '../routes_page.dart';
import '../screens/presentation/pdf_reader_page.dart';
import 'notify_db_helper.dart';
import 'notify_hold_service.dart';
import 'auth_services.dart';

Future<void> handleBackgroundMessaging(RemoteMessage? message) async {
  if (message == null) return;
  log(message.toMap().toString());

  final messageId = message.messageId;
  if (messageId == null) return;

  final notification = NotificationModel(
    id: messageId,
    title: message.notification?.title ?? "No Title",
    subtitle: message.notification?.body ?? "No Body",
    link: message.data['link'],
    bookLink: message.data['bookLink'],
    imgUrl: message.data['imgLink'],
    date: DateTime.now().toString(),
    isRead: false,
    uid: AuthServices().fireAuth.currentUser?.uid ?? "Unknown",
  );

  await ManageNotifyProvider().addNotification(notification);
  final sp = await SharedPreferences.getInstance();
  sp.setBool('read', false);
}

class FireNotifyApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'Notification',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  Future<void> initNotification() async {
    await _requestPermissions();
    await _initializePushNotifications();
    await _initializeLocalNotifications();
  }

  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await _firebaseMessaging.getToken();
      NotificationProvider().updateToken(token);
    }
  }

  Future<void> _initializePushNotifications() async {
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessaging);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
        _handleMessageOpenedApp(message);
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_channel);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    log("Foreground message received: ${message.toMap()}");
    _saveNotification(message);

    final notification = message.notification;
    if (notification != null) {
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
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    log("Message opened app: ${message.toMap()}");

    final bookLink = message.data['bookLink'];
    final title = message.notification?.title;

    if (bookLink != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => ReadingPage(
            bookLink: bookLink,
            title: title ?? "No Title",
          ),
        ),
      );
    } else {
      navigatorKey.currentState?.pushNamed('/notifyList');
    }
  }

  void _saveNotification(RemoteMessage message) async {
    final notification = NotificationModel(
      id: message.messageId ?? "Unknown",
      title: message.notification?.title ?? "No Title",
      subtitle: message.notification?.body ?? "No Body",
      link: message.data['link'],
      bookLink: message.data['bookLink'],
      imgUrl: message.data['imgLink'],
      date: DateTime.now().toString(),
      isRead: false,
      uid: AuthServices().fireAuth.currentUser?.uid ?? "Unknown",
    );

    await ManageNotifyProvider().addNotification(notification);
    final sp = await SharedPreferences.getInstance();
    sp.setBool('read', false);
  }
}
