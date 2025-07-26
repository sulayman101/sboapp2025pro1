import 'package:flutter/material.dart';

class CheckBoxWidget extends StatefulWidget {
  final Widget label;
  final bool isChecked;
  // ignore: prefer_typing_uninitialized_variables
  final onChange;
  const CheckBoxWidget(
      {super.key,
      required this.label,
      required this.isChecked,
      required this.onChange});

  @override
  State<CheckBoxWidget> createState() => _CheckBoxWidgetState();
}

class _CheckBoxWidgetState extends State<CheckBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: widget.isChecked, onChanged: widget.onChange),
        widget.label,
      ],
    );
  }
}

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField(
      {super.key,
      Widget? title,
      super.onSaved,
      super.validator,
      bool super.initialValue = false,
      bool autoValidate = true})
      : super(builder: (FormFieldState<bool> state) {
          return CheckboxListTile(
            dense: state.hasError,
            title: title,
            value: state.value,
            onChanged: state.didChange,
            subtitle: state.hasError
                ? Builder(
                    builder: (BuildContext context) => Text(
                      state.errorText ?? "",
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  )
                : null,
            controlAffinity: ListTileControlAffinity.leading,
          );
        });
}
