import 'package:flutter/material.dart';

ToggleButtons createToggleButtons(List<String> labels, List<bool> isSelected, Function(int) onPressed) {
  if (labels.length != isSelected.length) {
    throw Exception('The length of labels and isSelected must be the same');
  }
  return ToggleButtons(
    isSelected: isSelected,
    borderRadius: BorderRadius.circular(8.0),
    onPressed: onPressed,
    children: labels.map((level) => Text(level)).toList(),
  );
}
