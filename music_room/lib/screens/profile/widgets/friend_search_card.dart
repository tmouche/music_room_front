import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/core/model/friend.dart';
import 'package:music_room/core/notification/provider.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/friend/provider.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/profile/provider.dart';
import 'package:music_room/screens/profile/widgets/user_logo.dart';
import 'package:music_room/widgets/glass_pop_menu.dart';

class FriendSearchCard extends ConsumerStatefulWidget {
  const FriendSearchCard({
    super.key,
    required this._friend,
    this._isPending = false,
  });

  final Friend  _friend;
  final bool    _isPending;

  @override
  ConsumerState<FriendSearchCard> createState() => _FriendSearchCardState();
}

class _FriendSearchCardState extends ConsumerState<FriendSearchCard> {

  BusyNotifier get _busy => ref.read(profileBusyProvider.notifier);

  Future<void>  _onAcceptFriend() async {
    await _busy.run(
      () => ref.read(friendProvider.notifier).acceptFriendInvite(widget._friend.friendId),
      label: 'Accept Friend',
    );
  }

  Future<void>  _onInviteToRoom() async {
    final currentRoomId = ref.read(roomProvider).currentRoom?.id;
    if (currentRoomId == null) {
      ref.read(notificationProvider.notifier).hint(
        'No room to invite',
        description: 'You should join a room before trying to invite someone.',
      );
      return ;
    }
    await _busy.run(
      () => ref.read(friendProvider.notifier).inviteToRoom(currentRoomId, widget._friend.friendId),
      label: 'Invite to Room',
    );
  }

  Future<void>  _onRejectFriend() async {
    await _busy.run(
      () => ref.read(friendProvider.notifier).rejectFriendInvite(widget._friend.friendId),
      label: 'Reject Friend',
    );
  }

  Future<void>  _onRemoveFriend() async {
    await _busy.run(
      () => ref.read(friendProvider.notifier).deleteFriend(widget._friend.friendId),
      label: 'Remove Friend',
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(profileBusyProvider);
    return Container(
      margin: EdgeInsets.fromLTRB(Spacing.sm, 0, Spacing.sm, 0),
      padding: EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Coloring.onSurfaceVarientMuted,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: Spacing.sm,
            children: [
              UserLogo(size: 45),
              Text(widget._friend.username!),
            ],
          ),
          GlassPopMenu(
            baseFilled: false,
            items: [
              widget._isPending ?
                GlassPopMenuItem(icon: Icons.check, label: 'Accept', onTap: busy ? null : _onAcceptFriend)
              : GlassPopMenuItem(icon: Icons.my_library_music, label: 'Invite', onTap: busy ? null : _onInviteToRoom),
              widget._isPending ?
                GlassPopMenuItem(icon: Icons.close, label: 'Reject', onTap: busy ? null : _onRejectFriend)
              : GlassPopMenuItem(icon: Icons.person_remove, label: 'Remove', onTap: busy ? null : _onRemoveFriend),
            ]
          )
        ],
      ) 
    );
  }
}