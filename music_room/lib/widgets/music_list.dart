import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/widgets/glass_pop_menu.dart';
import 'package:music_room/widgets/separator.dart';

Future<Widget> musicSearchView(WidgetRef ref, String query) async {
  List<Track> tracks = [];

  final response = await ref.read(roomProvider.notifier).searchTrack(query);

  if (
    response != null
    && response['data'] != null
    && response['data']['items'] != null
  ) {
    final List<dynamic> itemsJson = response['data']['items'];
    tracks = itemsJson.map((json) => Track.fromJson(json)).toList();
  }

  return MusicList(trackList: tracks);
}

class MusicSearchCard extends StatelessWidget {
  const MusicSearchCard({
    super.key,
    required this.track,
  });

  final Track track;

  Widget  _buildTrackCover() {
    return SizedBox(
      width: 50,
      height: 50,
      child : ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: track.imageUrl != null
          ? CachedNetworkImage(
              imageUrl: track.imageUrl!,
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
                Column(
                  spacing: Spacing.xxs,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track.title, style: Texting.titleMiddle, overflow: TextOverflow.ellipsis),
                    Text(track.artist, style: Texting.bodyMiddle, overflow: TextOverflow.ellipsis),
                  ],
                ),
                GlassPopMenu(
                  baseFilled: false,
                  items: [
                    GlassPopMenuItem(icon: Icons.play_arrow_outlined, label: 'Play'),
                    GlassPopMenuItem(icon: Icons.vertical_align_top, label: 'Play Next'),
                    GlassPopMenuItem(icon: Icons.vertical_align_bottom, label: 'Play Last'),
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

class MusicList extends StatelessWidget {
  const MusicList({
    super.key,
    required this.trackList,
  });

  final List<Track> trackList;

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
        child: Column(
          spacing: Spacing.md,
          children: trackList.map(
            (toElement) => MusicSearchCard(track: toElement)
          ).toList(),
        ),
    );
  }
}
