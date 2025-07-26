import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/text_form_field.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/reports_function.dart';

Future loadingAlert({required BuildContext context}) async {
  showDialog(
      context: context,
      builder: (context) => const PopScope(
            canPop: false,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ));
}

Future bannedAlert({required BuildContext context}) async {
  showDialog(
      context: context,
      builder: (context) => Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black
                      .withOpacity(0), // Needed to apply the blur effect
                ),
              ),
              PopScope(
                canPop: false,
                child: AlertDialog(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  contentTextStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onError),
                  titleTextStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  title: const Text('Account Banned!'),
                  content: const Text(
                      'Your account has been banned. Please contact support for more information.'),
                  actions: [
                    Column(
                      children: [
                        materialButton(
                          text: 'Appeal',
                          onPressed: () {
                            _showBottomSheet(context: context);
                          },
                        ),
                        materialButton(
                          text: 'Sign out',
                          onPressed: () async {
                            await AuthServices().singOut();
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                        TextButton(
                          child: const Text('delete'),
                          onPressed: () async {
                            await AuthServices().singOut();
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ));
}

Future _showBottomSheet({required BuildContext context}) async {
  final txtUserReport = TextEditingController();
  double size = 0.35;
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PopScope(
          canPop: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                    thickness: 5,
                    indent: MediaQuery.of(context).size.width * size,
                    endIndent: MediaQuery.of(context).size.width * size),
                titleText(text: "Appeal Report", fontSize: 18),
                MyTextFromField(
                  labelText: "Appeal",
                  hintText: "Explain the problem!.",
                  textEditingController: txtUserReport,
                  maxLines: 5,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: materialButton(
                          onPressed: () {
                            String uid = AuthServices()
                                .fireAuth
                                .currentUser!
                                .uid
                                .toString();
                            String email = AuthServices()
                                .fireAuth
                                .currentUser!
                                .email
                                .toString();
                            String name = AuthServices()
                                .fireAuth
                                .currentUser!
                                .displayName
                                .toString();
                            String issue = "User Ban Appeal";
                            String userReport = txtUserReport.value.text;
                            ReportFunction().sendReportEmail(
                                toEmail: "sanaagbook@gmail.com",
                                subject: issue,
                                body: "$uid\n$email\n$name\n$userReport");
                          },
                          text: "Appeal"),
                    ),
                    Expanded(
                      flex: 1,
                      child: materialButton(
                          onPressed: () {
                            AuthServices().singOut();
                            Navigator.pop(context);
                          },
                          text: "Cansel"),
                    ),
                  ],
                ),
              ],
            ),
          ))); // Close the dialog
}

Future errorAlert({required BuildContext context, required String msg}) async {
  showDialog(
    context: context,
    builder: (context) => PopScope(
        canPop: true,
        child: AlertDialog(
          title: titleText(text: "Error"),
          content: Text(msg),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: buttonText(text: "ok"))
          ],
        )),
  );
}
