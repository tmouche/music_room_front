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

  static const onError = Colors.red;
  static const onSuccess = Colors.green;

  static const List<Color> defaultCover = [primary, secondary];
  static const List<Color> roomCard = [Color(0xFF2E3448), Color(0xFF4A3B5C)];
}
