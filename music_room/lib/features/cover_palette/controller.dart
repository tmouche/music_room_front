import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/features/cover_palette/impl_repository.dart';
import 'package:music_room/features/cover_palette/provider.dart';
import 'package:music_room/features/cover_palette/state.dart';
import 'package:music_room/features/room/provider.dart';

class CoverPaletteController extends Notifier<CoverPaletteState> {
  CoverPaletteRepository get _repo => ref.read(coverPaletteRepositoryProvider);

  @override
  CoverPaletteState build() {
    final imageUrl = ref.watch(roomProvider.select((s) => s.currentRoom?.currentTrack?.imageUrl));
    if (imageUrl == null) return const CoverPaletteState();
    _extractInBackground(imageUrl);
    return (stateOrNull ?? const CoverPaletteState()).copyWith(imageUrl: imageUrl);
  }

  void  _extractInBackground(String imageUrl) {
    unawaited(_extract(imageUrl).catchError((Object e) {
      logger.debug('Fail to extract cover colors: $e');
      _applyColors(imageUrl, Coloring.defaultCover);
    }));
  }

  Future<void>  _extract(String imageUrl) async {
    final colors = await _repo.extractColors(imageUrl);
    _applyColors(imageUrl, colors);
  }

  void  _applyColors(String imageUrl, List<Color> colors) {
    if (state.imageUrl != imageUrl) return;
    state = state.copyWith(colors: colors);
  }
}
