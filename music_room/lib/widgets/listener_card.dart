import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/room_user.dart';
import 'package:music_room/widgets/glass_pop_menu.dart';

class ListenerCard extends StatelessWidget {
  const ListenerCard({
    super.key,
    required this._listener,
    required this._isOwner,
  });

  final RoomUser _listener;
  final bool     _isOwner;

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
                Text(_listener.username, style: Texting.titleMiddle),
              ],
            ),
            Row(
              spacing: Spacing.sm,
              children: [
                if (_isOwner) Icon(CupertinoIcons.sparkles, color: Coloring.onSurface)
                else  GlassPopMenu(
                  items: [
                    GlassPopMenuItem(icon: CupertinoIcons.sparkles, label: 'Give Ownership'),
                  ],
                ),
              ],
            )
        ],
      ),
    ) ;
  }
}
