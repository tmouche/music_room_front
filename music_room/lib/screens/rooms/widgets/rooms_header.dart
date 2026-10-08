
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/features/friend/provider.dart';
import 'package:music_room/features/inbox/provider.dart';
import 'package:music_room/screens/rooms/widgets/create_room_modal.dart';
import 'package:music_room/screens/rooms/widgets/invitation_modal.dart';
import 'package:music_room/widgets/backgrounded_icons_button.dart';

class RoomsHeader extends ConsumerWidget {
  const RoomsHeader({super.key});

  void _showNotifications(BuildContext context, WidgetRef ref) {
    ref.read(inboxProvider.notifier).refreshInBackground();
    showModalBottomSheet(
      context: context,
      builder: (_) => InvitationModal(), 
    );
  }

  void  _createRoom(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => CreateRoomModal(),
    );
  }

  int _notificationCount(WidgetRef ref) {
    final invitationCount = ref.watch(inboxProvider.select((s) => s.invitations.length));
    final friendRequestCount = ref.watch(friendProvider.select((s) => s.pendingRequests.length));
    return invitationCount + friendRequestCount;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationCount = _notificationCount(ref);
    return Container(
      padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.md),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Coloring.surfacePrimary,
        border: BoxBorder.fromLTRB(
          bottom: BorderSide(color: Coloring.onSurfaceVarient.withValues(alpha: 0.15))
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Listen Now", style: Texting.titleLarge,),
          Row(
            spacing: Spacing.xs,
            children: [
              BackgroundedIconsButton(
                onPressed: () => _createRoom(context),
                icon: CupertinoIcons.plus,
                bgColor: Color.fromRGBO(239, 68, 68, 1),
                iconSize: 25,
                boxPadding: 5,
              ),
              Badge(
                isLabelVisible: notificationCount > 0,
                label: Text('$notificationCount'),
                child: BackgroundedIconsButton(
                  onPressed: () => _showNotifications(context, ref),
                  icon: CupertinoIcons.bell,
                  iconSize: 25,
                  boxPadding: 5,
                ),
              ),
            ],
          ),
        ],
      ) 
    );
  }
}
