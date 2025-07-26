import 'dart:developer';

import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/constants/updating_app.dart';
import 'package:sboapp/services/get_database.dart';
import 'package:sboapp/routes_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? appVersion;
  bool waiting = false;


  void getDeviceAndVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
  }

  checkUpdating(){
    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    databaseReference
        .child('$dbName/updates/waiting')
        .onValue
        .listen((onData) {
      setState(() => waiting = bool.parse(onData.snapshot.value.toString()));
    });
  }

  String? currentVersion;
  bool updating = false;
  String newVersion = "";
  bool isUpdated = true;


  Future<void> getCheckUpdating() async {
    // Fetch current app version
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;
    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    // Listen for updates
    databaseReference.child('$dbName/updates').once().then((snapshot) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      //setState(() {
        updating = data['updating'] ?? false;
        newVersion = data['version'] ?? "";
      //});
      log("updating: $updating version:${int.parse(currentVersion!.replaceAll('.', '').toString()) < int.parse(newVersion.replaceAll('.', '').toString())}");
      // Compare versions and show alert
      if (updating) {
        log("updating");
          log("updating: $updating version:${int.parse(newVersion.replaceAll('.', '').toString()) < int.parse(currentVersion!.replaceAll('.', '').toString())}");
          if(int.parse(currentVersion!.replaceAll('.', '').toString()) < int.parse(newVersion.replaceAll('.', '').toString())) {
            checkUpdating();
          }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceAndVersion();
    getCheckUpdating();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    getDeviceAndVersion();
    getCheckUpdating();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<GetDatabase>(context, listen: true).loadIsRead();
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: FlutterSplashScreen.gif(
              gifPath: 'assets/images/splash.gif',
              gifWidth: 269,
              gifHeight: 474,
              backgroundColor: Theme.of(context).colorScheme.surface,
              nextScreen: waiting ? const UpdatingApp() : const AuthCheck(),
              duration: const Duration(milliseconds: 3000),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                customText(
                    text: "``Read More Learn More``",
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18),
                customText(
                    text: appVersion != null ? "Version: $appVersion" : "",
                    color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
