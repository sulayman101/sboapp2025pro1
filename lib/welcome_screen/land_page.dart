import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/auth/signin.dart';
import 'package:sboapp/auth/signup.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:sboapp/welcome_screen/on_board_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingView extends StatefulWidget {
  final dynamic providerLocale;

  const OnboardingView({super.key, this.providerLocale});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;
  bool _isAuth = false;
  bool _isSignIn = true;
  Locale? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAuth = prefs.getBool("isComp") ?? false;
    });
  }

  Future<void> _saveOnboardingStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isComp", value);
  }

  void _toggleAuthMode() {
    setState(() {
      _isSignIn = !_isSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    final controller = providerLocale.language == "العربية"
        ? OnboardingItemsAr()
        : OnboardingItemsEn();

    return Scaffold(
      appBar: _isAuth
          ? AppBar(
              title: appBarText(
                text: _isSignIn
                    ? providerLocale.bodySingIn
                    : providerLocale.bodySingUp,
              ),
            )
          : null,
      body: _isAuth ? _buildAuthPages() : _buildOnboardingPages(controller),
    );
  }

  Widget _buildOnboardingPages(dynamic controller) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLanguageDropdown(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() {
                  _isLastPage = index == controller.items.length - 1;
                }),
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(item.image),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            item.descriptions,
                            textStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        displayFullTextOnTap: true,
                        totalRepeatCount: 1,
                      ),
                    ],
                  );
                },
              ),
            ),
            _buildBottomNavigation(providerLocale, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownButton<Locale>(
      value: _selectedLanguage ?? Localizations.localeOf(context),
      items: const [
        DropdownMenuItem(value: Locale("en"), child: Text('English')),
        DropdownMenuItem(value: Locale("ar"), child: Text('عربي')),
      ],
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          setState(() {
            _selectedLanguage = newLocale;
          });
          Provider.of<AppLocalizationsNotifier>(context, listen: false)
              .changeLocale(newLocale);
        }
      },
    );
  }

  Widget _buildBottomNavigation(dynamic providerLocale, dynamic controller) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.07,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: _isLastPage
          ? _buildGetStartedButton(providerLocale)
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _saveOnboardingStatus(true);
                      _isAuth = true;
                    });
                  },
                  child: buttonText(text: providerLocale.bodySkip),
                ),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: controller.items.length,
                  onDotClicked: (index) => _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeIn,
                  ),
                  effect: const WormEffect(
                    dotHeight: 12,
                    dotWidth: 12,
                    activeDotColor: Colors.blue,
                  ),
                ),
                TextButton(
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeIn,
                  ),
                  child: buttonText(text: providerLocale.bodyBookNext),
                ),
              ],
            ),
    );
  }

  Widget _buildGetStartedButton(dynamic providerLocale) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue,
      ),
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          setState(() {
            _saveOnboardingStatus(true);
            _isAuth = true;
          });
        },
        child: customText(
          text: providerLocale.bodyGetStart,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAuthPages() {
    return _isSignIn
        ? SignIn(onSignUp: _toggleAuthMode)
        : SignUp(onSignIn: _toggleAuthMode);
  }
}
