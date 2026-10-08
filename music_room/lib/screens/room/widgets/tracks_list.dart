import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/queue_item.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/room/provider.dart';
import 'package:music_room/screens/room/widgets/music_search.dart';
import 'package:music_room/widgets/search_modal.dart';

class TracksList extends ConsumerStatefulWidget {
  const TracksList({
    super.key,
    required this.room
  });

  final Room room;

  @override
  ConsumerState<TracksList> createState() => _TracksListState();
}

class _TracksListState extends ConsumerState<TracksList> {
  RoomView get _roomView => ref.watch(roomViewProvider);
  BusyNotifier get _busy => ref.read(roomBusyProvider.notifier);

  Future<void>  _onReorderingList(int oldPos, int newPos) async {
    await _busy.run(
      () => ref.read(roomProvider.notifier).onReorderTrack(oldPos, newPos),
      label: 'Reorder Queue'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Spacing.sm,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text('Up Next', style: Texting.titleMiddle),
                  Text('${widget.room.queue.length} songs', style: Texting.bodyMedium)
              ],
            ),
            if (_roomView.isListening(widget.room)) const AddMusicButton()
          ]
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(bottom: Spacing.sm),
                sliver: SliverReorderableList(
                  proxyDecorator: (child, index, animation) {
                    return AnimationTrackCard(animation: animation, child: child);
                  },
                  itemCount: widget.room.queue.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      key: ValueKey(widget.room.queue[index].id),
                      padding: EdgeInsets.symmetric(vertical: Spacing.sm / 2),
                      child: TrackCard(
                        index: index,
                        queueItem: widget.room.queue[index],
                        isOwner: _roomView.isOwnerOf(widget.room),
                      ),
                    );
                  },
                  onReorderItem: _onReorderingList,
                ),
              ),
            ],
          ),
        ),
      ]
    );    
  }
}


class AddMusicButton extends ConsumerWidget {
  const AddMusicButton({super.key});

  void  _onAddMusicButton(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchModal(
        topic: "Musics",
        contentBuilder: ({List<Track>? content}) => MusicSearch(tracks: content),
        toSearch: (query) => ref.read(roomProvider.notifier).onSearchTrack(query),
      )
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () => _onAddMusicButton(context, ref),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(Spacing.sm, Spacing.xs, Spacing.sm, Spacing.xs),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Coloring.onSurfaceVarientMuted,
          border: Border.all(color: Coloring.onSurfaceVarient)
        ),
        child: Row(
          spacing: Spacing.xs,
          children: [
            Icon(Icons.add, color: Coloring.onSurface, size: 10),
            Text('Add', style: Texting.titleMiddle,),
          ],
        ) 
      )
    );
  }
}


class AnimationTrackCard extends StatelessWidget {
  const AnimationTrackCard({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(animation.value);
        return Material(
          color: Colors.transparent,
          elevation: 0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -4 * t, bottom: -4 * t, left: -6, right: -6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25 * t),
                        blurRadius: 10 * t,
                        spreadRadius: 1 * t,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 15 * t,
                        sigmaY: 15 * t,
                      ),
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.05 * t),
                      ),
                    ),
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
    );
  }
}


class TrackCard extends StatelessWidget {
  const TrackCard({
    super.key,
    required this._index,
    required this._queueItem,
    required this._isOwner,
  });

  final int _index;
  final QueueItem _queueItem;
  final bool _isOwner;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            spacing: Spacing.sm,
            children: [
              SizedBox(
                width: 45, height: 45,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _queueItem.track.title,
                        style: Texting.titleMiddle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _queueItem.track.artist,
                        style: Texting.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                )
              ],
            ),
        ),
        if (_isOwner) ReorderableDragStartListener(
          index: _index,
          child: Icon(Icons.drag_handle, color: Coloring.onSurfaceVarient),
        )
      ],
    );   
  }
}