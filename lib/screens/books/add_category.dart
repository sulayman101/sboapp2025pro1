import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sboapp/components/ads_and_net.dart';
import 'package:sboapp/constants/button_style.dart';
import 'package:sboapp/constants/text_form_field.dart';
import 'package:sboapp/constants/text_style.dart';
import 'package:sboapp/services/lan_services/language_provider.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final _txtCat = TextEditingController();
  final _txtCaver = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;
    return ScaffoldWidget(
        appBar: AppBar(
          title: appBarText(text: providerLocale.appBarAddCategory),
        ),
        body: Column(
          children: [
            MyTextFromField(
                labelText: providerLocale.bodyLblCategory,
                hintText: providerLocale.bodyHintCategory,
                textEditingController: _txtCat),
            MyTextFromField(
                labelText: providerLocale.bodyBookLblAr,
                hintText: providerLocale.bodyBookHintAr,
                textEditingController: _txtCaver),
            materialButton(onPressed: () {}, text: providerLocale.bodyAdd),
          ],
        ));
  }
}
