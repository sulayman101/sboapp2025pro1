import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/settings_card.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';

class NotifySettings extends StatelessWidget {
  const NotifySettings({super.key});

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return ScaffoldWidget(
        appBar: AppBar(
          title: Text(providerLocale.appBarNotification),
        ),
        body: Column(
          children: [
            CardSettings(
              leading: const Icon(Icons.notification_add),
              title: Text(providerLocale.bodyAddNotify),
              onTap: () {
                Navigator.pushNamed(context, "/addNotify");
              },
            ),
            CardSettings(
              leading: const Icon(Icons.edit_notifications),
              title: Text(providerLocale.bodyManageNotify),
              onTap: () {
                Navigator.pushNamed(context, "/manNotify");
              },
            ),
          ],
        ));
  }
}
