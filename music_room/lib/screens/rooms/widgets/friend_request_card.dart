import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/friend.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/friend/controller.dart';
import 'package:music_room/features/friend/provider.dart';
import 'package:music_room/screens/profile/widgets/user_logo.dart';
import 'package:music_room/screens/rooms/provider.dart';

class FriendRequestCard extends ConsumerWidget {
  const FriendRequestCard({
    super.key,
    required this._friend,
  });

  final Friend _friend;

  Future<void>  _onAccept(WidgetRef ref) async {
    await _busy(ref).run(
      () => _friends(ref).acceptFriendInvite(_friend.friendId),
      label: 'Accept Friend',
    );
  }

  Future<void>  _onReject(WidgetRef ref) async {
    await _busy(ref).run(
      () => _friends(ref).rejectFriendInvite(_friend.friendId),
      label: 'Reject Friend',
    );
  }

  BusyNotifier      _busy(WidgetRef ref) => ref.read(roomsBusyProvider.notifier);
  FriendController  _friends(WidgetRef ref) => ref.read(friendProvider.notifier);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(roomsBusyProvider);
    return Container(
      padding: EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Coloring.onSurfaceVarientMuted,
      ),
      child: Row(
        spacing: Spacing.sm,
        children: [
          UserLogo(size: 45),
          Expanded(
            child: Text(
              '${_friend.username ?? 'Someone'} wants to be your friend',
              style: Texting.bodyMediumAccent,
            ),
          ),
          IconButton(
            onPressed: busy ? null : () => _onAccept(ref),
            icon: Icon(Icons.check, color: Coloring.onSurface),
          ),
          IconButton(
            onPressed: busy ? null : () => _onReject(ref),
            icon: Icon(Icons.close, color: Coloring.onSurface),
          ),
        ],
      ),
    );
  }
}
