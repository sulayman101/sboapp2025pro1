import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/components/awesome_snackbar.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String txtNum;
  const OtpScreen(
      {required this.verificationId, super.key, required this.txtNum});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _txtSmsCode = TextEditingController();
  String? dialCode;
  String? _txtNum;
  Timer? _timer;
  int _start = 120;

  // Start the countdown timer
  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_start > 0) {
          _start--;
        } else {
          _timer?.cancel();
          _clearTimerState(); // Clear the timer state when countdown finishes
        }
      });
    });
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
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthServices>(context, listen: false);
    final Size size = MediaQuery.of(context).size;
    return ScaffoldWidget(
        body: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        titleText(text: "OTP Code", fontSize: 18),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: bodyText(
              text:
                  "We have just sent a 6-digit verification code to $_txtNum. Please check your SMS to verify."),
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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
                    await authProvider.verifyPhoneNumber(widget.txtNum);
                    ScaffoldMessenger.of(context).showSnackBar(
                        customizedSnackBar(
                            title: "OTP",
                            message: "Code sent to ${widget.txtNum}",
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
    ));
  }
}
