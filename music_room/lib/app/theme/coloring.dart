import 'package:flutter/material.dart';

class Coloring {
  const Coloring();


  static const primary = Colors.pink;
  static const secondary = Colors.red;
  static const tertiary = Colors.orange;

  static const surfacePrimary = Colors.black;
  static const surfaceVarient = Color.fromARGB(255, 25, 25, 25);
  static const onSurface = Colors.white;
  static const onSurfaceVarient = Colors.grey;
  static const onSurfaceVarientMuted = Color.fromRGBO(158, 158, 158, 0.15);

  static final borderPrimary = Colors.grey;
  static final borderFocused = Colors.red.withAlpha(150);

  static final List<List<Color>> cardColors = [
    [Color(0xFFEC4899), Color(0xFFEF4444), Color(0xFFF97316)], // pink → red → orange
    [Color(0xFF3B82F6), Color(0xFF06B6D4), Color(0xFF14B8A6)], // blue → cyan → teal
    [Color(0xFFA855F7), Color(0xFFEC4899), Color(0xFFEF4444)], // purple → pink → red
    [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFFD946EF)], // indigo → purple → fuchsia
    [Color(0xFF8B5CF6), Color(0xFF6366F1), Color(0xFF3B82F6)], // violet → indigo → blue
    [Color(0xFFF97316), Color(0xFFEF4444), Color(0xFFEC4899)], // orange → red → pink
    [Color(0xFF14B8A6), Color(0xFF6366F1), Color(0xFFA855F7)], // teal → indigo → purple
  ];
}
