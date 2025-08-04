import 'package:flutter/material.dart';

class CheckBoxWidget extends StatelessWidget {
  final Widget label;
  final bool isChecked;
  final ValueChanged<bool?> onChange;

  const CheckBoxWidget({
    super.key,
    required this.label,
    required this.isChecked,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: isChecked, onChanged: onChange),
        label,
      ],
    );
  }
}

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    super.key,
    Widget? title,
    super.onSaved,
    super.validator,
    bool initialValue = false,
  }) : super(
          initialValue: initialValue,
          builder: (state) {
            return CheckboxListTile(
              dense: state.hasError,
              title: title,
              value: state.value,
              onChanged: state.didChange,
              subtitle: state.hasError
                  ? Text(
                      state.errorText ?? "",
                      style: TextStyle(
                          color: Theme.of(state.context).colorScheme.error),
                    )
                  : null,
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        );
}
