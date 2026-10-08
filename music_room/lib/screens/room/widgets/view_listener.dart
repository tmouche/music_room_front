import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/screens/room/widgets/next_track_card.dart';
import 'package:music_room/screens/room/widgets/seek_bar.dart';
import 'package:music_room/screens/room/widgets/volume_row.dart';

class ViewListener extends ConsumerStatefulWidget {
  const ViewListener({
    super.key,
    required this.room
  });

  final Room room;

  @override
  ConsumerState<ViewListener> createState() => _ViewListenerState();
}

class _ViewListenerState extends ConsumerState<ViewListener> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.only(bottom: Spacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: max(0, constraints.maxHeight - Spacing.lg),
            ),
            child: IntrinsicHeight(
              child: Column(
                spacing: Spacing.md,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RepaintBoundary(child: SeekBar()),
                  Expanded(
                    child: Column(
                      spacing: Spacing.lg,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        NextTrackCard(room: widget.room),
                        VolumeRow(room: widget.room),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}