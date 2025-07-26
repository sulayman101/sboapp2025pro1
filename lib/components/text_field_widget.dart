import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field2/countries.dart';
import 'package:intl_phone_field2/intl_phone_field.dart';

class TextFieldWidget extends StatefulWidget {
  final String label, hint;
  final TextEditingController controller;
  final bool? isPass;
  final Icon? preIcon;
  final Icon? eyeIcon;
  // ignore: prefer_typing_uninitialized_variables
  final validation;
  // ignore: prefer_typing_uninitialized_variables
  final onChange;
  final Color? errorColor;
  final bool? isEnabled;
  const TextFieldWidget(
      {super.key,
      required this.label,
      required this.hint,
      required this.controller,
      this.isPass,
      this.preIcon,
      this.eyeIcon,
      required this.validation,
      this.errorColor,
      this.onChange,
      this.isEnabled});

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool isVisible = true;

  visibilityPass() {
    setState(() {
      isVisible = !isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(20),
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.controller,
          obscureText: widget.isPass != null ? isVisible : false,
          enabled: widget.isEnabled,
          decoration: InputDecoration(
            prefixIcon: widget.preIcon,
            labelText: widget.label,
            hintText: widget.hint,
            errorBorder: widget.errorColor == null
                ? null
                : OutlineInputBorder(
                    borderSide: BorderSide(color: widget.errorColor!),
                    borderRadius: BorderRadius.circular(15),
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.green),
            ),
            suffixIcon: widget.isPass != null
                ? IconButton(
                    onPressed: visibilityPass,
                    icon: isVisible
                        ? const Icon(CupertinoIcons.eye_slash_fill)
                        : const Icon(CupertinoIcons.eye_solid))
                : null,
            // You can customize various aspects of the decoration here
          ),
          validator: widget.validation,
          onChanged: widget.onChange,
        ),
      ),
    );
  }
}

class MyPhoneField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final Function(dynamic)? onSaved;
  final bool? isSomalia;
  // ignore: prefer_typing_uninitialized_variables
  final validator;
  final Function(Country)? countryKey;
  final TextEditingController textEditingController;
  final bool? isReadOnly;
  // ignore: prefer_typing_uninitialized_variables
  final keyboardType;

  const MyPhoneField(
      {super.key,
      required this.labelText,
      required this.hintText,
      this.onSaved,
      this.validator,
      required this.textEditingController,
      this.isReadOnly,
      this.keyboardType,
      this.countryKey,
      this.isSomalia});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntlPhoneField(
        initialCountryCode: 'SO',
        readOnly: isReadOnly ?? false,
        //disableLengthCheck: true,
        keyboardType: keyboardType,
        controller: textEditingController,
        onCountryChanged: countryKey,
        decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary))),
        onSaved: onSaved,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}
