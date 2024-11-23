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
