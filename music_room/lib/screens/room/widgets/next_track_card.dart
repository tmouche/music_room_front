
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/room.dart';

class NextTrackCard extends StatelessWidget {
  const NextTrackCard({
    super.key,
    required this.room,
  });

  final Room  room; 

  @override
  Widget build(BuildContext context) {
    final nextTrack = room.queue.firstOrNull?.track;
    return Container(
      padding: EdgeInsets.all(Spacing.sm2),
      decoration: BoxDecoration(
        color: Coloring.onSurface.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20), width: 1),
      ),
      child: Row(
        spacing: Spacing.md,
        children: [
          SizedBox(
            width: 55,
            height: 55,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: nextTrack?.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: nextTrack!.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Coloring.primary, Coloring.secondary],
                        ),
                      ),
                    ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 0,
              children: [
                Text('UP NEXT', style: Texting.bodyMiddleTrans),
                Text(
                  nextTrack?.title ?? 'Nothing queued',
                  style: Texting.bodyLarge.copyWith(color: Coloring.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  nextTrack?.artist ?? '...',
                  style: Texting.bodyMiddleTrans,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          )
        ],
      ) 
    );
  }
}
