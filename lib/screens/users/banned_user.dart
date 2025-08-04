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
                width: MediaQuery.of(context).size.width,
                child: roleAction == "Banned User"
                    ? _buildBannedUserContent(
                        context, txtUserEmail, txtUserBody)
                    : _buildDeletedUserContent(
                        context, txtUserEmail, txtUserBody),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannedUserContent(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController bodyController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset("assets/images/bannedUser.gif"),
        ),
        customText(
          text: "Your account was banned",
          color: Theme.of(context).colorScheme.error,
          fontSize: 20,
        ),
        materialButton(
          onPressed: () => _showContactUsBottomSheet(
              context, emailController, bodyController),
          text: "Contact Us",
        ),
        TextButton(
          onPressed: () => AuthServices().signOut(),
          child: buttonText(text: "Sign Out"),
        ),
      ],
    );
  }

  Widget _buildDeletedUserContent(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController bodyController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset("assets/images/deletedUser.gif"),
        ),
        customText(
          text: "Your account was deleted",
          color: Theme.of(context).colorScheme.error,
          fontSize: 20,
        ),
        materialButton(
          onPressed: () => _showContactUsBottomSheet(
              context, emailController, bodyController),
          text: "Contact Us",
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => AuthServices().deleteUser(),
          child: customText(text: "Delete", color: Colors.red[100]),
        ),
      ],
    );
  }

  void _showContactUsBottomSheet(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController bodyController) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Material(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTextFromField(
                labelText: "Email",
                hintText: "Enter your email",
                textEditingController: emailController,
              ),
              MyTextFromField(
                labelText: "Explain Issue",
                hintText: "Enter issue details",
                textEditingController: bodyController,
              ),
              materialButton(
                onPressed: () {
                  final report = ReportFunction();
                  report.sendReportEmail(
                    toEmail: emailController.value.text,
                    subject: "User Banned",
                    body:
                        "UserId: ${AuthServices().fireAuth.currentUser!.uid}\n\n${bodyController.value.text}",
                  );
                },
                text: "Send Report",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
