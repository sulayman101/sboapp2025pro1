import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/get_database.dart';

class NotificationProvider with ChangeNotifier {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final String _firebaseEndpoint =
      'https://fcm.googleapis.com/v1/projects/sboapp-2a2be/messages:send';
  final String _serviceAccountJson = 'assets/json/service-account-file.json';

  int _secondsLeft = 60;
  late Timer _timer;

  String get message => "Undo in $_secondsLeft seconds";

  // Update user token in the database
  void updateToken(String? token) async {
    if (token == null) return;

    final userRef = _databaseRef
        .child('$dbName/Users/${AuthServices().fireAuth.currentUser!.uid}');
    final tokenSnapshot = await userRef.once();

    if (tokenSnapshot.snapshot.value != null) {
      final tokenData = tokenSnapshot.snapshot.value as Map;
      if (tokenData['token'] != token) {
        userRef.update({'token': token});
      }
    }
  }

  // Notify all users or specific roles
  void notifyAllUsers({
    required String title,
    required String body,
    String? bookLink,
    String? link,
    String? imgLink,
    String? roleFilter,
  }) async {
    try {
      _databaseRef.child('$dbName/Users/').onChildAdded.listen((event) {
        if (event.snapshot.value != null) {
          final userData = event.snapshot.value as Map;
          final token = userData['token'];
          final role = userData['role'];

          if (token != null && (roleFilter == null || role == roleFilter)) {
            sendNotificationToToken(
              token: token,
              title: title,
              body: body,
              bookLink: bookLink,
              link: link,
              imgLink: imgLink,
            );
          }
        }
      });
    } catch (e) {
      log("Error notifying users: $e");
    }
  }

  // Get OAuth2 access token
  Future<String> getAccessToken() async {
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

    final scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
      "https://www.googleapis.com/auth/firebase.database",
    ];

    final client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(jsonCredentials),
      scopes,
    );

    final credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(jsonCredentials),
      scopes,
      client,
    );

    client.close();
    return credentials.accessToken.data;
  }

  // Send notification to a specific token
  Future<void> sendNotificationToToken({
    required String token,
    required String title,
    required String body,
    String? link,
    String? bookLink,
    String? imgLink,
  }) async {
    final accessToken = await getAccessToken();

    final message = {
      'message': {
        'token': token,
        'notification': {'title': title, 'body': body},
        'android': {
          'notification': {'image': imgLink}
        },
        'data': {'imgLink': imgLink, 'bookLink': bookLink, 'link': link},
      },
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final response = await http.post(
        Uri.parse(_firebaseEndpoint),
        headers: headers,
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        log('Notification sent successfully');
      } else {
        log('Failed to send notification. Status: ${response.statusCode}');
      }
    } catch (e) {
      log('Error sending notification: $e');
    }
  }

  // Start a timer for undo functionality
  void startTimer() {
    _secondsLeft = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        _secondsLeft--;
        notifyListeners();
      } else {
        _timer.cancel();
        notifyListeners();
      }
    });
  }

  void stopTimer() {
    _secondsLeft = 60;
    _timer.cancel();
    notifyListeners();
  }

  void sendNotify({
    required String title,
    required String body,
    String? link,
    String? imgLink,
    String? bookLink,
    String? roleFilter,
    String? mySelect,
  }) {
    notifyAllUsers(
      title: title,
      body: body,
      link: link,
      imgLink: imgLink,
      bookLink: bookLink,
      roleFilter: roleFilter,
    );
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
