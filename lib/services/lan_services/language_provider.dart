import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';

class AppLocalizationsNotifier extends ChangeNotifier {
  late AppLocalizations _localizations;
  Locale _selectedLocale = const Locale("en");

  AppLocalizationsNotifier() {
    _initializeLocalizations();
    WidgetsBinding.instance.addObserver(_LocaleObserver(_onLocaleChanged));
  }

  AppLocalizations get localizations => _localizations;
  Locale get selectedLocale => _selectedLocale;

  Future<void> changeLocale(Locale newLocale) async {
    final sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setString('locale', newLocale.languageCode);
    _updateLocalizations(newLocale);
  }

  Future<void> loadSavedLocale() async {
    final sharedPref = await SharedPreferences.getInstance();
    final savedLocaleCode = sharedPref.getString('locale');
    if (savedLocaleCode != null) {
      _updateLocalizations(Locale(savedLocaleCode));
    }
  }

  void _initializeLocalizations() {
    _updateLocalizations(WidgetsBinding.instance.window.locale);
  }

  void _updateLocalizations(Locale locale) {
    _localizations = lookupAppLocalizations(locale);
    _selectedLocale = locale;
    notifyListeners();
  }

  void _onLocaleChanged(List<Locale>? locales) {
    if (locales != null && locales.isNotEmpty) {
      _updateLocalizations(locales.first);
    }
  }
}

class _LocaleObserver extends WidgetsBindingObserver {
  final void Function(List<Locale>?) onLocaleChanged;

  _LocaleObserver(this.onLocaleChanged);

  @override
  void didChangeLocales(List<Locale>? locales) {
    onLocaleChanged(locales);
  }
}
