import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CoverPaletteRepository {
  CoverPaletteRepository();

  Future<List<Color>>  extractColors(String imageUrl) async {
    final scheme = await ColorScheme.fromImageProvider(
      provider: CachedNetworkImageProvider(imageUrl),
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    return [scheme.primaryContainer, scheme.secondaryContainer];
  }
}
