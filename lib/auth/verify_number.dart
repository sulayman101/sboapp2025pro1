// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
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
  final _txtHoldNum = TextEditingController();
  final _txtSmsCode = TextEditingController();
  String? dialCode;
  bool codeSent = false;
  Timer? _timer;
  int _start = 120;
  DateTime? _startTime;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void startTimer() {
    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_start > 0) {
          _start--;
          _saveTimerState();
        } else {
          _timer?.cancel();
          _clearTimerState();
        }
      });
    });
  }

  Future<void> _loadSavedTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('time_left');
    final startTimeMillis = prefs.getInt('start_time');
    final savedDialCode = prefs.getString('key');
    final savedNumber = prefs.getString("num");
    final authProvider = Provider.of<AuthServices>(context, listen: false);

    if (savedTime != null &&
        startTimeMillis != null &&
        savedDialCode != null &&
        savedNumber != null) {
      final startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
      final difference = DateTime.now().difference(startTime).inSeconds;

      if (difference < savedTime) {
        setState(() {
          dialCode = savedDialCode;
          _txtHoldNum.text = savedNumber;
          _start = savedTime - difference;
          codeSent = true;
          startTimer();
        });
      } else {
        setState(() {
          dialCode = savedDialCode;
          _txtHoldNum.text = savedNumber;
        });
      }
      _showVerificationSheet(context, authProvider);
    }
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('time_left', _start);
    await prefs.setInt('start_time', _startTime!.millisecondsSinceEpoch);
    await prefs.setString("key", dialCode!);
    await prefs.setString("num", _txtNum.text);
  }

  Future<void> _clearTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('time_left');
    await prefs.remove('start_time');
    await prefs.remove("key");
    await prefs.remove("num");
  }

  void _showVerificationSheet(BuildContext context, AuthServices authProvider) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSheetHeader(context),
              const SizedBox(height: 20),
              titleText(text: "OTP Code", fontSize: 18),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: bodyText(
                  text:
                      "We have just sent a 6-digit verification code to ${_txtNum.text}. Please check your SMS to verify.",
                ),
              ),
              Pinput(controller: _txtSmsCode, length: 6),
              const SizedBox(height: 10),
              materialButton(
                color: Theme.of(context).colorScheme.primary,
                txtColor: Theme.of(context).colorScheme.onPrimary,
                onPressed: () async {
                  await authProvider.linkPhoneNumber(_txtSmsCode.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                          "Congratulations! Your number has been verified successfully."),
                    ),
                  );
                  Navigator.pop(context);
                },
                text: "Verify",
              ),
              SizedBox(height: size.height * 0.05),
              _buildResendButton(authProvider),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: buttonText(text: "Wrong number!"),
              ),
              SizedBox(height: size.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetHeader(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.height * 0.015,
            decoration: BoxDecoration(
              color: Colors.grey.shade500,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResendButton(AuthServices authProvider) {
    return TextButton(
      onPressed: _timer != null && _start > 0
          ? null
          : () async {
              await authProvider.verifyPhoneNumber(_txtNum.text);
              ScaffoldMessenger.of(context).showSnackBar(
                customizedSnackBar(
                  title: "OTP",
                  message: "Code sent to ${_txtNum.text}",
                  contentType: ContentType.success,
                ),
              );
            },
      child: buttonText(
        text: _timer != null && _start > 0 ? 'Resend in $_start sec' : 'Resend',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthServices>(context, listen: false);
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context).localizations;

    return Center(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPhoneInput(providerLocale),
            _buildSendButton(authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput(providerLocale) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomPhoneField(
        languageCode: Provider.of<AppLocalizationsNotifier>(context)
            .selectedLocale.languageCode,
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
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        onChanged: (phone) => _txtNum.text = phone.completeNumber,
        onCountryChanged: (countries) => dialCode = countries.code,
        validator: (value) => providerLocale.bodyCheckPhone,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildSendButton(AuthServices authProvider) {
    return Padding(
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
              startTimer();
            });
          }
        },
        text: codeSent ? 'Show verify' : 'Send',
      ),
    );
  }
}
