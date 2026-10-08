import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/room/provider.dart';

final roomBusyProvider = NotifierProvider.autoDispose<BusyNotifier, bool>(BusyNotifier.new);

class RoomView {
  const RoomView({required this.current, required this.myId});
  final Room? current;
  final String? myId;

  bool isListening(Room route) => current?.id == route.id;
  Room displayed(Room route) => isListening(route) ? current! : route;
  bool isOwnerOf(Room route) => displayed(route).owner == myId;
  bool get isCurrentOwner => current != null && current!.owner == myId;
}

final roomViewProvider = Provider.autoDispose<RoomView>((ref) => RoomView(
  current: ref.watch(roomProvider.select((s) => s.currentRoom)),
  myId: ref.watch(authProvider.select((s) => s.user?.id)),
));