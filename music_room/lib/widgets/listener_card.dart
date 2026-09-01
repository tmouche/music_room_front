import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/room_user.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/core/utils/ui_utils.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/widgets/glass_pop_menu.dart';

class ListenerCard extends ConsumerStatefulWidget {
  const ListenerCard({
    super.key,
    required this._listener,
    required this._isOwner,
    required this._amIOwner,
  });

  final RoomUser _listener;
  final bool     _isOwner;
  final bool     _amIOwner;

  @override
  ConsumerState<ListenerCard> createState() => _ListenerCardState();
}

class _ListenerCardState extends ConsumerState<ListenerCard> {

  Future<void>  _onGiveOwnership() async {
    try {
      ref.read(roomProvider.notifier).promoteToOwnerRoom(widget._listener);
    } on ApiException catch (e) {
      logger.debug('API Error on give ownership: $e');
      if (mounted) UiUtils.showError(context, 'Give Ownership Failed, Server Error.');
    } catch (e) {
      logger.debug('Error on give ownership: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: Spacing.sm,
            children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Coloring.onSurfaceVarientMuted, width: 1.5),
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  child: Icon(CupertinoIcons.headphones, color: Colors.white.withValues(alpha: 0.5)),
                ),
                Text(widget._listener.username, style: Texting.titleMiddle),
              ],
            ),
            Row(
              spacing: Spacing.sm,
              children: [
                if (widget._isOwner) Icon(CupertinoIcons.sparkles, color: Coloring.onSurface)
                else if (widget._amIOwner) GlassPopMenu(
                  items: [
                    GlassPopMenuItem(icon: CupertinoIcons.sparkles, label: 'Give Ownership', onTap: _onGiveOwnership),
                  ],
                ),
              ],
            )
        ],
      ),
    ) ;
  }
}
