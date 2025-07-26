import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizationsNotifier extends ChangeNotifier {
  late AppLocalizations _localizations;
  Locale selectedLocal = const Locale("en");

  AppLocalizationsNotifier() {
    _localizations =
        lookupAppLocalizations(WidgetsBinding.instance.window.locale);
    final observer = _LocaleObserver((locales) {
      _localizations =
          lookupAppLocalizations(WidgetsBinding.instance.window.locale);
      notifyListeners();
    });
    final binding = WidgetsBinding.instance;
    binding.addObserver(observer);
  }

  AppLocalizations get localizations => _localizations;

  void changeLocale(Locale newLocale) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    sharedPref.setString('local', newLocale.languageCode.toString());
    _localizations = lookupAppLocalizations(newLocale);
    selectedLocal = newLocale;
    notifyListeners();
  }

  void getLocale() async {
    SharedPreferences sharedLocal = await SharedPreferences.getInstance();
    final String? local = sharedLocal.getString("local");
    if (local != null) {
      _localizations = lookupAppLocalizations(Locale(local));
      selectedLocal = Locale(local);
    }
    notifyListeners();
  }
}

class _LocaleObserver extends WidgetsBindingObserver {
  _LocaleObserver(this._didChangeLocales);
  final void Function(List<Locale>?) _didChangeLocales;

  @override
  void didChangeLocales(List<Locale>? locales) {
    _didChangeLocales(locales);
  }
}
