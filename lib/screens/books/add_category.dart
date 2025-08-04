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
  final _txtCategory = TextEditingController();
  final _txtArabicName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final providerLocale =
        Provider.of<AppLocalizationsNotifier>(context, listen: true)
            .localizations;

    return ScaffoldWidget(
      appBar: AppBar(
        title: appBarText(text: providerLocale.appBarAddCategory),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildTextField(
              controller: _txtCategory,
              label: providerLocale.bodyLblCategory,
              hint: providerLocale.bodyHintCategory,
            ),
            _buildTextField(
              controller: _txtArabicName,
              label: providerLocale.bodyBookLblAr,
              hint: providerLocale.bodyBookHintAr,
            ),
            _buildAddButton(providerLocale),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return MyTextFromField(
      labelText: label,
      hintText: hint,
      textEditingController: controller,
    );
  }

  Widget _buildAddButton(dynamic providerLocale) {
    return materialButton(
      onPressed: () {
        // Add category logic here
      },
      text: providerLocale.bodyAdd,
    );
  }
}
