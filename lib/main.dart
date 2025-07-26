import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';//d
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/fire_push_notify.dart';
import 'package:sboapp/services/get_database.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/services/navigate_page_ads.dart';
import 'package:sboapp/services/net_connectivity.dart';
import 'package:sboapp/services/notify_db_helper.dart';
import 'package:sboapp/services/notify_hold_service.dart';

import 'package:sboapp/services/offline_books/offline_books_provider.dart';
import 'package:sboapp/themes/theme_provider.dart';
import 'package:sboapp/routes_page.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'app_model/notification_model.dart';
import 'app_model/offline_books_model.dart';
import 'firebase_options.dart';


void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    //notify hive db
    // Initialize Hive
    await Hive.initFlutter();

    // Register the adapter
    Hive.registerAdapter(OfflineBooksModelAdapter());
    Hive.registerAdapter(NotificationModelAdapter());

    // Open the notifications box
    await Hive.openBox<OfflineBooksModel>('offline_data');
    await Hive.openBox<NotificationModel>('notifications');
    //ended

    //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await MobileAds.instance.initialize();
    FireNotifyApi().initNotification();
    //FirebaseAppCheck.instance.activate();
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (Platform.isAndroid) {
        //await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      }
    });*/
  } catch (e) {
    log(e.toString());
  }
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
    ChangeNotifierProvider(create: (context) => GetDatabase()),
    ChangeNotifierProvider(create: (context) => NotificationProvider()),
    ChangeNotifierProvider(create: (context) => AuthServices()),
    //ChangeNotifierProvider(create: (_) => NativeAdsState()), don
    ChangeNotifierProvider(create: (context) => NavigatePageAds()),
    ChangeNotifierProvider(create: (context) => ThemeProvider()),
    ChangeNotifierProvider(create: (context) => AppLocalizationsNotifier()),
    //testing db notify
    ChangeNotifierProvider(create: (context) => ManageNotifyProvider()),
    //testing offline books
    ChangeNotifierProvider(create: (context)=> OfflineBooksProvider()),
  ], child: const MyApp()));
// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context, listen: false).getCurrentTheme();
    Provider.of<ThemeProvider>(context, listen: false).getThemeMode();

    return const RoutesPage();
  }
}
