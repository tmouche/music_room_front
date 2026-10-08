import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/features/hifi/provider.dart';

class VolumeRow extends ConsumerStatefulWidget {
  const VolumeRow({
    super.key,
    required this.room
  });

  final Room room;

  @override
  ConsumerState<VolumeRow> createState() => _VolumeRowState();
}

class _VolumeRowState extends ConsumerState<VolumeRow> {
  double audioVolume = 0;
  bool _isVolumeDragging = false;

  void  _onVolumeChange(double value) {
    setState(() => audioVolume = value);
    ref.read(hifiProvider.notifier).setVolume(value / 100);
  }

  @override
  Widget build(BuildContext context) {
    final hifiState = ref.watch(hifiProvider);
    if (!_isVolumeDragging) audioVolume = (hifiState.volume * 100).clamp(0.0, 100.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: _isVolumeDragging ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, t, _) {
        final iconColor = Color.lerp(Coloring.onSurfaceVarient, Coloring.onSurface, t)!;
        final iconScale = lerpDouble(1.0, 1.1, t)!;
        return Row(
          spacing: Spacing.lg,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: iconScale,
              child: Icon(CupertinoIcons.volume_mute, color: iconColor, size: 18),
            ),
            Expanded(
              child: Transform.scale(
                scaleY: lerpDouble(1.0, 1.5, t)!,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: audioVolume,
                    min: 0,
                    max:  100,
                    onChanged: (value) => _onVolumeChange(value),
                    onChangeStart: (_) => setState(() => _isVolumeDragging = true),
                    onChangeEnd: (_) => setState(() => _isVolumeDragging = false),
                    activeColor: iconColor,
                    inactiveColor: Colors.white.withValues(alpha: lerpDouble(0.2, 0.35, t)!),
                  )
                ),
              ),
            ),
            Transform.scale(
              scale: iconScale,
              child: Icon(CupertinoIcons.volume_up, color: iconColor, size: 18),
            ),
          ]
        );
      },
    );
  }
}
