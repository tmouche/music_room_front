import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/room/controller.dart';
import 'package:music_room/features/room/impl_repository.dart';
import 'package:music_room/features/room/state.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepository();
});

final roomProvider = NotifierProvider<RoomController, RoomState>(
  () => RoomController(),
);

final playerPositionProvider = StreamProvider<Duration>((ref) {
  final repo = ref.watch(roomRepositoryProvider);
  return repo.positionStream;
});

