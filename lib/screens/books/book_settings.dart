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
    final role = ModalRoute.of(context)?.settings.arguments as List;
    final uploader = ModalRoute.of(context)?.settings.arguments as List;
    return ScaffoldWidget(
        appBar: AppBar(
          title: appBarText(text: providerLocale.appBarManage),
        ),
        body: Column(
          children: [
            Visibility(
              visible: role[0] == "Admin" || role[0] == "Agent",
              child: CardSettings(
                leading: const Icon(CupertinoIcons.book_fill),
                title: bodyText(text: providerLocale.bodyAddBook),
                onTap: () {
                  Navigator.pushNamed(context, "/addBook");
                },
              ),
            ),
            Visibility(
              visible: role[0] == "Owner" ||
                  role[0] == "Admin" ||
                  role[0] == "Agent",
              child: CardSettings(
                leading: const Icon(Icons.book_rounded),
                title: bodyText(text: providerLocale.bodyManage),
                onTap: () {
                  log(role[0]);
                  Navigator.pushNamed(
                      context,
                      role[0] == "Admin" || role[0] == "Owner"
                          ? "/manAllBooks"
                          : "/myBooks");
                },
              ),
            ),
            CardSettings(
              leading: const Icon(Icons.local_library),
              title: bodyText(text: providerLocale.bodyFavAnPaidBook),
              onTap: () {
                Navigator.pushNamed(context, "/favBook");
              },
            ),
            Visibility(
              visible:
                  uploader[1] == null || uploader[1] == false ? true : false,
              child: CardSettings(
                leading: const Icon(Icons.request_page),
                title: bodyText(text: providerLocale.bodyRequestUploadBook),
                onTap: () {
                  Navigator.pushNamed(context, "/reqUpBook");
                },
              ),
            ),
          ],
        ));
  }
}
