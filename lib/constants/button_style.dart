import 'package:flutter/material.dart';
import 'package:sboapp/constants/text_style.dart';

Widget materialButton({
  bool? loading,
  VoidCallback? onPressed,
  required String text,
  Color? color,
  Color? txtColor,
  double? height,
  double? fontSize,
  IconData? icon,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: FilledButton.tonal(
      style: FilledButton.styleFrom(
        fixedSize: height == null ? null : Size.fromHeight(height),
        backgroundColor: color,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      /*height: height,
        elevation: 3,
        color: color ?? Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),*/
      onPressed: onPressed,
      child: loading != null && loading == false
          ? CircularProgressIndicator(color: txtColor)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon == null ? const SizedBox() : Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(icon),
                ),
                buttonText(text: text, color: txtColor, fontSize: fontSize),
              ],
            ),
    ),
  );
}

TextButton outLineButton({VoidCallback? onPressed, required Widget child}) {
  return TextButton(onPressed: onPressed, child: child);
}
