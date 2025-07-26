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
  // ignore: prefer_typing_uninitialized_variables
  final providerLocale;
  const OnboardingView({super.key, this.providerLocale});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  // ignore: prefer_typing_uninitialized_variables
  var controller;
  final pageController = PageController();

  bool isLastPage = false;
  bool singInOrUp = true;
  bool isAuth = false;
  Set<Locale>? selectedLanguage;

  void onBoardingStatus(value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isComp", value);
  }

  void onBoardingGet() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {});
    if (prefs.getBool("isComp") != null) {
      isAuth = prefs.getBool("isComp")!;
    }
  }

  @override
  void initState() {
    super.initState();
    onBoardingGet();
  }

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    controller = providerLocale.language == "العربية"
        ? OnboardingItemsAr()
        : OnboardingItemsEn();
    return Scaffold(
      appBar: !isAuth
          ? null
          : AppBar(
              title: appBarText(
                  text: singInOrUp
                      ? providerLocale.bodySingIn
                      : providerLocale.bodySingUp),
            ),
      body: isAuth
          ? _authPages()
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<Locale>(
                      value: selectedLanguage?.first ??
                          Localizations.localeOf(context),
                      items: const [
                        DropdownMenuItem(
                          value: Locale("en"),
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: Locale("ar"),
                          child: Text('عربي'),
                        ),
                      ],
                      onChanged: (Locale? newLocale) {
                        if (newLocale != null) {
                          setState(() {
                            selectedLanguage = {newLocale};
                          });
                          Provider.of<AppLocalizationsNotifier>(context,
                                  listen: false)
                              .changeLocale(newLocale);
                        }
                      },
                    ),
                    Expanded(
                      child: PageView.builder(
                          onPageChanged: (index) => setState(() => isLastPage =
                              controller.items.length - 1 == index),
                          itemCount: controller.items.length,
                          controller: pageController,
                          itemBuilder: (context, index) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Image.asset(
                                        controller.items[index].image)),
                                const SizedBox(height: 15),
                                Text(
                                  controller.items[index].title,
                                  style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 15),
                                AnimatedTextKit(
                                  animatedTexts: [
                                    TypewriterAnimatedText(
                                      controller.items[index].descriptions,
                                      textStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 17),
                                      textAlign: TextAlign.center,
                                      //speed: const Duration(milliseconds: 5),
                                    ),
                                  ],
                                  displayFullTextOnTap: true,
                                  totalRepeatCount: 1,
                                ),
                              ],
                            );
                          }),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.07,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: isLastPage
                          ? getStarted()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //Skip Button
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        onBoardingStatus(!isAuth);
                                        isAuth = !isAuth;
                                      });
                                    },
                                    child: buttonText(
                                        text: providerLocale.bodySkip)),

                                //Indicator
                                SmoothPageIndicator(
                                  controller: pageController,
                                  count: controller.items.length,
                                  onDotClicked: (index) =>
                                      pageController.animateToPage(index,
                                          duration:
                                              const Duration(milliseconds: 600),
                                          curve: Curves.easeIn),
                                  effect: const WormEffect(
                                    dotHeight: 12,
                                    dotWidth: 12,
                                    activeDotColor: Colors.blue,
                                  ),
                                ),

                                //Next Button
                                TextButton(
                                    onPressed: () => pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 600),
                                        curve: Curves.easeIn),
                                    child: buttonText(
                                        text: providerLocale.bodyBookNext)),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  //Now the problem is when press get started button
  // after re run the app we see again the onboarding screen
  // so lets do one time onboarding

  //Get started button

  Widget getStarted() {
    final provider =
        Provider.of<AppLocalizationsNotifier>(context, listen: true);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: Colors.blue),
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.5,
      child: TextButton(
        onPressed: () async {
          //final SharedPreferences prefs = await SharedPreferences.getInstance();
          setState(() {});
          onBoardingStatus(!isAuth);
          isAuth = !isAuth;
        },
        child: customText(
            text: provider.localizations.bodyGetStart, color: Colors.white),
      ),
    );
  }

  void changeAuth() {
    setState(() {});
    singInOrUp = !singInOrUp;
  }

  Widget _authPages() {
    return singInOrUp
        ? SignIn(
            onSignUp: changeAuth,
          )
        : SignUp(
            onSignIn: changeAuth,
          );
  }
}
