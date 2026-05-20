import 'package:flutter/material.dart';

TextTheme appTextTheme() {
  return const TextTheme(
    titleLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
    titleMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
    titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 18, color: Colors.grey),
    bodyMedium: TextStyle(fontSize: 13, color: Colors.grey),
    bodySmall: TextStyle(fontSize: 8, color: Colors.grey),
  );
} 