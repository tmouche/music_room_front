
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/room/provider.dart';
import 'package:music_room/screens/room/widgets/next_track_card.dart';
import 'package:shimmer/shimmer.dart';

class ViewExtern extends ConsumerStatefulWidget {
  const ViewExtern({
    super.key,
    required this.room
  });

  final Room room;

  @override
  ConsumerState<ViewExtern> createState() => _ViewExternState();
}

class _ViewExternState extends ConsumerState<ViewExtern> {
  bool  _isLoading = false;

  BusyNotifier get _busy => ref.read(roomBusyProvider.notifier);

  Future<void>  _onJoinRoom() async {
    setState(() {_isLoading = true;});
    final ok = await _busy.run(
      () => ref.read(roomProvider.notifier).onJoinRoom(widget.room),
      label: 'Join room failed',
    );
    setState(() {_isLoading = false;});
    if (mounted){
      if(context.canPop()) context.pop();
    }
    if (ok==false) {return;}
    if (mounted) context.go('/myRoom');
  }

  Widget  _onLoading() {
    return Shimmer.fromColors(
      baseColor: Coloring.onSurface,
      highlightColor: Coloring.roomCard.last.withValues(alpha: 0.5),
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

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(roomBusyProvider);
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: Spacing.lg),
        child: Column(
          spacing: Spacing.md,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                spacing: Spacing.md,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NextTrackCard(room: widget.room),
                  Expanded(
                    child: Container(
                    decoration: BoxDecoration(
                      color: Coloring.onSurface,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: _isLoading ? _onLoading() : TextButton(
                      onPressed: busy ? null : _onJoinRoom,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: Spacing.sm,
                        children: [
                          Icon(
                            Icons.headphones_outlined,
                            color: Coloring.surfacePrimary,
                            size: 25, fontWeight: FontWeight(500)
                          ),
                          Text(
                            'Join to listen music',
                            style: Texting.titleMiddle.copyWith(color: Coloring.surfacePrimary,
                            fontWeight: FontWeight(700))
                          )
                        ],
                      )
                    ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
