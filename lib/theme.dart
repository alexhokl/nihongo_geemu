import 'package:flutter/material.dart';

ColorScheme getBaseColorScheme() {
  return ColorScheme.fromSeed(seedColor: Colors.teal);
}

ColorScheme getLightColorScheme() {
  final base = getBaseColorScheme();
  return base.copyWith(
    brightness: Brightness.light,
  );
}

ColorScheme getDarkColorScheme() {
  final base = getBaseColorScheme();
  return base.copyWith(
    brightness: Brightness.dark,
  );
}

ThemeData getBaseTheme() {
  return ThemeData(
    useMaterial3: true,
  );
}

ThemeData getLightTheme() {
  final base = getBaseTheme();
  return base.copyWith(
    colorScheme: getLightColorScheme(),
  );
}

ThemeData getDarkTheme() {
  final base = getBaseTheme();
  return base.copyWith(
    colorScheme: getDarkColorScheme(),
    scaffoldBackgroundColor: Colors.grey,
  );
}
