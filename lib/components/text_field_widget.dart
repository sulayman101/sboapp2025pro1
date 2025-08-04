import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field2/countries.dart';
import 'package:intl_phone_field2/intl_phone_field.dart';
import 'package:intl_phone_field2/phone_number.dart';

class TextFieldWidget extends StatefulWidget {
  final String label, hint;
  final TextEditingController controller;
  final bool? isPass;
  final Icon? preIcon, eyeIcon;
  final String? Function(String?)? validation;
  final void Function(String?)? onChange;
  final Color? errorColor;
  final bool? isEnabled;

  const TextFieldWidget({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPass,
    this.preIcon,
    this.eyeIcon,
    this.validation,
    this.errorColor,
    this.onChange,
    this.isEnabled,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool isVisible = true;

  void toggleVisibility() {
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
          obscureText: widget.isPass == true ? isVisible : false,
          enabled: widget.isEnabled,
          decoration: InputDecoration(
            prefixIcon: widget.preIcon,
            labelText: widget.label,
            hintText: widget.hint,
            errorBorder: widget.errorColor != null
                ? OutlineInputBorder(
                    borderSide: BorderSide(color: widget.errorColor!),
                    borderRadius: BorderRadius.circular(15),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            suffixIcon: widget.isPass == true
                ? IconButton(
                    onPressed: toggleVisibility,
                    icon: Icon(
                      isVisible
                          ? CupertinoIcons.eye_slash_fill
                          : CupertinoIcons.eye_solid,
                    ),
                  )
                : null,
          ),
          validator: widget.validation,
          onChanged: widget.onChange,
        ),
      ),
    );
  }
}

class MyPhoneField extends StatelessWidget {
  final String labelText, hintText;
  final TextEditingController textEditingController;
  final String? Function(PhoneNumber?)? validator;
  final void Function(dynamic)? onSaved;
  final void Function(Country)? countryKey;
  final bool? isReadOnly;

  const MyPhoneField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.textEditingController,
    this.validator,
    this.onSaved,
    this.countryKey,
    this.isReadOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntlPhoneField(
        initialCountryCode: 'SO',
        readOnly: isReadOnly ?? false,
        controller: textEditingController,
        onCountryChanged: countryKey,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onSaved: onSaved,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}
