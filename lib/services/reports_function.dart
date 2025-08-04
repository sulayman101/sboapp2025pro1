import 'dart:developer';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportFunction {
  /// Sends a report email using the default email client.
  Future<void> sendReportEmail({
    required String toEmail,
    required String subject,
    required String body,
  }) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: toEmail,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      if (Platform.isAndroid) {
        await _launchGmailApp(emailLaunchUri);
      } else {
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      log('Error launching email client: $e');
    }
  }

  /// Launches the Gmail app on Android devices.
  Future<void> _launchGmailApp(Uri emailUri) async {
    final intent = AndroidIntent(
      action: 'action_view',
      package: 'com.google.android.gm',
      data: emailUri.toString(),
    );

    try {
      await intent.launch();
    } catch (e) {
      log('Error launching Gmail app: $e');
    }
  }
}
