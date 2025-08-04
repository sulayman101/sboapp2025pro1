import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sboapp/constants/settings_card.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/themes/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';

class Settings extends StatefulWidget {
  final dynamic providerLocale;
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
    Colors.pink,
  ];

  int? _selectedTheme;
  int chipSelected = 0;
  Locale? selectedLanguage;

  final List<IconData> themeIcons = [
    Icons.light_mode,
    Icons.brightness_auto,
    Icons.dark_mode,
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentTheme();
    _loadChipSelection();
  }

  Future<void> _loadCurrentTheme() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = preferences.getInt("currentTheme");
    });
  }

  Future<void> _loadChipSelection() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      chipSelected = preferences.getInt("ThemeMode") ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildThemeSettingsCard(),
        _buildLanguageSettingsCard(),
        _buildHelpSettingsCard(),
        _buildSignOutSettingsCard(),
      ],
    );
  }

  Widget _buildThemeSettingsCard() {
    return CardSettings(
      leading: Icon(Icons.color_lens_sharp,
          color: Theme.of(context).colorScheme.primary),
      title: Text(widget.providerLocale.bodyChangeTheme),
      trailing: _buildThemeModeChips(),
      onTap: () => _showThemeSelectionBottomSheet(),
    );
  }

  Widget _buildThemeModeChips() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        themeIcons.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ChoiceChip(
            label: Icon(
              themeIcons[index],
              color: chipSelected == index
                  ? Theme.of(context).colorScheme.onPrimary
                  : null,
            ),
            selected: chipSelected == index,
            selectedColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            onSelected: (value) {
              setState(() {
                chipSelected = index;
                Provider.of<ThemeProvider>(context, listen: false)
                    .setThemeMode(index);
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSettingsCard() {
    return CardSettings(
      leading: const Icon(Icons.language),
      title: Text(widget.providerLocale.changeLanguage),
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
    );
  }

  Widget _buildHelpSettingsCard() {
    return CardSettings(
      leading: const Icon(Icons.help),
      title: Text(widget.providerLocale.bodyFeedbackAndHelp),
      onTap: () => Navigator.pushNamed(context, '/help'),
    );
  }

  Widget _buildSignOutSettingsCard() {
    return CardSettings(
      leading: const Icon(Icons.logout),
      title: Text(widget.providerLocale.bodySingOut),
      onTap: () {
        context.read<AuthServices>().fireAuth.signOut();
        Navigator.pop(context);
      },
    );
  }

  void _showThemeSelectionBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              titleText(
                text: widget.providerLocale.bodyThemes,
                fontSize: MediaQuery.of(context).textScaler.scale(18),
              ),
              const Divider(thickness: 2),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                shrinkWrap: true,
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  return _buildThemeOption(
                    index: index,
                    color: colors[index],
                    label: widget.providerLocale.bodyColorNames[index],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required int index,
    required Color color,
    required String label,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Provider.of<ThemeProvider>(context, listen: false)
                .changeTheme(index);
            setState(() {
              _selectedTheme = index;
            });
            Navigator.pop(context);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.width * 0.15,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              if (_selectedTheme == index)
                const Icon(Icons.check, color: Colors.white),
            ],
          ),
        ),
        Text(label),
      ],
    );
  }
}
