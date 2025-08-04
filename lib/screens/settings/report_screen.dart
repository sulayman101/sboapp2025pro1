import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/text_form_field.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/reports_function.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';

class SupportUsers extends StatefulWidget {
  const SupportUsers({super.key});

  @override
  State<SupportUsers> createState() => _SupportUsersState();
}

class _SupportUsersState extends State<SupportUsers> {
  final _bodyController = TextEditingController();
  String? _selectedIssue;

  static const menuItems = [
    'Help',
    'Book issue',
    'Page issue',
    'Problem issue',
    'Report Uploader',
  ];

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;

    return ScaffoldWidget(
      appBar: AppBar(
        title: Text(providerLocale.appBarSupport),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildDropdown(providerLocale),
              _buildDescriptionField(providerLocale),
              bodyText(text: providerLocale.bodyWeSupportLanguages),
              _buildSendButton(providerLocale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(dynamic providerLocale) {
    return DropdownButtonFormField<String>(
      value: _selectedIssue,
      onChanged: (String? newValue) {
        setState(() => _selectedIssue = newValue);
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        labelText: providerLocale.bodyLblSelectProblemIssue,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 20.0,
        ),
      ),
      items: menuItems.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildDescriptionField(dynamic providerLocale) {
    return MyTextFromField(
      labelText: providerLocale.bodyLblDescribe,
      hintText: providerLocale.bodyHintDescribe,
      textEditingController: _bodyController,
      isReadOnly: _selectedIssue == null,
      maxLines: 5,
    );
  }

  Widget _buildSendButton(dynamic providerLocale) {
    return materialButton(
      onPressed: _selectedIssue == null
          ? null
          : () {
              final uid = FirebaseAuth.instance.currentUser!.uid;
              final email = FirebaseAuth.instance.currentUser!.email!;
              final body =
                  "${providerLocale.bodyUserReportNote}${providerLocale.bodyUserID}: $uid\n\n${providerLocale.bodyLblEmail}: $email\n\n${_bodyController.text}";

              ReportFunction().sendReportEmail(
                toEmail: "contactus@sboapp.so",
                subject: _selectedIssue!,
                body: body,
              );
            },
      text: providerLocale.bodySend,
    );
  }
}
