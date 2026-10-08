import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/notification/provider.dart';
import 'package:music_room/features/cover_palette/provider.dart';
import 'package:music_room/features/hifi/provider.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/room/provider.dart';
import 'package:music_room/screens/room/widgets/room_cover.dart';
import 'package:music_room/screens/room/widgets/room_header.dart';
import 'package:music_room/screens/room/widgets/view_extern.dart';
import 'package:music_room/screens/room/widgets/view_listener.dart';
import 'package:music_room/screens/room/widgets/view_owner.dart';

class RoomPage extends ConsumerStatefulWidget {
  final Room room;

  const RoomPage({
    super.key,
    required this.room,
  });

  @override
  ConsumerState<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends ConsumerState<RoomPage>
  with SingleTickerProviderStateMixin {
  double audioVolume = 0;
  RoomView get roomView => ref.watch(roomViewProvider);

  Future<void>  _roomClosedCallback(String? message) async {
    if (message == null) return;
    ref.read(roomProvider.notifier).clearRoomClosedMessage();
    ref.read(notificationProvider.notifier).hint(
      'Room Closed',
      description: message
    );
    await ref.read(roomProvider.notifier).onRefreshRoom();
    if (mounted) if (context.canPop()) {context.pop();}
  }

  void  _playerErrorCallback(String? message) {
    if (message == null) return;
    ref.read(hifiProvider.notifier).clearPlayerErrorMessage();
    ref.read(notificationProvider.notifier).error(
      'Player Error',
      description: message
    );
  }

  Widget  _viewRoom() {
    if (!roomView.isListening(widget.room)) {
      return ViewExtern(room: widget.room);
    } else if (!roomView.isOwnerOf(widget.room)) {
      return ViewListener(room: widget.room);
    }
    return ViewOwner(room: widget.room);
  }

  List<Color> _backgroundColors() {
    final coverColors = ref.watch(coverPaletteProvider.select((s) => s.colors));
    final colors = roomView.isListening(widget.room) ? coverColors : Coloring.defaultCover;
    return colors.map((color) => color.withValues(alpha: 0.7)).toList();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(roomProvider.select((s) => s.roomClosedMessage), (_, message) => _roomClosedCallback(message));
    ref.listen(hifiProvider.select((s) => s.playerErrorMessage), (_, message) => _playerErrorCallback(message));
    final currentRoom = ref.watch(roomProvider.select((s) => s.currentRoom));
    final room = currentRoom?.id == widget.room.id ? currentRoom! : widget.room;
    return Scaffold(
      backgroundColor: Coloring.surfacePrimary,
      body: SafeArea(
        bottom: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _backgroundColors(),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, 0),
          child: Column(
            spacing: Spacing.sm,
            children: [
              RoomHeader(room: room),
              RoomCover(room: room),
              _viewRoom(),
            ],
          ),
        ),
      ),
    );
  }
}
