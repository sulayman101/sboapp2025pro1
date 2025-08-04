import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/settings_card.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';

class BookSettings extends StatelessWidget {
  const BookSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    final arguments = ModalRoute.of(context)?.settings.arguments as List;
    final role = arguments[0];
    final uploader = arguments[1];

    return ScaffoldWidget(
      appBar: AppBar(
        title: appBarText(text: providerLocale.appBarManage),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          if (role == "Admin" || role == "Agent")
            _buildCard(
              icon: CupertinoIcons.book_fill,
              text: providerLocale.bodyAddBook,
              onTap: () => Navigator.pushNamed(context, "/addBook"),
            ),
          if (role == "Owner" || role == "Admin" || role == "Agent")
            _buildCard(
              icon: Icons.book_rounded,
              text: providerLocale.bodyManage,
              onTap: () {
                log(role);
                Navigator.pushNamed(
                  context,
                  role == "Admin" || role == "Owner"
                      ? "/manAllBooks"
                      : "/myBooks",
                );
              },
            ),
          _buildCard(
            icon: Icons.local_library,
            text: providerLocale.bodyFavAnPaidBook,
            onTap: () => Navigator.pushNamed(context, "/favBook"),
          ),
          if (uploader == null || uploader == false)
            _buildCard(
              icon: Icons.request_page,
              text: providerLocale.bodyRequestUploadBook,
              onTap: () => Navigator.pushNamed(context, "/reqUpBook"),
            ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return CardSettings(
      leading: Icon(icon),
      title: bodyText(text: text),
      onTap: onTap,
    );
  }
}
