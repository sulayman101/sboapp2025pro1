// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/components/awesome_snackbar.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/custom_phone/custom_phone.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyNum extends StatefulWidget {
  final String? number;
  const VerifyNum({super.key, this.number});

  @override
  State<VerifyNum> createState() => _VerifyNumState();
}

class _VerifyNumState extends State<VerifyNum> with WidgetsBindingObserver {
  final _txtNum = TextEditingController();
  String? _txtShrNum;
  final _txtHoldNum = TextEditingController();
  final _txtSmsCode = TextEditingController();
  bool isChecked = true;
  String? dialCode;
  bool codeSent = false;
  Timer? _timer;
  int _start = 120;
  DateTime? _startTime;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // FormKey

  // Start the countdown timer
  void startTimer() {
    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_start > 0) {
          _start--;
          _saveTimerState(); // Save the remaining time
        } else {
          _timer?.cancel();
          _clearTimerState(); // Clear the timer state when countdown finishes
        }
      });
    });
  }

  void _showVerificationSheet(BuildContext context, authProvider) {
    final Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (BuildContext context) => PopScope(
              canPop: false,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.arrow_back_ios)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Container(
                                  width: size.width * 0.2,
                                  height: size.height * 0.015,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade500,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      titleText(text: "OTP Code", fontSize: 18),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: bodyText(
                            text:
                                "We have just sent a 6-digit verification code to ${_txtShrNum ?? _txtNum.text}. Please check your SMS to verify."),
                      ),
                      Pinput(
                        controller: _txtSmsCode,
                        length: 6,
                      ),
                      const SizedBox(height: 10),
                      materialButton(
                          color: Theme.of(context).colorScheme.primary,
                          txtColor: Theme.of(context).colorScheme.onPrimary,
                          onPressed: () async {
                            await authProvider.linkPhoneNumber(
                                authProvider.verificationId, _txtSmsCode.text);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                        "Congratulations! Your number has been verified successfully.")));
                            Navigator.pop(context); // Close the bottom sheet
                          },
                          text: "Verify"),
                      SizedBox(height: size.height * 0.05),
                      TextButton(
                          onPressed: _timer != null && _start > 0
                              ? null
                              : () async {
                                  await authProvider
                                      .verifyPhoneNumber(_txtShrNum);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      customizedSnackBar(
                                          title: "OTP",
                                          message:
                                              "Code sent to ${_txtNum.text}",
                                          contentType: ContentType.success));
                                },
                          child: buttonText(
                              text: _timer != null && _start > 0
                                  ? 'Resend in $_start sec'
                                  : 'Resend')),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: buttonText(text: "Wrong number!")),
                      SizedBox(
                        height: size.height * 0.1,
                      )
                    ],
                  ),
                ),
              ),
            ));
  }

  Future<void> _loadSavedTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('time_left');
    final startTimeMillis = prefs.getInt('start_time');
    final cKey = prefs.getString('key');
    final uNum = prefs.getString("num");
    final authProvider = Provider.of<AuthServices>(context, listen: false);

    if (savedTime != null &&
        startTimeMillis != null &&
        cKey != null &&
        uNum != null) {
      final startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
      final difference = DateTime.now().difference(startTime).inSeconds;
      _showVerificationSheet(context, authProvider);
      if (difference < savedTime) {
        setState(() {
          dialCode = cKey;
          _txtHoldNum.text = uNum;
          _start = savedTime - difference;
          codeSent = true;
          startTimer();
        });
      } else {
        setState(() {
          dialCode = cKey;
          _txtHoldNum.text = uNum;
        });
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(dialCode.toString())));
    }
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('time_left', _start);
    await prefs.setInt('start_time', _startTime!.millisecondsSinceEpoch);
    await prefs.setString("key", dialCode!);
    await prefs.setString("num", _txtNum.text);
  }

  // Clear saved timer state
  Future<void> _clearTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('time_left');
    await prefs.remove('start_time');
    await prefs.remove("key");
    await prefs.remove("num");
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthServices>(context, listen: false);
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return Center(child: authNum(authProvider, providerLocale)
        //old
        /*Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        titleText(text: providerLocale.bodyComingSoon),
        bodyText(text: "Upload book request"),
        TextButton(
          onPressed: ()=> launchUrl(Uri.parse("https://wa.me/252702032244")),
            child: buttonText(text: providerLocale.bodyBookContactUs)),
        const ListAds(),
      ],),
    ); */
        //new
        /*Column(
        children: [
      titleText(text: "Verify you number to request Agent", fontSize: 18),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _phoneWidget(providerLocale)),
          Padding(
            padding: const EdgeInsets.only(bottom: 11.0),
            child: TextButton(onPressed: _timer != null ? null : ()async{
              if(_txtNum.text.isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating,content: Text("Please enter your number.")));
              }else {
                await authProvider.verifyPhoneNumber(_txtNum.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text("Code sent to ${_txtNum.text}")));
                setState(() {
                  codeSent = true;
                });
              }
            },child: buttonText(text:'Send Code')),
          )
        ],
      ),
      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        Visibility(
          visible: codeSent,
            child: Column(children: [
              titleText(text: "OTP Code", fontSize: 18),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: bodyText(text: "We have just sent verification code 6 digits on ${_txtNum.text} please check SMS to verify"),
          ),
          Pinput(
            controller: _txtSmsCode,
            length: 6,
          ),
          materialButton(
              color: Theme.of(context).colorScheme.primary,
              txtColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () async{
                //String verificationId = authProvider.verificationId;
                await authProvider.linkPhoneNumber(authProvider.verificationId, _txtSmsCode.text);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(behavior: SnackBarBehavior.floating,content: Text("Congratulation number is verified successfully.")));
              }, text: "Verify"),
        ],)),
    ],);*/
        );
  }

  Widget authNum(authProvider, providerLocale) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
          children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.01,
            width: MediaQuery.of(context).size.width * 0.085,
            decoration: BoxDecoration(
            color: Colors.grey,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: titleText(text: "Verify your number to request Uploader", fontSize: 18),
        ),
        Row(
          children: [
            Expanded(
                child: _phoneWidget(
                    providerLocale)),
          ],
        ), // Assuming you have this widget defined
        Padding(
          padding: const EdgeInsets.only(bottom: 11.0),
          child: materialButton(
            color: Theme.of(context).colorScheme.primary,
              txtColor: Theme.of(context).colorScheme.surface,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (!codeSent) {
                    await authProvider.verifyPhoneNumber(_txtNum.text);
                  }
                  _showVerificationSheet(context, authProvider);
                  setState(() {
                    codeSent = true;
                    startTimer(); // Start countdown timer
                  });
                }
              },
              text: codeSent ? 'Show verify' : 'Send'),
        ),
      ]),
    );
  }

  Widget _phoneWidget(providerLocale) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      child: CustomPhoneField(
        languageCode:
            Provider.of<AppLocalizationsNotifier>(context, listen: true)
                .selectedLocal
                .languageCode,
        controller: _txtHoldNum,
        initialCountryCode: dialCode,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
            labelText: providerLocale.bodyLblPhone,
            hintText: "Update your number",
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary))),
        onChanged: (phone) {
          _txtNum.text = phone.completeNumber;
        },
        onCountryChanged: (countries) {
          dialCode = countries.code;
        },
        validator: (value) {
          return providerLocale.bodyCheckPhone;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}
