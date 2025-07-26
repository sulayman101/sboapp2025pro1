

import 'package:flutter/material.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/text_form_field.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/auth_services.dart';
import 'package:sboapp/services/reports_function.dart';

class BannedUser extends StatelessWidget {
  final String roleAction;
  const BannedUser({super.key, required this.roleAction});

  @override
  Widget build(BuildContext context) {
    final txtUserEmail = TextEditingController();
    final txtUserBody = TextEditingController();
    return ScaffoldWidget(
        appBar: AppBar(
          title: appBarText(text: roleAction),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width * 1,
                  child: roleAction == "Banned User"
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  Image.asset("assets/images/bannedUser.gif"),
                            ),
                            customText(
                                text: "Your account was banned",
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 20),
                            materialButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Material(
                                            child: Column(
                                              children: [
                                                const Row(
                                                  children: [
                                                    Divider(
                                                      indent: 30,
                                                      endIndent: 30,
                                                      thickness: 2,
                                                    ),
                                                  ],
                                                ),
                                                MyTextFromField(
                                                    labelText: "Email",
                                                    hintText:
                                                        "Enter your email",
                                                    textEditingController:
                                                        txtUserEmail),
                                                MyTextFromField(
                                                    labelText: "Explain Issue",
                                                    hintText:
                                                        "Enter Issue detailed",
                                                    textEditingController:
                                                        txtUserBody),
                                                materialButton(
                                                    onPressed: () {
                                                      final report =
                                                          ReportFunction();
                                                      report.sendReportEmail(
                                                          toEmail: txtUserEmail
                                                              .value.text,
                                                          subject:
                                                              "User Banned",
                                                          body:
                                                              "UserId: ${AuthServices().fireAuth.currentUser!.uid} \n\n${txtUserBody.value.text}");
                                                    },
                                                    text: "Send Report"),
                                              ],
                                            ),
                                          ));
                                },
                                text: "contact us"),
                            TextButton(
                                onPressed: () {
                                  AuthServices().singOut();
                                },
                                child: buttonText(text: "Sing out"))
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  Image.asset("assets/images/deletedUser.gif"),
                            ),
                            customText(
                                text: "Your account was deleted",
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 20),
                            materialButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Material(
                                            child: Column(
                                              children: [
                                                MyTextFromField(
                                                    labelText: "Email",
                                                    hintText:
                                                        "Enter your email",
                                                    textEditingController:
                                                        txtUserEmail),
                                                MyTextFromField(
                                                    labelText: "Explain Issue",
                                                    hintText:
                                                        "Enter Issue detailed",
                                                    textEditingController:
                                                        txtUserBody),
                                                materialButton(
                                                    onPressed: () {
                                                      final report =
                                                          ReportFunction();
                                                      report.sendReportEmail(
                                                          toEmail: txtUserEmail
                                                              .value.text,
                                                          subject:
                                                              "User Banned",
                                                          body:
                                                              "UserId: ${AuthServices().fireAuth.currentUser!.uid} \n\n${txtUserBody.value.text}");
                                                    },
                                                    text: "Send Report"),
                                              ],
                                            ),
                                          ));
                                },
                                text: "contact us"),
                            const SizedBox(height: 8),
                            TextButton(
                                onPressed: () {
                                  AuthServices().deleteUser();
                                },
                                child: customText(
                                    text: "Delete", color: Colors.red[100]))
                          ],
                        ),
                ),
              ),
            ],
          ),
        ));
  }
}
