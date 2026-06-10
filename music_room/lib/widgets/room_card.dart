
import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/core/model/room.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({
    super.key,
    required this.room
  });
  
  final Room room;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: Coloring.onSurfaceVarientMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(room.name),
    );
  }
}