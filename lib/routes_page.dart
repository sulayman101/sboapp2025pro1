import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'package:sboapp/themes/theme_provider.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/routes/app_routes.dart';

import 'l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class RoutesPage extends StatelessWidget {
  const RoutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Provider.of<ThemeProvider>(context, listen: true);
    final proLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true);
    return MaterialApp(
      showPerformanceOverlay: true,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(useMaterial3: true, colorScheme: colorScheme.getLightTheme),
      darkTheme:
          ThemeData(useMaterial3: true, colorScheme: colorScheme.getDarkTheme),
      themeMode: colorScheme.getMode,
      navigatorKey: navigatorKey,
      locale: proLocale.selectedLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: '/',
      routes: AppRoutes.routes, // Delegated to a separate file
    );
  }
}
