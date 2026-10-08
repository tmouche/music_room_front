import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/room/provider.dart';
import 'package:music_room/widgets/glass_pop_menu.dart';
import 'package:music_room/widgets/separator.dart';

class MusicSearch extends ConsumerStatefulWidget {
  MusicSearch({
    super.key,
    List<Track>? tracks,
  }) : _tracks = tracks ?? [];

  final List<Track> _tracks;

  @override
  ConsumerState<MusicSearch>  createState() => _MusicSearchState();
} 

class _MusicSearchState extends ConsumerState<MusicSearch> {

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      child: Column(
        spacing: Spacing.md,
        children: [
          Column(
            spacing: Spacing.xs,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text('YOUR MUSIC', style: Texting.bodyMedium,),
              ),
              separator(),
            ],
          ),
          ...widget._tracks.map(
            (toElement) => MusicSearchCard(track: toElement)
          ),
        ] 
      ),
    );
  }
}


class MusicSearchCard extends ConsumerStatefulWidget {
  final Track track;
  
  const MusicSearchCard({
    super.key,
    required this.track,
  });

  @override
  ConsumerState<MusicSearchCard> createState() => _MusicSearchCardState();
}

class _MusicSearchCardState extends ConsumerState<MusicSearchCard> {
  BusyNotifier get _busy => ref.read(roomBusyProvider.notifier);

  Future<void> _onPlay() async {
    await _busy.run(
      () => ref.read(roomProvider.notifier).onPlayNowTrack(widget.track),
      label: 'Play a track'
    );
  }

  Future<void> _onPlayNext() async {
    await _busy.run(
      () => ref.read(roomProvider.notifier).onPlayNextTrack(widget.track),
      label: 'Play next'
    );
  }

  Future<void> _onPlayLast() async {
    await _busy.run(
      () => ref.read(roomProvider.notifier).onPlayLastTrack(widget.track),
      label: 'Play last'
    );
  }

  Widget  _buildTrackCover() {
    return SizedBox(
      width: 50,
      height: 50,
      child : ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: widget.track.imageUrl != null
          ? CachedNetworkImage(
              imageUrl: widget.track.imageUrl!,
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
      );
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(roomBusyProvider);
    final isOwner = ref.watch(roomViewProvider).isCurrentOwner;
    return Row(
      spacing: Spacing.sm2,
      children: [
        _buildTrackCover(),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Coloring.onSurfaceVarient
                )
              )
              
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    spacing: Spacing.xxs,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.track.title, style: Texting.titleMiddle, overflow: TextOverflow.ellipsis),
                      Text(widget.track.artist, style: Texting.bodyMiddle, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                GlassPopMenu(
                  baseFilled: false,
                  items: [
                    if (isOwner) GlassPopMenuItem(icon: Icons.play_arrow_outlined, label: 'Play', onTap: busy ? null : _onPlay),
                    GlassPopMenuItem(icon: Icons.vertical_align_top, label: 'Play Next', onTap: busy ? null : _onPlayNext),
                    GlassPopMenuItem(icon: Icons.vertical_align_bottom, label: 'Play Last', onTap: busy ? null : _onPlayLast),
                  ]
                )
              ],
            ) 
          )
        ),
      ]
    );
  }
}