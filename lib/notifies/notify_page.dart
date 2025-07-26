import 'dart:developer';
import 'dart:math';

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

  void _getUpdateStatus() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

    // Listen for updates
    databaseReference.child('$dbName/updates').once().then((snapshot) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        updating = data['updating'] ?? false;
        newVersion = data['version'] ?? "";
        waiting = data['waiting'] ?? false;
        currentVersion = packageInfo.version;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUpdateStatus();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    List labelsList = [
      providerLocale.bodyAll,
      providerLocale.bodyAllUsers,
      providerLocale.bodyAllAuthors,
      providerLocale.bodyAllAdmins
    ];


    List<TempLocalNotifications> tempNotifies = [];
    
    return ScaffoldWidget(
      appBar: AppBar(
        title: appBarText(text: providerLocale.appBarUpdateNotify),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card.filled(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    titleText(text: providerLocale.bodyNotify, fontSize: 18),
                    MyTextFromField(
                        labelText: providerLocale.bodyLblTitle,
                        hintText: providerLocale.bodyHintTitle,
                        textEditingController: _titleTxt,
                        isReadOnly: _wait),
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
                      validator: (value) {
                        bool validURL = Uri.parse(value).isAbsolute;
                        if (!validURL) {
                          return providerLocale.bodyEnterValidUrl;
                        }
                      },
                    ),
                    MyTextFromField(
                      labelText: providerLocale.bodyLblImgLink,
                      hintText: providerLocale.bodyHintImgLink,
                      textEditingController: _imgLinkTxt,
                      validator: (value) {
                        bool validURL = Uri.parse(value).isAbsolute;
                        if (!validURL) {
                          return providerLocale.bodyEnterValidUrl;
                        }
                      },
                    ),
                    MyTextFromField(
                      labelText: "Book Link",
                      hintText: "Enter Book Link",
                      textEditingController: _bookLinkTxt,
                      validator: (value) {
                        bool validURL = Uri.parse(value).isAbsolute;
                        if (!validURL) {
                          return providerLocale.bodyEnterValidUrl;
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ChoiceChip(
                            label: labelText(text: labelsList[0]),
                            selected: chipSelected == 0,
                            onSelected: _wait
                                ? null
                                : (value) {
                                    setState(() {
                                      chipSelected = 0;
                                      selected = null;
                                    });
                                  }),
                        ChoiceChip(
                            label: labelText(text: labelsList[1]),
                            selected: chipSelected == 1,
                            onSelected: _wait
                                ? null
                                : (value) {
                                    setState(() {
                                      chipSelected = 1;
                                      selected = "User";
                                    });
                                  }),
                        ChoiceChip(
                            label: labelText(text: labelsList[2]),
                            selected: chipSelected == 2,
                            onSelected: _wait
                                ? null
                                : (value) {
                                    setState(() {
                                      chipSelected = 2;
                                      selected = "Agent";
                                    });
                                  }),
                        ChoiceChip(
                            label: labelText(text: labelsList[3]),
                            selected: chipSelected == 3,
                            onSelected: _wait
                                ? null
                                : (value) {
                                    setState(() {
                                      chipSelected = 3;
                                      selected = "Admin";
                                    });
                                  }),
                      ],
                    ),
                    _wait
                        ? FilledButton(
                            child: bodyText(
                              text: provider.message,
                            ),
                            onPressed: () {
                              setState(() {
                                Provider.of<NotificationProvider>(context,
                                        listen: false)
                                    .stopTimer();
                                _wait = false;
                              });
                            },
                          )
                        : FilledButton(
                            child: bodyText(
                              text: providerLocale.bodySend,
                            ),
                            onPressed: () async {
                              final fcmProvider =
                                  Provider.of<NotificationProvider>(context,
                                      listen: false);
                              if (_titleTxt.text.isNotEmpty &&
                                  _msgTxt.text.isNotEmpty) {
                                setState(() => _wait = true);
                                Provider.of<NotificationProvider>(context,
                                        listen: false)
                                    .messageProvider();
                                await Future.delayed(const Duration(minutes: 1));
                                setState(() {
                                  _wait = false;
                                  tempNotifies.add(TempLocalNotifications(
                                      title: _titleTxt.text,
                                      body: _msgTxt.text,
                                      who: chipSelected == 3
                                          ? "Admins"
                                          : chipSelected == 2
                                              ? "Athors"
                                              : chipSelected == 1
                                                  ? "Users"
                                                  : "All",
                                      linkImg: _imgLinkTxt.text.isEmpty
                                          ? false
                                          : true,
                                  ));
                                });
                                fcmProvider.sendNotify(
                                    title: _titleTxt.value.text,
                                    body: _msgTxt.value.text,
                                    link: _linkTxt.text.isEmpty ? null : _linkTxt.value.text,
                                    imgLink: _imgLinkTxt.text.isEmpty
                                        ? null
                                        : _imgLinkTxt.value.text,
                                    bookLink: _bookLinkTxt.text.isEmpty ? null : _bookLinkTxt.value.text,
                                    mySelect: selected);

                                _titleTxt.clear();
                                _msgTxt.clear();
                                _imgLinkTxt.clear();
                                _linkTxt.clear();
                                _bookLinkTxt.clear();
                                chipSelected = 0;
                              }
                            },
                          ),
                  ],
                ),
              ),
            ),
            Card.filled(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: const Text("Update All"),
                  trailing: Switch(value: waiting && updating ? true : false, onChanged: (value){
                      Provider.of<GetDatabase>(context, listen: false).updateAppVersions(newVersion: currentVersion, updating: !updating, waiting: !waiting);
                      Future.delayed(const Duration(seconds: 30)).whenComplete(()=> _getUpdateStatus());
                  }),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Update New Version : $newVersion"),
                        IconButton(onPressed: (){
                          Provider.of<GetDatabase>(context, listen: false).updateAppVersions(newVersion: currentVersion);
                        }, icon: const Icon(Icons.update)),
                      ],),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Updating Status : $updating"),
                        IconButton(onPressed: (){
                          Provider.of<GetDatabase>(context, listen: false).updateAppVersions(updating: !updating);
                        }, icon: Icon(Icons.change_circle, color: updating ? Colors.blue :  null)),
                      ],),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Waiting Status : $waiting"),
                        IconButton(onPressed: (){
                          Provider.of<GetDatabase>(context, listen: false).updateAppVersions(waiting: !waiting);
                        }, icon: Icon(Icons.access_time, color: waiting ? Colors.blue :  null, )),
                      ],),
                  ],
                ),
              )
            ),
            /*const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("This List will disappear if you exit this page"),
            ),
            Expanded(
                child: ListView.builder(
              itemCount: tempNotifies.length,
              itemBuilder: (BuildContext context, int index) {
                if (tempNotifies.isEmpty) {
                  return const Center(
                    child: Text("There no temprery sent notifications"),
                  );
                } else {
                  return ListTile(
                    title: Text(tempNotifies[index].title),
                    subtitle: Text(
                        "${tempNotifies[index].body} ${tempNotifies[index].linkImg ? "With Image Link" : ""}"),
                    trailing: Text(tempNotifies[index].who),
                  );
                }
              },
            ))*/
          ],
        ),
      ),
    );
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
