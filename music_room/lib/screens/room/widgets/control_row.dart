import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/hifi/provider.dart';
import 'package:music_room/features/room/controller.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/room/provider.dart';

class ControlRow extends ConsumerStatefulWidget {
  const ControlRow({
    super.key,
    required this.room
  });

  final Room room;

  @override
  ConsumerState<ControlRow> createState() => _ControlRowState();
}

class _ControlRowState extends ConsumerState<ControlRow> {
  late bool _isPlaying;

  BusyNotifier get _busy => ref.read(roomBusyProvider.notifier);
  RoomController get _room => ref.read(roomProvider.notifier);
  bool get _hifiStateIsPlaying => ref.watch(hifiProvider.select((s) => s.isPlaying));

  Future<void>  _togglePlaying() async {
    if (ref.read(roomProvider).currentRoom?.currentTrack != null) {
      if (_isPlaying) {
        final ok = await _busy.run(
          () => _room.onPauseTrack(),
          label: 'Pause Track'
        );
        if (ok) setState(() => _isPlaying = false);
      } else {
        final ok = await _busy.run(
          () => _room.onResumeTrack(),
          label: 'Play Track'
        );
        if (ok) setState(() => _isPlaying = true);
      }
    }
  }

  Future<void>  _onSkipPrev() async {
    await _busy.run(
      () => _room.onRestartTrack(),
      label: 'Skip to previous'
    );
  }

  Future<void>  _onSkipNext() async {
    await _busy.run(
      () => _room.onSkipTrack(),
      label: 'Skip to next'
    );
  }


  @override
  Widget build(BuildContext context) {
    _isPlaying = _hifiStateIsPlaying;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _onSkipPrev,
          child: Icon(CupertinoIcons.backward_end, color: Coloring.onSurface, size: 32),
        ),
        TextButton(
          onPressed: _togglePlaying,
          style: TextButton.styleFrom(
            overlayColor: Colors.white.withValues(alpha: 0.1),
            shape: CircleBorder()
          ),
          child: Container(
            alignment: Alignment.center,
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: _isPlaying ?
              Icon(CupertinoIcons.pause_fill, color: Colors.black, size: 32)
              : Icon(CupertinoIcons.play_fill, color: Colors.black, size: 32)
          )
        ),
        TextButton(
          onPressed: _onSkipNext,
          child: Icon(CupertinoIcons.forward_end, color: Coloring.onSurface, size: 32),
        ),
      ],
    );
  }
}
