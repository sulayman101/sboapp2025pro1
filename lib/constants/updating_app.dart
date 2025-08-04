import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/get_database.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatingApp extends StatefulWidget {
  const UpdatingApp({super.key});

  @override
  State<UpdatingApp> createState() => _UpdatingAppState();
}

class _UpdatingAppState extends State<UpdatingApp> {
  String? currentVersion;
  bool updating = false;
  String newVersion = "";

  @override
  void initState() {
    super.initState();
    _fetchAppData();
  }

  Future<void> _fetchAppData() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      currentVersion = packageInfo.version;

      final databaseReference = FirebaseDatabase.instance.ref();
      final snapshot = await databaseReference.child('$dbName/updates').once();

      if (snapshot.snapshot.value is Map<dynamic, dynamic>) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        setState(() {
          updating = data['updating'] ?? false;
          newVersion = data['version'] ?? "";
        });

        if (!_isVersionUpToDate()) {
          _showUpdateAlert();
        }
      }
    } catch (e) {
      log("Error fetching app data: $e");
    }
  }

  bool _isVersionUpToDate() {
    final current = int.parse(currentVersion!.replaceAll('.', ''));
    final latest = int.parse(newVersion.replaceAll('.', ''));
    return current >= latest;
  }

  void _showUpdateAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Available"),
        content: Text(
            "A new version $newVersion is available. Please update the app."),
        actions: [
          TextButton(
            onPressed: () async {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/updatingApp.png",
              scale: 2,
            ),
            customText(
              textAlign: TextAlign.center,
              text:
                  "We are updating the app; we will be back soon.\n.نقوم بتحديث التطبيق، سنعود قريباً",
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            if (updating)
              ElevatedButton(
                onPressed: () {
                  log("Current Version: $currentVersion, New Version: $newVersion");
                },
                child: const Text("Update Now"),
              ),
          ],
        ),
      ),
    );
  }
}
