
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/features/room/provider.dart';

class SeekBar extends ConsumerStatefulWidget {

  const SeekBar({
    super.key,
  });

  @override
  ConsumerState<SeekBar> createState() => _SeekBar();
}

class _SeekBar extends ConsumerState<SeekBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration.zero);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAnchor(Duration position, bool isPlaying) {
    final total = ref.read(roomProvider).currentRoom?.currentTrack?.duration ?? Duration.zero;
    if (total == Duration.zero) return ;
    _controller.value = position.inMilliseconds / total.inMilliseconds;
    _controller.duration = total;

    if (isPlaying) {
      _controller.forward();
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(playerPositionProvider, (prev, next) {
      next.whenData((pos) => _onAnchor(pos, ref.read(roomProvider).isPlaying));
    });
    final roomState = ref.watch(roomProvider);
    final durationSec = roomState.currentRoom?.currentTrack?.duration.inSeconds ?? 0;
    final durationMin = roomState.currentRoom?.currentTrack?.duration.inMinutes ?? 0;
    if (roomState.currentRoom?.currentTrack == null) _controller.value = 0.0;
    if (!roomState.isPlaying) _controller.stop();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final displayedMs = (_controller.value * (roomState.currentRoom?.currentTrack?.duration.inMilliseconds ?? 0)).round();
        final displayedInMin = ((displayedMs / 1000 / 60).round()).toString().padLeft(2, '0');
        final displayedInSec = ((displayedMs / 1000 % 60).round()).toString().padLeft(2, '0');
        return Column(
          spacing: Spacing.xxs,
          children: [
            LinearProgressIndicator(
              value: _controller.value.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(Colors.white),
              minHeight: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$displayedInMin:$displayedInSec', style: Texting.bodyMiddle),
                Text('$durationMin:${(durationSec % 60).toString().padLeft(2, '0')}', style: Texting.bodyMiddle)
              ],
            )
          ],
        );
      }
    ); 
  }

}