import 'package:flutter/material.dart';

ColorScheme appColorSheme() {
  return const ColorScheme(
    brightness: Brightness.dark,
    surface: Colors.black,
    onSurface: Colors.white,
    onSurfaceVariant: Colors.grey,
    primary: Colors.pink,
    onPrimary: Colors.white,
    secondary: Colors.red,
    onSecondary: Colors.white,
    tertiary: Colors.orange,
    onTertiary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    outline: Colors.grey,
  );
}