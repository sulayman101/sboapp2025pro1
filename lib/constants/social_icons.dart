

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sboapp/Constants/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaRow extends StatelessWidget {
  const SocialMediaRow({super.key});

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:8.0),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: titleText(text: "Follow us On"),
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
              onPressed: () => _launchURL('https://facebook.com/sboapp2023'),
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.tiktok, color: Colors.black),
              onPressed: () => _launchURL('https://tiktok.com/@sboapp'),
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.telegram, color: Colors.blueAccent),
              onPressed: () => _launchURL('https://t.me/sboapp'),
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
              onPressed: () => _launchURL('https://chat.whatsapp.com/IO1zysxDnuHCEg8IxnLkHM'),
            ),
          ],
        ),
      ),
    );
  }
}
