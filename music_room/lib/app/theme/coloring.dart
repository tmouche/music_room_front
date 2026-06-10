import 'package:flutter/material.dart';

class Coloring {
  const Coloring();


  static const primary = Colors.pink;
  static const secondary = Colors.red;

  static const surfacePrimary = Colors.black;
  static const onSurface = Colors.white;
  static const onSurfaceVarient = Colors.grey;
  static const onSurfaceVarientMuted = Color.fromRGBO(158, 158, 158, 0.15);

  static final borderPrimary = Colors.grey;
  static final borderFocused = Colors.red.withAlpha(150);
}

// @immutable
// class AppColors extends ThemeExtension<AppColors> {
//   const AppColors({
//     required this.brandPrimary,
//     required this.brandSecondary,
//     required this.brandTertiary,
//     required this.onBrand,
//     required this.surface,
//     required this.onSurface,
//     required this.onSurfaceMuted,
//   })
// }