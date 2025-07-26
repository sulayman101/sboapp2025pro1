import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sboapp/constants/settings_card.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/themes/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final providerLocale;
  const Settings({super.key, this.providerLocale});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final colors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.grey,
    Colors.brown,
    Colors.pink
  ];

  int? _selectedTheme;
  int chipSelected = 0;
  List labelsList = [Icons.light_mode, Icons.brightness_auto, Icons.dark_mode];
  int? selected;

  _selectTheme({index, textValue, colors, action, themeSelected}) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: action,
              child: ClipRRect(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: colors[index]),
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.15,
                ),
              ),
            ),
            _selectedTheme == themeSelected
                ? Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : Container(),
          ],
        ),
        Text(textValue),
      ],
    );
  }

  void getChipSelected() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? selectedChip = preferences.getInt("ThemeMode");
    if (selectedChip != null) {
      setState(() {
        chipSelected = selectedChip;
      });
    } else {
      chipSelected = 1;
    }
  }

  _themeModeChips() {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      ChoiceChip(
          side: BorderSide.none,
          showCheckmark: false,
          label: Icon(
            labelsList[0],
            color: chipSelected == 0
                ? Theme.of(context).colorScheme.onPrimary
                : null,
          ),
          selectedColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          selected: chipSelected == 0,
          onSelected: (value) {
            setState(() {
              chipSelected = 0;
              selected = 0;
              Provider.of<ThemeProvider>(context, listen: false)
                  .setThemeMode(selected);
            });
          }),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ChoiceChip(
            side: BorderSide.none,
            showCheckmark: false,
            label: Icon(labelsList[1],
                color: chipSelected == 1
                    ? Theme.of(context).colorScheme.onPrimary
                    : null),
            selectedColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            selected: chipSelected == 1,
            onSelected: (value) {
              setState(() {
                chipSelected = 1;
                selected = 1;
                Provider.of<ThemeProvider>(context, listen: false)
                    .setThemeMode(selected);
              });
            }),
      ),
      ChoiceChip(
          side: BorderSide.none,
          showCheckmark: false,
          label: Icon(
            labelsList[2],
            color: chipSelected == 2
                ? Theme.of(context).colorScheme.onPrimary
                : null,
          ),
          selectedColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          selected: chipSelected == 2,
          onSelected: (value) {
            setState(() {
              chipSelected = 2;
              selected = 2;
              Provider.of<ThemeProvider>(context, listen: false)
                  .setThemeMode(selected);
            });
          }),
    ]);
  }

  void getCurrent() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? current = preferences.getInt("currentTheme");
    if (current != null) {
      setState(() {
        _selectedTheme = current;
      });
    }
  }

  Locale? selectedLanguage;

  @override
  void initState() {
    super.initState();
    getCurrent();
    getChipSelected();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CardSettings(
          leading: Icon(Icons.color_lens_sharp,
              color: Theme.of(context).colorScheme.primary),
          title: Text(widget.providerLocale.bodyChangeTheme),
          trailing: _themeModeChips(),
          onTap: () {
            showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: _themeOptions(),
                  );
                });
          },
        ),
        CardSettings(
          leading: const Icon(Icons.language),
          title: Text(widget.providerLocale
              .changeLanguage), //title(context: context, text: ),
          trailing: DropdownButton<Locale>(
            underline: Container(),
            value: selectedLanguage ?? Localizations.localeOf(context),
            items: AppLocalizations.supportedLocales.map((locale) {
              return DropdownMenuItem<Locale>(
                value: locale,
                child: Text(locale.languageCode == "en" ? "English" : "عربي"),
              );
            }).toList(),
            onChanged: (newLocale) {
              setState(() {
                selectedLanguage = newLocale!;
              });
              Provider.of<AppLocalizationsNotifier>(context, listen: false)
                  .changeLocale(newLocale!);
            },
          ),
        ),
        CardSettings(
            leading: const Icon(Icons.help),
            title: Text(widget.providerLocale.bodyFeedbackAndHelp),
            onTap: () {
              Navigator.pushNamed(context, '/help');
            }),
        CardSettings(
            leading: const Icon(Icons.logout),
            title: Text(widget.providerLocale.bodySingOut),
            onTap: () {
              context.read<AuthServices>().fireAuth.signOut();
              Navigator.pop(context);
            }),
      ],
    );
  }

  _themeOptions() {
    List names = [
      widget.providerLocale.bodyColorBlue,
      widget.providerLocale.bodyColorGreen,
      widget.providerLocale.bodyColorPurple,
      widget.providerLocale.bodyColorGrey,
      widget.providerLocale.bodyColorBrown,
      widget.providerLocale.bodyColorPink
    ];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          titleText(
              text: widget.providerLocale.bodyThemes,
              fontSize: MediaQuery.of(context).textScaler.scale(18)),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Divider(thickness: 2),
          ),
          GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              shrinkWrap: true,
              itemCount: names.length,
              itemBuilder: (context, int index) {
                return _selectTheme(
                    index: index,
                    textValue: names[index],
                    colors: colors,
                    action: () {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .changeTheme(index);
                      _selectedTheme = index;
                      Navigator.pop(context);
                    },
                    themeSelected: index);
              }),
        ],
      ),
    );
  }
}
/*
children: [
                  _selectTheme(index: 0, textValue: "Default", colors: colors, action: (){
                    Provider.of<ThemeProvider>(context, listen: false).changeTheme(0);
                    _selectedTheme = 0;
                    Navigator.pop(context);
                  }, themeSelected: 0),
                  _selectTheme(index: 1, textValue: "Green", colors: colors, action: (){
                    Provider.of<ThemeProvider>(context, listen: false).changeTheme(1);
                    _selectedTheme = 1;
                    Navigator.pop(context);
                  }, themeSelected:1),
                  _selectTheme(index: 2, textValue: "Purple", colors: colors, action: (){
                    Provider.of<ThemeProvider>(context, listen: false).changeTheme(2);
                    _selectedTheme = 2;
                    Navigator.pop(context);
                  }, themeSelected: 2),
                  _selectTheme(index: 3, textValue: "Grey", colors: colors, action: (){
                    Provider.of<ThemeProvider>(context, listen: false).changeTheme(3);
                    _selectedTheme = 3;
                    Navigator.pop(context);
                  }, themeSelected: 3),
                  _selectTheme(index: 4, textValue: "Brown", colors: colors, action: (){
                    Provider.of<ThemeProvider>(context, listen: false).changeTheme(4);
                    _selectedTheme = 4;
                    Navigator.pop(context);
                  }, themeSelected: 4),
                  _selectTheme(index: 5, textValue: "Pink", colors: colors, action: (){
                    Provider.of<ThemeProvider>(context, listen: false).changeTheme(5);
                    _selectedTheme = 5;
                    Navigator.pop(context);
                  }, themeSelected: 5),
                ],

 */