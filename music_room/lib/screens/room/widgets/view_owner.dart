import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/screens/room/widgets/control_row.dart';
import 'package:music_room/screens/room/widgets/seek_bar.dart';
import 'package:music_room/screens/room/widgets/volume_row.dart';

class ViewOwner extends StatelessWidget {
  const ViewOwner({
    super.key,
    required this.room,
  });

  final Room  room;

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RepaintBoundary(child: SeekBar()),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ControlRow(room: room),
                        VolumeRow(room: room),
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
