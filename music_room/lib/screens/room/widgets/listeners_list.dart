import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/model/room_user.dart';
import 'package:music_room/core/model/user.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/profile/widgets/friend_search.dart';
import 'package:music_room/screens/room/provider.dart';
import 'package:music_room/widgets/glass_pop_menu.dart';
import 'package:music_room/widgets/search_modal.dart';

class ListenersList extends ConsumerStatefulWidget {
  const ListenersList({
    super.key,
    required this.room
  });

  final Room room;

  @override
  ConsumerState<ListenersList> createState() => _ListenersListState();
}

class _ListenersListState extends ConsumerState<ListenersList> {
  RoomView get roomView => ref.watch(roomViewProvider);

  @override
  Widget build(BuildContext context) {
    final myId = ref.watch(authProvider.select((s) => s.user?.id));
    return Column(
      spacing: Spacing.sm,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text('User List', style: Texting.titleMiddle),
                  Text(
                    '${widget.room.people} ${widget.room.people == 1 ? 'listener' : 'listeners'}',
                    style: Texting.bodyMedium
                  )
              ],
            ),
            if (roomView.isOwnerOf(widget.room)) const InviteButton()
          ]
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              spacing: Spacing.md,
              children: widget.room.listeners.map(
                (toElement) => ListenerCard(
                  listener: toElement,
                  isOwner: toElement.id == widget.room.owner,
                  amIOwner: roomView.isOwnerOf(widget.room),
                  isMe: toElement.id == myId,
                )
              ).toList(),
            )
          )
        )
      ],
    );
  }
}


class InviteButton extends StatelessWidget {
  const InviteButton({super.key});

  void  _onInviteButton(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchModal(
        topic: "Friends",
        contentBuilder: ({String? content}) => FriendSearch(query: content),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return  TextButton(
      onPressed: () => _onInviteButton(context),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(Spacing.sm, Spacing.xs, Spacing.sm, Spacing.xs),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Coloring.onSurfaceVarientMuted,
          border: Border.all(color: Coloring.onSurfaceVarient)
        ),
        child: Row(
          spacing: Spacing.xs,
          children: [
            Icon(Icons.add, color: Coloring.onSurface, size: 10),
            Text('Invite', style: Texting.titleMiddle,),
          ],
        ) 
      )
    );  
  }
}


class ListenerCard extends ConsumerStatefulWidget {
  const ListenerCard({
    super.key,
    required this._listener,
    required this._isOwner,
    required this._amIOwner,
    required this._isMe,
  });

  final RoomUser _listener;
  final bool     _isOwner;
  final bool     _amIOwner;
  final bool     _isMe;

  @override
  ConsumerState<ListenerCard> createState() => _ListenerCardState();
}

class _ListenerCardState extends ConsumerState<ListenerCard> {
  BusyNotifier get _busy => ref.read(roomBusyProvider.notifier); 

  Future<void>  _onGiveOwnership() async {
    await _busy.run(
      () => ref.read(roomProvider.notifier).onPromoteToOwnerRoom(widget._listener),
      label: 'Promote to owner.'
    );
  }

  Future<void>  _onAskForProfile() async {
    User? user;
    user = await _busy.fetch(
      () => ref.read(authProvider.notifier).getUser(widget._listener.id),
    );
    if (mounted && user != null) {
      context.push('/users/${user.id}', extra: user);
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
                if (widget._isOwner) Icon(CupertinoIcons.sparkles, color: Coloring.onSurface),
                if (!widget._isMe) GlassPopMenu(
                  baseFilled: false,
                  items: [
                    if (widget._amIOwner) GlassPopMenuItem(icon: CupertinoIcons.sparkles, label: 'Give Ownership', onTap: _onGiveOwnership),
                    GlassPopMenuItem(icon: CupertinoIcons.person, label: 'Profile', onTap: _onAskForProfile),
                  ],
                ),                    
              ],
            )
        ],
      ),
    ) ;
  }
}