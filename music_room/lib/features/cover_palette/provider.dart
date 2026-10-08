import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/cover_palette/controller.dart';
import 'package:music_room/features/cover_palette/impl_repository.dart';
import 'package:music_room/features/cover_palette/state.dart';

final coverPaletteRepositoryProvider = Provider<CoverPaletteRepository>((ref) {
  return CoverPaletteRepository();
});

final coverPaletteProvider = NotifierProvider<CoverPaletteController, CoverPaletteState>(
  () => CoverPaletteController(),
);
