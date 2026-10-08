
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/friend.dart';
import 'package:music_room/core/model/user.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/screens/profile/provider.dart';
import 'package:music_room/screens/profile/widgets/user_logo.dart';

class FriendCard extends ConsumerStatefulWidget {
  const FriendCard({
    super.key,
    required this._friend,
  });

  final Friend _friend;

  @override
  ConsumerState<FriendCard> createState() => _FriendCardState();
}

class _FriendCardState extends ConsumerState<FriendCard> {
  BusyNotifier get _busy => ref.read(profileBusyProvider.notifier);

  Future<void>  _onAskForProfile() async {
    User? user;
    user = await _busy.fetch(
      () => ref.read(authProvider.notifier).getUser(widget._friend.friendId),
    );
    if (mounted && user != null) {
      context.push('/users/${user.id}', extra: user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(profileBusyProvider);
    return Container(
      width: 90,
      height: 160,
      padding: EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Coloring.onSurfaceVarientMuted,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            spacing: Spacing.sm,
            children: [
              UserLogo(size: 45),
              Text(
                widget._friend.username ?? "No name friend",
                style: Texting.titleMiddle,
                overflow: TextOverflow.ellipsis
              ),
            ],
          ),
          IconButton(
            onPressed: busy ? null : _onAskForProfile,
            icon: Icon(CupertinoIcons.ellipsis) 
          )
        ],
      )
    );
  }
}