import 'package:flutter/material.dart';
import 'package:sboapp/app_model/book_model.dart';

class DropDownWidget extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final providerLocale;
  final String? selectedValue;
  final String? hintText;
  // ignore: prefer_typing_uninitialized_variables
  final onChange;
  final List<MyCategories> items;

  const DropDownWidget(
      {super.key,
      this.providerLocale,
      this.selectedValue,
      required this.items,
      required this.onChange,
      this.hintText});

  @override
  State<DropDownWidget> createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
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
          value: widget.selectedValue,
          hint: Text(
              widget.hintText ?? widget.providerLocale.bodyAddOrChooseCategory),
          onChanged: widget.onChange,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            labelText: widget.providerLocale.bodyLblCategory,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          ),
          items:
              widget.items.map<DropdownMenuItem<String>>((MyCategories value) {
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
