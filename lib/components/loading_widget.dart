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
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

Future bannedAlert({required BuildContext context}) async {
  showDialog(
    context: context,
    builder: (context) => Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withOpacity(0)),
        ),
        PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.error,
            contentTextStyle:
                TextStyle(color: Theme.of(context).colorScheme.onError),
            titleTextStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            title: const Text('Account Banned!'),
            content: const Text(
                'Your account has been banned. Please contact support for more information.'),
            actions: [
              Column(
                children: [
                  materialButton(
                    text: 'Appeal',
                    onPressed: () => _showBottomSheet(context: context),
                  ),
                  materialButton(
                    text: 'Sign out',
                    onPressed: () async {
                      await AuthServices().signOut();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Future _showBottomSheet({required BuildContext context}) async {
  final txtUserReport = TextEditingController();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            thickness: 5,
            indent: MediaQuery.of(context).size.width * 0.35,
            endIndent: MediaQuery.of(context).size.width * 0.35,
          ),
          titleText(text: "Appeal Report", fontSize: 18),
          MyTextFromField(
            labelText: "Appeal",
            hintText: "Explain the problem!",
            textEditingController: txtUserReport,
            maxLines: 5,
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: materialButton(
                  onPressed: () => _sendAppealReport(context, txtUserReport),
                  text: "Appeal",
                ),
              ),
              Expanded(
                flex: 1,
                child: materialButton(
                  onPressed: () {
                    AuthServices().signOut();
                    Navigator.pop(context);
                  },
                  text: "Cancel",
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Future _sendAppealReport(
    BuildContext context, TextEditingController txtUserReport) async {
  final user = AuthServices().fireAuth.currentUser!;
  String uid = user.uid;
  String email = user.email ?? "Unknown";
  String name = user.displayName ?? "Unknown";
  String issue = "User Ban Appeal";
  String userReport = txtUserReport.value.text;

  await ReportFunction().sendReportEmail(
    toEmail: "sanaagbook@gmail.com",
    subject: issue,
    body: "$uid\n$email\n$name\n$userReport",
  );
}
