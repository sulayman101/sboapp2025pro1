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

  @override
  void initState() {
    super.initState();
    _clearAllNotifications();
    _checkDot();
  }

  Future<void> _clearAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _checkDot() async {
    final sp = await SharedPreferences.getInstance();
    sp.getBool('read');
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    final provider = Provider.of<ManageNotifyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(providerLocale.appBarNotification),
        actions: [
          IconButton(
            onPressed: () => _showClearNotificationsDialog(provider),
            icon: const Icon(Icons.cleaning_services),
          ),
        ],
      ),
      body: provider.notifications.isNotEmpty
          ? _buildNotificationList(provider)
          : const Center(child: Text("No Notifications")),
    );
  }

  Widget _buildNotificationList(ManageNotifyProvider provider) {
    final notifications = provider.notifications;
    notifications.sort((a, b) => b.date!.compareTo(a.date!));

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Card.filled(
          child: ListTile(
            leading: _buildNotificationImage(notification.imgUrl),
            title: lTitleText(text: notification.title),
            subtitle: lSubTitleText(text: notification.subtitle),
            trailing: Visibility(
              visible: !notification.isRead,
              child: const Icon(Icons.notifications_active),
            ),
            onTap: () =>
                _handleNotificationTap(context, provider, notification),
          ),
        );
      },
    );
  }

  Widget _buildNotificationImage(String? imgUrl) {
    return imgUrl == null
        ? const Icon(Icons.add_alert)
        : ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ImageNetCache(imageSize: 0.04, imageUrl: imgUrl),
          );
  }

  void _handleNotificationTap(BuildContext context,
      ManageNotifyProvider provider, NotificationModel notification) async {
    provider.markAsRead(notification.id);

    if (notification.bookLink != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReadingPage(
            bookLink: notification.bookLink!,
            title: notification.title,
          ),
        ),
      );
    } else if (notification.link != null) {
      _showLinkDialog(context, notification);
    } else {
      _showInfoDialog(context, notification);
    }
  }

  void _showLinkDialog(BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: titleText(text: notification.title),
        content: bodyText(text: notification.subtitle),
        actions: [
          TextButton(
            onPressed: () {
              launchUrl(Uri.parse(notification.link!));
              Navigator.pop(context);
            },
            child: buttonText(text: "Open"),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: titleText(text: notification.title),
        content: bodyText(text: notification.subtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: buttonText(text: "Ok"),
          ),
        ],
      ),
    );
  }

  void _showClearNotificationsDialog(ManageNotifyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: titleText(text: "Clear Notifications"),
        content: bodyText(text: "Do you want to clear all notifications?"),
        actions: [
          TextButton(
            onPressed: () {
              provider.deleteAllNotifications();
              Navigator.pop(context);
            },
            child: const Text("Clear"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
