import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sboapp/Constants/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaRow extends StatelessWidget {
  const SocialMediaRow({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final socialLinks = [
      {
        'icon': FontAwesomeIcons.facebook,
        'color': Colors.blue,
        'url': 'https://facebook.com/sboapp2023'
      },
      {
        'icon': FontAwesomeIcons.tiktok,
        'color': Colors.black,
        'url': 'https://tiktok.com/@sboapp'
      },
      {
        'icon': FontAwesomeIcons.telegram,
        'color': Colors.blueAccent,
        'url': 'https://t.me/sboapp'
      },
      {
        'icon': FontAwesomeIcons.whatsapp,
        'color': Colors.green,
        'url': 'https://chat.whatsapp.com/IO1zysxDnuHCEg8IxnLkHM'
      },
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: titleText(text: "Follow us On"),
            ),
            ...socialLinks.map((link) => IconButton(
                  icon: FaIcon(link['icon'] as IconData,
                      color: link['color'] as Color),
                  onPressed: () => _launchURL(link['url'] as String),
                )),
          ],
        ),
      ),
    );
  }
}
