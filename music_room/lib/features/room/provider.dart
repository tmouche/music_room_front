

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/model/room.dart';

final roomsProvider = FutureProvider<List<Room>>((ref) async {
  return ref.watch(roomRepositoryProvider).getRooms();
});
