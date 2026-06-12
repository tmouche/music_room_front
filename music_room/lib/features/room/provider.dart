

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/room/controller.dart';
import 'package:music_room/features/room/state.dart';

final roomProvider = NotifierProvider<RoomController, RoomState>(
  () => RoomController(),
);
