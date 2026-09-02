import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/core/utils/ui_utils.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/room/widgets/music_search_card.dart';
import 'package:music_room/widgets/separator.dart';

class MusicSearch extends ConsumerStatefulWidget {
  const MusicSearch({
    super.key,
    required this.query
  });

  final String query;

  @override
  ConsumerState<MusicSearch>  createState() => _MusicSearchState();
} 


class _MusicSearchState extends ConsumerState<MusicSearch> {
  bool        _isLoading = false;
  List<Track> _tracks = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant MusicSearch old) {
    super.didUpdateWidget(old);
    if (old.query != widget.query) _fetch();
  }

  Future<void>  _fetch() async {
    if (widget.query.isEmpty) {
      setState(() => _tracks = []);
      return ;
    }
    setState(() => _isLoading = true);

    try {
      final response = await ref.read(roomProvider.notifier).searchTrack(widget.query);
      final items = response['data']?['items'] as List<dynamic>? ?? [];
      if (mounted) setState(() => _tracks = items.map((j) => Track.fromJson(j)).toList());
    } on ApiException catch (e) {
      logger.debug('API Error on search: $e');
      if (mounted) UiUtils.showError(context, 'Server Error.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
          ..._tracks.map(
            (toElement) => MusicSearchCard(track: toElement)
          ),
        ] 
      ),
    );
  }
}
