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
  final _body = TextEditingController();
  String? _selected;
  static const menuItems = [
    'Help',
    'Book issue',
    'page issue',
    'problem issue',
    'Report Uploader',
  ];
  // ignore: unused_field
  final List<DropdownMenuItem<String>> _dropDownMenuItems = menuItems
      .map((String value) => DropdownMenuItem(value: value, child: Text(value)))
      .toList();

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: _selected,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selected = newValue);
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelText: providerLocale.bodyLblSelectProblemIssue,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 20.0),
                  ),
                  items:
                      menuItems.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              MyTextFromField(
                labelText: providerLocale.bodyLblDescribe,
                hintText: providerLocale.bodyHintDescribe,
                textEditingController: _body,
                isReadOnly: _selected == null ? true : false,
                maxLines: 5,
              ),
              bodyText(text: providerLocale.bodyWeSupportLanguages),
              materialButton(
                  onPressed: _selected == null
                      ? null
                      : () {
                          final uid = FirebaseAuth.instance.currentUser!.uid;
                          final email =
                              FirebaseAuth.instance.currentUser!.email!;
                          final body =
                              "${providerLocale.bodyUserReportNote + providerLocale.bodyUserID}: $uid \n\n ${providerLocale.bodyLblEmail}: $email \n\n ${_body.text}";
                          ReportFunction().sendReportEmail(
                            //toEmail: "sboapp1@gmail.com",
                            toEmail: "contactus@sboapp.so",
                            subject: _selected!,
                            body: body,
                          );
                        },
                  text: providerLocale.bodySend),
            ],
          ),
        ));
  }
}
