
import 'dart:async';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sboapp/auth/auth_check.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/constants/updating_app.dart';
import 'package:sboapp/services/get_database.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? appVersion;
  bool waiting = false;
  String? currentVersion;
  bool updating = false;
  String newVersion = "";
  StreamSubscription? _waitingStatusSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAppData();
  }



  Future<void> _initializeAppData() async {
    await _fetchAppVersion();
    await _checkForUpdates();
  }

  Future<void> _fetchAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    //setState(() {
      appVersion = packageInfo.version;
    //});
  }

  Future<void> _checkForUpdates() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final snapshot = await databaseReference.child('$dbName/updates').once();

    if (snapshot.snapshot.value is Map<dynamic, dynamic>) {
      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      //setState(() {
        updating = data['updating'] ?? false;
        newVersion = data['version'] ?? "";
      //});

      if (_isUpdateRequired()) {
        _listenForWaitingStatus();
      }
    }
  }

  bool _isUpdateRequired() {
    final current = int.parse(appVersion!.replaceAll('.', ''));
    final latest = int.parse(newVersion.replaceAll('.', ''));
    return updating && current < latest;
  }

  void _listenForWaitingStatus() {
    final databaseReference = FirebaseDatabase.instance.ref();
    _waitingStatusSubscription = databaseReference.child('$dbName/updates/waiting').onValue.listen((event) {
      //setState(() {
        waiting = bool.parse(event.snapshot.value.toString());
      //});
    });
  }



  @override
  Widget build(BuildContext context) {
    // Provider.of<GetDatabase>(context, listen: true).loadIsRead(); // Placeholder: Add appropriate logic or remove this line if unnecessary.

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
                  fontSize: 18,
                ),
                customText(
                  text: appVersion != null ? "Version: $appVersion" : "",
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:sboapp/auth/auth_check.dart';
// import 'package:sboapp/constants/text_style.dart';
// import 'package:sboapp/constants/updating_app.dart';
// import 'package:sboapp/services/get_database.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   String? appVersion;
//   bool waiting = false;
//   String? currentVersion;
//   bool updating = false;
//   String newVersion = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAppData();
//   }
//
//   Future<void> _initializeAppData() async {
//     await _fetchAppVersion();
//     await _checkForUpdates();
//   }
//
//   Future<void> _fetchAppVersion() async {
//     final packageInfo = await PackageInfo.fromPlatform();
//     setState(() {
//       appVersion = packageInfo.version;
//     });
//   }
//
//   Future<void> _checkForUpdates() async {
//     final databaseReference = FirebaseDatabase.instance.ref();
//     final snapshot = await databaseReference.child('$dbName/updates').once();
//
//     if (snapshot.snapshot.value is Map<dynamic, dynamic>) {
//       final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
//       setState(() {
//         updating = data['updating'] ?? false;
//         newVersion = data['version'] ?? "";
//       });
//
//       if (_isUpdateRequired()) {
//         _listenForWaitingStatus();
//       }
//     }
//   }
//
//   bool _isUpdateRequired() {
//     final current = int.parse(appVersion!.replaceAll('.', ''));
//     final latest = int.parse(newVersion.replaceAll('.', ''));
//     return updating && current < latest;
//   }
//
//   void _listenForWaitingStatus() {
//     final databaseReference = FirebaseDatabase.instance.ref();
//     databaseReference.child('$dbName/updates/waiting').onValue.listen((event) {
//       setState(() {
//         waiting = bool.parse(event.snapshot.value.toString());
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Provider.of<GetDatabase>(context, listen: true).loadIsRead(); // Placeholder: Add appropriate logic or remove this line if unnecessary.
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           Align(
//             alignment: Alignment.center,
//             child: FlutterSplashScreen.gif(
//               gifPath: 'assets/images/splash.gif',
//               gifWidth: 269,
//               gifHeight: 474,
//               backgroundColor: Theme.of(context).colorScheme.surface,
//               nextScreen: waiting ? const UpdatingApp() : const AuthCheck(),
//               duration: const Duration(milliseconds: 3000),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 customText(
//                   text: "``Read More Learn More``",
//                   color: Theme.of(context).colorScheme.primary,
//                   fontSize: 18,
//                 ),
//                 customText(
//                   text: appVersion != null ? "Version: $appVersion" : "",
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
