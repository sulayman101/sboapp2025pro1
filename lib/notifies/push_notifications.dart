// ignore_for_file: use_build_context_synchronously



import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/app_model/notification_model.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/screens/presentation/pdf_reader_page.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Constants/shimmer_widgets/home_shimmer.dart';
import '../services/notify_db_helper.dart';

class NotifyPage extends StatefulWidget {
  const NotifyPage({super.key});

  @override
  State<NotifyPage> createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  void _clearAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  checkDot() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.getBool('read');
  }


  @override
  void initState() {
    super.initState();
    _clearAllNotifications();
    checkDot();
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    final provider = Provider.of<ManageNotifyProvider>(context);
    //provider.loadNotifications();

    return Scaffold(
      appBar: AppBar(
        title: Text(providerLocale.appBarNotification),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: titleText(text: "Clear Notifications"),
                          content: bodyText(
                              text: "Do you went to Clear all Notifications?"),
                          actions: [
                            TextButton(
                                onPressed: (){
                                  provider.deleteAllNotifications();
                                  Navigator.pop(context);
                                },
                                child: const Text("Clear")),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel"))
                          ],
                        ));
              },
              icon: const Icon(Icons.cleaning_services))
        ],
      ),
      body: provider.notifications.isNotEmpty ? ListView.builder(
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                //final notification = snapshot.data![index];
                final List<NotificationModel> notification = provider.notifications;
                notification.sort((a, b) => b.date!.compareTo(a.date!));
                //log(notification[index].link.toString());
                  return Card.filled(
                    child: ListTile(
                      leading: notification[index].imgUrl == null
                          ? const Icon(Icons.add_alert)
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                            child: ImageNetCache(
                            imageSize:  0.04,
                            imageUrl: notification[index].imgUrl.toString()),
                          ),
                      title: lTitleText(text: notification[index].title),
                      subtitle: lSubTitleText(text: notification[index].subtitle),
                      trailing: Visibility(
                          visible: !notification[index].isRead,
                          child: const Icon(Icons.notifications_active)),
                      onTap: () async {// Create the notifications table
                        provider.markAsRead(notification[index].id);
                        if (notification[index].bookLink != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReadingPage(
                                    bookLink: notification[index].bookLink!,
                                    title: notification[index].title,
                                  )));
                        } else if(notification[index].link != null && notification[index].bookLink == null){
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title:
                                titleText(text: notification[index].title),
                                content: bodyText(
                                    text: notification[index].subtitle),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        launchUrl(Uri.parse(notification[index].link!));
                                        Navigator.pop(context);
                                        },
                                      child: buttonText(text: "Open"))
                                ],
                              ));
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title:
                                titleText(text: notification[index].title),
                                content: bodyText(
                                    text: notification[index].subtitle),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: buttonText(text: "Ok"))
                                ],
                              ));
                        }
                      },
                    ),
    );}) : const Center(child: Text("No Notifications"))

    );
  }
}


/**
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/AppModel/notify_model.dart';
import 'package:sboapp/Components/ads_and_net.dart';
import 'package:sboapp/Constants/text_style.dart';
import 'package:sboapp/Services/notify_hold_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class NotifyPage extends StatefulWidget {
  const NotifyPage({super.key});

  @override
  State<NotifyPage> createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> {

  List _notifyList = [];
  Stream<List<NotificationModel>> getNotify() async* {
    final preShare = await SharedPreferences.getInstance();
     final notify = preShare.getStringList("notifications");
     if(notify != null) {
       _notifyList.add(notify);
     }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotify();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      appBar: AppBar(
        title: appBarText(text: "Notifications"),
      ),
      body: Consumer<NotificationProvider>(builder: (BuildContext context, NotificationProvider value, Widget? child) {
        final provider = context.read<NotificationProvider>();
        return StreamBuilder<List<NotificationModel>>(
          stream: provider.loadNotifications(),
          builder: (BuildContext context, AsyncSnapshot<List<NotificationModel>> snapshot) {
            if(snapshot.hasData){
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: snapshot.data![index].imageUrl != "" ? Image.network(snapshot.data![index].imageUrl!) : Icon(Icons.add_alert_sharp),
                    title: Text(snapshot.data![index].title),
                    subtitle: Text(snapshot.data![index].body),
                    trailing: Badge(isLabelVisible: true , smallSize: 10,alignment: Alignment.center,),
                  );
                },
              );
            }else{
              return const Center(child: Text("No Notifications"));
            }
          },);
      },
      )
    );
  }
}
    **/