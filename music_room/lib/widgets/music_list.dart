import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/core/utils/ui_utils.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/widgets/glass_pop_menu.dart';

Future<Widget> musicSearchView(WidgetRef ref, String query) async {
  List<Track> tracks = [];

  final response = await ref.read(roomProvider.notifier).searchTrack(query);

  if (
    response.isNotEmpty
    && response['data'] != null
    && response['data']['items'] != null
  ) {
    final List<dynamic> itemsJson = response['data']['items'];
    tracks = itemsJson.map((json) => Track.fromJson(json)).toList();
  }

  return MusicList(trackList: tracks);
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

  bool _isLoading = false;

  Future<void> _onPlay() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(roomProvider.notifier).overrideCurrentTrack(widget.track);
    } on ApiException catch (e) {
      logger.debug('API Error on Play Music List Card: $e');
      if (mounted) UiUtils.showError(context, 'Play Music List Card, Server Error.');
    } catch (e) {
      logger.debug('Error on Play Music List Card: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onPlayNext() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(roomProvider.notifier).addTrackToHead(widget.track);
    } on ApiException catch (e) {
      logger.debug('API Error on PlayNext Music List Card: $e');
      if (mounted) UiUtils.showError(context, 'PlayNext Music List Card, Server Error.');
    } catch (e) {
      logger.debug('Error on PlayNext Music List Card: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onPlayLast() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(roomProvider.notifier).addTrackToQueue(widget.track);
    } on ApiException catch (e) {
      logger.debug('API Error on PlayPrev Music List Card: $e');
      if (mounted) UiUtils.showError(context, 'PlayPrev Music List Card, Server Error.');
    } catch (e) {
      logger.debug('Error on PlayPrev Music List Card: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                    GlassPopMenuItem(icon: Icons.play_arrow_outlined, label: 'Play', onTap: _isLoading ? null : _onPlay),
                    GlassPopMenuItem(icon: Icons.vertical_align_top, label: 'Play Next', onTap: _isLoading ? null : _onPlayNext),
                    GlassPopMenuItem(icon: Icons.vertical_align_bottom, label: 'Play Last', onTap: _isLoading ? null : _onPlayLast),
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
