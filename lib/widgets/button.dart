import 'package:flutter/material.dart';

List<ButtonSegment<String>> createButtonSegments(List<String> labels) {
  return List.generate(labels.length, (index) {
    return ButtonSegment<String>(
      value: labels[index],
      tooltip: labels[index],
      label: Text(labels[index]),
      enabled: true,
    );
  });
}

Stack getButtonStack(List<FloatingActionButton> floatingButtons) {
  return Stack(
    children: floatingButtons
        .map((button) => Positioned(
              right: 16,
              bottom: 16.0 + 64.0 * floatingButtons.indexOf(button),
              child: button,
            ))
        .toList(),
  );
}
