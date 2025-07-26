import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_data.dart';

enum MyThemes {
  lightDefault,
  darkDefault,
  lightGreen,
  darkGreen,
  lightPurple,
  darkPurple,
  lightRed,
  darkRed
}

class ThemeProvider extends ChangeNotifier {
  ColorScheme? lightThemeData;
  ColorScheme? darkThemeData;
  ThemeMode? themeMode;
  ColorScheme? get getLightTheme => lightThemeData;
  ColorScheme? get getDarkTheme => darkThemeData;
  ThemeMode? get getMode => themeMode;

  List<String> myThemes = [
    "lightDefault",
    "darkDefault",
    "lightGreen",
    "darkGreen",
    "lightPurple",
    "darkPurple",
    "lightRed",
    "darkRed",
    "lightBrow",
    "darkBrown",
    "lightPink",
    "darkPink"
  ];

  void setThemeMode(selected) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt("ThemeMode", selected);
    if (selected! == 0) {
      themeMode = ThemeMode.light;
    } else if (selected == 2) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  void getThemeMode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? selected = preferences.getInt("ThemeMode");
    if (selected == 0) {
      themeMode = ThemeMode.light;
    } else if (selected == 2) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  void getCurrentTheme() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? current = preferences.getInt("currentTheme");
    if (current != null) {
      changeTheme(current);
    } else {
      changeTheme(0);
    }
  }

  void changeTheme(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt("currentTheme", index);
    if (myThemes[index] == myThemes[0] /*&& myThemes == MyThemes.darkGreen*/) {
      lightThemeData = defaultThemeLight;
      darkThemeData = defaultThemeDark;
      log("default Theme");
      //setTheme(flexGreenSchemeDark);
    } else if (myThemes[index] ==
        myThemes[1] /*&& myThemes == MyThemes.darkRed*/) {
      lightThemeData = flexGreenSchemeLight;
      darkThemeData = flexGreenSchemeDark;
      log("green Theme");
      //setTheme(flexRedSchemeDark);
    } else if (myThemes[index] ==
        myThemes[2] /*&& myThemes == MyThemes.darkRed*/) {
      lightThemeData = flexPurpleSchemeLight;
      darkThemeData = flexPurpleSchemeDark;
      log("purple Theme");
      //setTheme(flexRedSchemeDark);
    } else if (myThemes[index] ==
        myThemes[3] /*&& myThemes == MyThemes.darkGreen*/) {
      lightThemeData = flexGreySchemeLight;
      darkThemeData = flexGreySchemeDark;
      log("Red Theme");
      //setTheme(flexGreenSchemeDark);
    } else if (myThemes[index] ==
        myThemes[4] /*&& myThemes == MyThemes.darkGreen*/) {
      lightThemeData = flexBrownSchemeLight;
      darkThemeData = flexBrownSchemeDark;
      log("Brown Theme");
      //setTheme(flexGreenSchemeDark);
    } else if (myThemes[index] ==
        myThemes[5] /*&& myThemes == MyThemes.darkGreen*/) {
      lightThemeData = flexPinkSchemeLight;
      darkThemeData = flexPinkSchemeDark;
      log("Pink Theme");
      //setTheme(flexGreenSchemeDark);
    }
    notifyListeners();
  }
}
