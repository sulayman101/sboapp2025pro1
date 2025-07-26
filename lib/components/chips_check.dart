

import 'package:flutter/material.dart';

Widget choiceChipWidget({required String label, required bool selected, required Function(bool) onSelected}){
  return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      );
}