import 'dart:developer';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportFunction {
  Future<void> sendReportEmail({
    required String toEmail,
    required String subject,
    required String body,
  }) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: toEmail,
      queryParameters: {
        'subject': Uri.encodeComponent(subject),
        'body': Uri.encodeComponent(body),
      },
    );
    try {
      if (Platform.isAndroid) {
        final AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          package: 'com.google.android.gm', // Package name for Gmail
          data: Uri.decodeComponent(emailLaunchUri.toString()),
        );
        await intent.launch();
      } else {
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      log('Error launching email client: $e');
    }
  }
}
