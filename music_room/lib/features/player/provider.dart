import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/player/controller.dart';
import 'package:music_room/features/player/impl_repository.dart';
import 'package:music_room/features/player/state.dart';

final audioPlayerRepositoryProvider = Provider<AudioPlayerRepository>((ref) {
  return AudioPlayerRepository();
});

final audioPlayerProvider = NotifierProvider<AudioPlayerController, AudioPlayerState>(
  () => AudioPlayerController(),
);
