
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/queue_item.dart';

class TrackCard extends StatelessWidget {
  const TrackCard({
    super.key,
    required this._queueItem,
    required this._index,
  });

  final QueueItem _queueItem;
  
  final int _index;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: Spacing.sm,
            children: [
              SizedBox(
                width: 45,
                height: 45,
                child : ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: _queueItem.track.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: _queueItem.track.imageUrl!,
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
                Column(
                  children: [
                    Text(_queueItem.track.title, style: Texting.titleMiddle),
                    Text(_queueItem.track.artist, style: Texting.bodyMedium),
                  ],
                )
              ],
            ),
            ReorderableDragStartListener(
              index: _index,
              child: Icon(Icons.drag_handle, color: Coloring.onSurfaceVarient),
            )
        ],
      ),
    ) ;   
  }
}