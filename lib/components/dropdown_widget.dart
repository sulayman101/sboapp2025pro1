import 'package:flutter/material.dart';
import 'package:sboapp/app_model/book_model.dart';

class DropDownWidget extends StatelessWidget {
  final dynamic providerLocale;
  final String? selectedValue;
  final String? hintText;
  final void Function(String?) onChange;
  final List<MyCategories> items;

  const DropDownWidget({
    super.key,
    required this.providerLocale,
    this.selectedValue,
    required this.items,
    required this.onChange,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(10),
        child: DropdownButtonFormField<String>(
          elevation: 3,
          borderRadius: BorderRadius.circular(10),
          value: selectedValue,
          hint: Text(hintText ?? providerLocale.bodyAddOrChooseCategory),
          onChanged: onChange,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            labelText: providerLocale.bodyLblCategory,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          ),
          items: items.map<DropdownMenuItem<String>>((MyCategories value) {
            return DropdownMenuItem<String>(
              value: value.category,
              child: Text(value.category),
            );
          }).toList(),
        ),
      ),
    );
  }
}
