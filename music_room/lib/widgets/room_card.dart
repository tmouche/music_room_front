import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/room.dart';
import 'package:shimmer/shimmer.dart';

class RoomCard extends ConsumerStatefulWidget {
  const RoomCard({
    super.key,
    required this.room,
  });
  
  final Room room;

  @override
  ConsumerState<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends ConsumerState<RoomCard> { 

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero
      ),
      onPressed: () => context.pushReplacement('/rooms/${widget.room.id}', extra: widget.room),
      child: Container(
        width: double.infinity,
        height: 200,
        constraints: BoxConstraints(minHeight: 200, maxHeight: 200),
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.room.gradientColor!
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.sm,
          children: [
            Text(widget.room.name, style: Texting.titleMedium),
            Row(
              spacing: Spacing.sm,
              children: [
                Icon(Icons.people_outline, color: Coloring.onSurface, size: 18,),
                Text('${widget.room.people} listening', style: Texting.bodyMediumAccent,)
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withAlpha(150)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.xs,
                children: [Text('NOW PLAYING', style: Texting.bodyMiddle),
                Text(widget.room.currentTrack?.title ?? '...', style: Texting.titleMiddle),
                Text(widget.room.currentTrack?.artist ?? 'The owner is choosing..', style: Texting.bodyMedium,),]
              ),
            )
          ],
        ),
      )
    );
  }
}

class AddRoomCard extends StatelessWidget {
  const AddRoomCard({
    super.key,
    required this.onTap
  });

  final VoidCallback  onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        overlayColor: Colors.white.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        constraints: BoxConstraints(minHeight: 200, maxHeight: 200),
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: Coloring.onSurfaceVarientMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Container(
          width: 115,
          height: 115,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          child: Icon(Icons.add, color: Colors.grey.withValues(alpha: 0.5), size: 70),
        )
        )
      )
    );
  }
}

class LoadingRoomCard extends StatelessWidget {
  const LoadingRoomCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Coloring.onSurfaceVarient.shade800,
      highlightColor: Coloring.onSurfaceVarient.shade700,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12)
        ),
      ),
    );
  }
}