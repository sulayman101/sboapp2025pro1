import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Services/get_database.dart';

class UpdatingApp extends StatefulWidget {
  const UpdatingApp({super.key});

  @override
  State<UpdatingApp> createState() => _UpdatingAppState();
}

class _UpdatingAppState extends State<UpdatingApp> {
  String? currentVersion;
  bool updating = false;
  String newVersion = "";


  Future<void> getDataFromFirebase(BuildContext context) async {
    // Fetch current app version
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;
    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    // Listen for updates
    databaseReference.child('$dbName/updates').once().then((snapshot) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        updating = data['updating'] ?? false;
        newVersion = data['version'] ?? "";
      });
      // Compare versions and show alert
      if (!updating && int.parse(currentVersion!.replaceAll('.', '').toString()) < int.parse(newVersion.replaceAll('.', '').toString())) {
        showUpdateAlert(context, newVersion);
      }
    });

  }

  // Show update alert
  void showUpdateAlert(BuildContext context, String? version) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Available"),
          content: Text("A new version $version is available. Please update the app."),
          actions: [
             TextButton(
              onPressed: () async{
                // Handle update action, e.g., redirect to App Store/Play Store
                final Uri url = Uri.parse(
                    "https://play.google.com/store/apps/details?id=com.dsd.sboapp&pli=1");
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
                Navigator.of(context).pop();
              },
              child: const Text("Update Now"),
            ),
          ],
        );
      },
    );
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromFirebase(context);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/updatingApp.png",
            scale: 2,
          ),
          customText(
            textAlign: TextAlign.center,
              text:
                  "We are updating the app; we will be back soon. \n .نقوم بتحديث التطبيق، سنعود قريباً",
              fontSize: 20,
              fontWeight: FontWeight.bold),

          updating  ? ElevatedButton(onPressed: (){
            log("${int.parse(currentVersion!.replaceAll('.', '').toString()) < int.parse(newVersion.replaceAll('.', '').toString())}");
            log("current Version:${currentVersion!.replaceAll('.', '')}  new Version:${newVersion.replaceAll('.', '')}");
            } , child: const Text("Update Now")) : const SizedBox(),
        ],
      ),
    ));
  }
}
