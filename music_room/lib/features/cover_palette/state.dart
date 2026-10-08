import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';

class CoverPaletteState {
  const CoverPaletteState({
    this._imageUrl,
    this._colors = Coloring.defaultCover,
  });

  final String?     _imageUrl;
  final List<Color> _colors;

  String? get imageUrl => _imageUrl;
  List<Color> get colors => _colors;

  CoverPaletteState copyWith({
    String? imageUrl,
    List<Color>? colors,
  }) {
    return CoverPaletteState(
      imageUrl: imageUrl ?? _imageUrl,
      colors: colors ?? _colors,
    );
  }
}
