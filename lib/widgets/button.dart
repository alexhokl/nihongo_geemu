import 'package:flutter/material.dart';

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
