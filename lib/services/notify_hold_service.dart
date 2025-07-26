import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/get_database.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationProvider with ChangeNotifier {
  //sendNotification

  void updateToken(token) async {
    if (token != null) {
      DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
      final tokenExist = await databaseRef
          .child('$dbName/Users/${AuthServices().fireAuth.currentUser!.uid}')
          .once();
      if (tokenExist.snapshot.value != null) {
        final tokenId = tokenExist.snapshot.value as Map;
        if (tokenId['token'].toString() != token.toString()) {
          databaseRef
              .child(
              '$dbName/Users/${AuthServices().fireAuth.currentUser!.uid}')
              .update({
            'token': token.toString(),
          });
        }
      }
    }
  }

  void notifyAllUsers({
    required String title,
    required String body,
    String? bookLink,
    String? link,
    String? imgLink,
    mySelect,
  }) async {
    DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
    try {
      // Listen for changes in the database and add data to the stream
      databaseRef.child('$dbName/Users/').onChildAdded.listen((event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map;
          final token = data['token'];
          final role = data['role'];
          if (mySelect == null) {
            log(token);
            if (token != null) {
              sendNotificationToTokens(
                  token: token.toString(),
                  title: title,
                  body: body,
                  bookLink: bookLink,
                  link: link,
                  imgLink: imgLink);
            }
          } else if (role == mySelect) {
            log("$token $mySelect $role");
            if (token != null) {
              sendNotificationToTokens(
                  token: token.toString(),
                  title: title,
                  body: body,
                  bookLink: bookLink,
                  link: link,
                  imgLink: imgLink);
            }
          }
        }
      });
    } catch (e) {
      log("Token Update Error: $e");
    }
  }

  // The path to your service account JSON file
  final String serviceAccountJson = 'assets/json/service-account-file.json';

  Future<String> getAccessToken() async {
    // Read the service account JSON file
    final jsonCredentials = {
      "type": "service_account",
      "project_id": "sboapp-2a2be",
      "private_key_id": "7296d5d11b9bd3a62fa82575e56929a03c08529d",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDVRVdWyevXWPCM\nvFilgrVGzrAY5Vww0+boW7GeOmM+OGkkW01a57JcGdYbYnbfiHixZAwgaP0pTHSs\nq08MEO9vHnJfZ+NcwhLA8ZzKYH5w/rp1DsVfgELphqIAllPT9AZv9L+jfsY01R+4\nsjCcg5m4cASZouwAcw8MJ8UFpx5BZaWjwjkovX8dknF39CIlHd2gs8tL4Qahzn31\nBCN70vBxWYrYckAc4cuaHfkRnaqpSMRdHJLYi2NAswor+2lgqs7owNW+rtCYDfJ8\nRXSLzGjwUPlyGJ4+KCFOleEUPIVhby+27t45S3zVdGvzzrwGGDqhK1/K42UPiN0W\nqzjJr1vDAgMBAAECggEACuIkMak4QDl2FrIXeMrEyXClJLNMeXydNscgt0kvfogo\nBWzxwG1wEqpW3MR9+hMSzBEMKJM/zndSW1I0RHj3K9DkvhQLhdSswR/gHaVZW0oE\nf3jATCSIrALs1xU7NE1dqFTxeqLVJoxBt1rDurKUigiQk4gjsJouiGZD9AsYZinb\n5HgaYDHwwgaRP9eVo4T9rci9Z13Q5qPYGk1Ktr0xHVANWdFRxBjD8ycxkb4d08ZL\n++pR/gRx3kN4boHR6b8+OMWyl+QvZv4bFifNMQ3mZKX3u1CWDqJnkm/69f02Tckn\nIVuoh2u5nPTptQRdav12mprRy2WnxcBVCRams4/zgQKBgQDggFH1GqJzMg9pCv58\nlGSnXKewv6UAbuqQgxXfHIsBpd1kpoNEXGATSN8E4Faom3RKKTIrpDVvXAjM3sOY\ni6/n+dmtHuE83i+6QqAfylDlcELMohgrRIi9u32xjkZ+E5EuGqYuPli5O64LMiNF\neItn2YcBi+o05OYu9vZWSwy9owKBgQDzMaVS8YO4DxStu7zriRzQRys+VR6ztWup\nvJgPVr7lcsFrGKcXwFAdXTjWDbkQTMWVroyoJpXU0pbtY7QIaCKd0MAECUEXyODJ\nF1i2dGTOeSN8qKnY5uj6y56dmTzD3g9aq7dpebgsWufihb6BScE+D7NXL+uwEv12\n7sWWe8yLYQKBgHLtfgdqASvTvsvZkvoXxYdgCYCUO1YDchVU5gd3xzmqvbHfBGgk\nmhKFRZZrejGKk3e7qzFoOOqvRNoMWDlpmT26TFMx8cCFRg2mOe7MVal/VNMJUDIm\nPZJTvz78RN4aCkJ95gDabfU1th2JJ0FTOpqJY3HJPLajT6tPRkBa30TdAoGAY1DG\n/1R6QlSGUVz2Dgp0peoqks4YN7PDQBIw1zLJytJOgvoSYvS6wwMrDt+T0EBKAJLE\nBnebgMpvsIqjHzvHx0NU51EQMDJs+jJ6nCh0co2uHF6U3muOgb1eDWZjFmo9Qv4V\nbRG0UQje4fdUkWAZdsrapqR/T+yxbjycnJP6OIECgYEAvu0YuQjlzvpU8+eGkpAR\nzrj46IKodwD0+6b2o6krnxF2iKL9kjYp4g/+jBG/OhApFX1YXMDF+uZxBUymI4v5\nggkdD5KeRc1zk08qQ1809LjAwNl1bZatqUAggcpq17k8NKLN9aqNaxwQZQVOob9A\nW6LUIejUf07VKJMvQMZsOVM=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-wddm0@sboapp-2a2be.iam.gserviceaccount.com",
      "client_id": "100771000921901276916",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-wddm0%40sboapp-2a2be.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(jsonCredentials), scopes);

    //get access
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(jsonCredentials),
            scopes,
            client);

    client.close();

    // Return the access token
    return credentials.accessToken.data;
  }

  Future<void> sendNotificationToTokens({
    required String token,
    required String title,
    required String body,
    String? link,
    String? bookLink,
    String? imgLink,
  }) async {
    const String firebaseEndpoint =
        'https://fcm.googleapis.com/v1/projects/sboapp-2a2be/messages:send';

    // Replace this with your generated OAuth2 access token
    String accessToken = await getAccessToken();

    // Build the message payload
    final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'android': {
          'notification': {
            'image': imgLink,
          }
        },
        'data': {
          'imgLink': imgLink,
          'bookLink': bookLink,
          'link': link,
        }
      }
    };

    /*final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'android': {
          'notification': {
            'imageUrl': imgLink,
          }
        },
        'data': {
          'imgLink': imgLink,
          'bookLink': bookLink,
          'link': link,
        }
      },
    };*/

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final response = await http.post(
        Uri.parse(firebaseEndpoint),
        headers: headers,
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        log('Notification sent successfully');
      } else {
        log('Failed to send notification. Status: ${response.statusCode},');
      }
    } catch (e) {
      log('Error sending notification: $e');
      rethrow;
    }
  }

  //ended

/*List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  NotificationProvider() {
    loadNotifications();
  }

  Stream<List<NotificationModel>> loadNotifications() async* {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? notificationsJson = sp.getString('notifications');
    if (notificationsJson != null) {
      List<dynamic> decodedList = jsonDecode(notificationsJson);
      _notifications =
          decodedList.map((item) => NotificationModel.fromMap(item)).toList();
    }
    notifyListeners();
    yield _notifications;
  }

  Future<void> addNotification(NotificationModel notification) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    _notifications.add(notification);
    String encodedList =
        jsonEncode(_notifications.map((e) => e.toMap()).toList());
    sp.setString('notifications', encodedList);
    notifyListeners();
  }*/

  int secondsLeft = 60;
  late Timer _timer;

  //int get _secondsLeft => secondsLeft;
  String get message => "Undo in $secondsLeft seconds";

  setTopBanner({title, toGoLink, imgLink}) {
    if (secondsLeft == 0) {
      FirebaseDatabase.instance.ref("$dbName/TopBanner").push().set({
        'imgLink': imgLink,
        'title': title,
        'toGoLink': toGoLink,
        'uid': AuthServices().fireAuth.currentUser!.uid,
        'date': DateTime.timestamp().toString(),
      });
      secondsLeft = 60;
      notifyListeners();
    }
  }

  sendNotify(
      {required String title,
      required String body,
        String? link,
      String? imgLink,
        String? bookLink,
      mySelect}) {
    notifyAllUsers(
        title: title, body: body,link: link, imgLink: imgLink, bookLink: bookLink, mySelect: mySelect);
    if (secondsLeft > 1) {
      secondsLeft = 60;
    }
    notifyListeners();
  }

  messageProvider() {
    if (secondsLeft == 0) secondsLeft = 60;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft > 0) {
        secondsLeft -= 1;
        notifyListeners();
      } else {
        _timer.cancel();
        notifyListeners();
      }
    });
  }

  void stopTimer() {
    secondsLeft = 60;
    _timer.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
