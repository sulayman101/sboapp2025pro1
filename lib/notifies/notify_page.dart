import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/text_form_field.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/services/notify_hold_service.dart';

import '../Services/get_database.dart';

class AddNotify extends StatefulWidget {
  const AddNotify({super.key});

  @override
  State<AddNotify> createState() => _AddNotifyState();
}

class _AddNotifyState extends State<AddNotify> {
  final _titleTxt = TextEditingController();
  final _msgTxt = TextEditingController();
  final _imgLinkTxt = TextEditingController();
  final _linkTxt = TextEditingController();
  final _bookLinkTxt = TextEditingController();
  bool _wait = false;

  int chipSelected = 0;
  String? selected;

  bool updating = false;
  String newVersion = "";
  bool waiting = false;
  String currentVersion = "";

  @override
  void initState() {
    super.initState();
    _getUpdateStatus();
  }

  Future<void> _getUpdateStatus() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final databaseReference = FirebaseDatabase.instance.ref();

      final snapshot = await databaseReference.child('$dbName/updates').once();
      if (snapshot.snapshot.value is Map<dynamic, dynamic>) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        setState(() {
          updating = data['updating'] ?? false;
          newVersion = data['version'] ?? "";
          waiting = data['waiting'] ?? false;
          currentVersion = packageInfo.version;
        });
      }
    } catch (e) {
      log("Error fetching update status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;

    final labelsList = [
      providerLocale.bodyAll,
      providerLocale.bodyAllUsers,
      providerLocale.bodyAllAuthors,
      providerLocale.bodyAllAdmins,
    ];

    return ScaffoldWidget(
      appBar: AppBar(
        title: appBarText(text: providerLocale.appBarUpdateNotify),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildNotificationForm(providerLocale, labelsList, provider),
            _buildUpdateSettings(providerLocale),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationForm(dynamic providerLocale, List<String> labelsList,
      NotificationProvider provider) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            titleText(text: providerLocale.bodyNotify, fontSize: 18),
            MyTextFromField(
              labelText: providerLocale.bodyLblTitle,
              hintText: providerLocale.bodyHintTitle,
              textEditingController: _titleTxt,
              isReadOnly: _wait,
            ),
            MyTextFromField(
              labelText: providerLocale.bodyLblMsg,
              hintText: providerLocale.bodyHintMsg,
              textEditingController: _msgTxt,
              isReadOnly: _wait,
              maxLines: 5,
            ),
            MyTextFromField(
              labelText: "Link",
              hintText: "Enter Link",
              textEditingController: _linkTxt,
              validator: (value) => _validateUrl(value, providerLocale),
            ),
            MyTextFromField(
              labelText: providerLocale.bodyLblImgLink,
              hintText: providerLocale.bodyHintImgLink,
              textEditingController: _imgLinkTxt,
              validator: (value) => _validateUrl(value, providerLocale),
            ),
            MyTextFromField(
              labelText: "Book Link",
              hintText: "Enter Book Link",
              textEditingController: _bookLinkTxt,
              validator: (value) => _validateUrl(value, providerLocale),
            ),
            _buildChoiceChips(labelsList),
            _buildSendButton(provider, providerLocale),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChips(List<String> labelsList) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        labelsList.length,
        (index) => ChoiceChip(
          label: labelText(text: labelsList[index]),
          selected: chipSelected == index,
          onSelected: _wait
              ? null
              : (value) {
                  setState(() {
                    chipSelected = index;
                    selected = index == 0
                        ? null
                        : index == 1
                            ? "User"
                            : index == 2
                                ? "Agent"
                                : "Admin";
                  });
                },
        ),
      ),
    );
  }

  Widget _buildSendButton(
      NotificationProvider provider, dynamic providerLocale) {
    return _wait
        ? FilledButton(
            child: bodyText(text: provider.message),
            onPressed: () {
              setState(() {
                provider.stopTimer();
                _wait = false;
              });
            },
          )
        : FilledButton(
            child: bodyText(text: providerLocale.bodySend),
            onPressed: () => _sendNotification(provider),
          );
  }

  Future<void> _sendNotification(NotificationProvider provider) async {
    if (_titleTxt.text.isNotEmpty && _msgTxt.text.isNotEmpty) {
      setState(() => _wait = true);
      provider.showMessage();

      await Future.delayed(const Duration(minutes: 1));
      setState(() => _wait = false);

      provider.sendNotify(
        title: _titleTxt.value.text,
        body: _msgTxt.value.text,
        link: _linkTxt.text.isEmpty ? null : _linkTxt.value.text,
        imgLink: _imgLinkTxt.text.isEmpty ? null : _imgLinkTxt.value.text,
        bookLink: _bookLinkTxt.text.isEmpty ? null : _bookLinkTxt.value.text,
        mySelect: selected,
      );

      _clearFormFields();
    }
  }

  void _clearFormFields() {
    _titleTxt.clear();
    _msgTxt.clear();
    _imgLinkTxt.clear();
    _linkTxt.clear();
    _bookLinkTxt.clear();
    chipSelected = 0;
  }

  String? _validateUrl(String? value, dynamic providerLocale) {
    if (value == null || !Uri.parse(value).isAbsolute) {
      return providerLocale.bodyEnterValidUrl;
    }
    return null;
  }

  Widget _buildUpdateSettings(dynamic providerLocale) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ExpansionTile(
          title: const Text("Update All"),
          trailing: Switch(
            value: waiting && updating,
            onChanged: (value) => _toggleUpdateSettings(),
          ),
          children: [
            _buildUpdateRow(
              "Update New Version: $newVersion",
              Icons.update,
              () => Provider.of<GetDatabase>(context, listen: false)
                  .updateAppVersions(newVersion: currentVersion),
            ),
            _buildUpdateRow(
              "Updating Status: $updating",
              Icons.change_circle,
              () => Provider.of<GetDatabase>(context, listen: false)
                  .updateAppVersions(updating: !updating),
              iconColor: updating ? Colors.blue : null,
            ),
            _buildUpdateRow(
              "Waiting Status: $waiting",
              Icons.access_time,
              () => Provider.of<GetDatabase>(context, listen: false)
                  .updateAppVersions(waiting: !waiting),
              iconColor: waiting ? Colors.blue : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateRow(String text, IconData icon, VoidCallback onPressed,
      {Color? iconColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text),
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: iconColor),
        ),
      ],
    );
  }

  void _toggleUpdateSettings() {
    Provider.of<GetDatabase>(context, listen: false).updateAppVersions(
      newVersion: currentVersion,
      updating: !updating,
      waiting: !waiting,
    );
    Future.delayed(const Duration(seconds: 30))
        .whenComplete(() => _getUpdateStatus());
  }
}

class TempLocalNotifications {
  final String title;
  final String body;
  final String who;
  final bool linkImg;

  TempLocalNotifications(
      {required this.title,
      required this.body,
      required this.who,
      required this.linkImg});
}

class NotificationProvider with ChangeNotifier {
  String message = "Notification in progress...";

  void showMessage() {
    message = "Notification is being sent...";
    notifyListeners();
  }

  void sendNotify({
    required String title,
    required String body,
    String? link,
    String? imgLink,
    String? bookLink,
    String? mySelect,
  }) {
    // Logic to send notification
    log("Notification sent: $title - $body");
  }

  void stopTimer() {
    message = "Notification stopped.";
    notifyListeners();
  }
}
