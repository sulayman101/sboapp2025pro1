import 'package:flutter/material.dart';

class MyTextFromField extends StatefulWidget {
  final Widget? prefixIcon;
  final String labelText;
  final String hintText;
  final bool? obscureText;
  // ignore: prefer_typing_uninitialized_variables
  final onSaved;
  // ignore: prefer_typing_uninitialized_variables
  final validator;
  // ignore: prefer_typing_uninitialized_variables
  final onChange;
  final TextEditingController textEditingController;
  final bool? isReadOnly;
  final int? maxLines;
  final int? maxLength;
  // ignore: prefer_typing_uninitialized_variables
  final keyboardType;
  final Widget? suffixIcon;

  const MyTextFromField(
      {super.key,
      this.prefixIcon,
      this.onChange,
      required this.labelText,
      required this.hintText,
      this.onSaved,
      this.validator,
      this.obscureText,
      required this.textEditingController,
      this.keyboardType,
      this.isReadOnly,
      this.maxLines,
      this.maxLength,
      this.suffixIcon,  bool? enabled});

  @override
  State<MyTextFromField> createState() => _MyTextFromFieldState();
}

class _MyTextFromFieldState extends State<MyTextFromField> {
  bool visible = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 3,
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          readOnly: widget.isReadOnly ?? false,
          minLines: 1,
          maxLines: widget.maxLines ?? 1,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          controller: widget.textEditingController,
          decoration: InputDecoration(
              prefixIcon: widget.prefixIcon,
              labelText: widget.labelText,
              hintText: widget.hintText,
              suffixIcon: widget.obscureText != null
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          visible = !visible;
                        });
                      },
                      icon: Icon(
                          visible ? Icons.visibility_off : Icons.visibility))
                  : widget.suffixIcon,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onPrimary))),
          obscureText: widget.obscureText == null ? false : visible,
          onSaved: widget.onSaved,
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ),
    );
  }
}
