import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/friend/provider.dart';
import 'package:music_room/features/inbox/provider.dart';
import 'package:music_room/screens/rooms/provider.dart';
import 'package:music_room/screens/rooms/widgets/friend_request_card.dart';
import 'package:music_room/screens/rooms/widgets/invitation_card.dart';

class InvitationModal extends ConsumerWidget {
  const InvitationModal({super.key});

  Future<void>  _onRefresh(WidgetRef ref) async {
    await _busy(ref).run(
      () => ref.read(inboxProvider.notifier).refresh(),
      label: 'Refresh Notifications',
    );
  }

  BusyNotifier  _busy(WidgetRef ref) => ref.read(roomsBusyProvider.notifier);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitations = ref.watch(inboxProvider.select((s) => s.invitations));
    final friendRequests = ref.watch(friendProvider.select((s) => s.pendingRequests));
    final busy = ref.watch(roomsBusyProvider);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Coloring.onSurfaceVarientMuted,
        borderRadius: BorderRadius.circular(25),
        border: BoxBorder.all(color: Coloring.onSurfaceVarientMuted)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.sm,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Notifications', style: Texting.titleMedium),
              IconButton(
                onPressed: busy ? null : () => _onRefresh(ref),
                icon: Icon(Icons.refresh, color: Coloring.onSurface),
              ),
            ],
          ),
          if (invitations.isEmpty && friendRequests.isEmpty)
            Text('Nothing new for now', style: Texting.bodyMedium),
          ...friendRequests.map((friend) => FriendRequestCard(friend: friend)),
          ...invitations.map((invitation) => InvitationCard(invitation: invitation)),
        ],
      ),
    );
  }
}
