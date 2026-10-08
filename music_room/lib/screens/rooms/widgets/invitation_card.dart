import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/invitation.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/inbox/controller.dart';
import 'package:music_room/features/inbox/provider.dart';
import 'package:music_room/screens/profile/widgets/user_logo.dart';
import 'package:music_room/screens/rooms/provider.dart';

class InvitationCard extends ConsumerWidget {
  const InvitationCard({
    super.key,
    required this._invitation,
  });

  final Invitation _invitation;

  Future<void>  _onAccept(WidgetRef ref) async {
    await _busy(ref).run(
      () => _inbox(ref).acceptInvitation(_invitation),
      label: 'Accept Invitation',
    );
  }

  Future<void>  _onReject(WidgetRef ref) async {
    await _busy(ref).run(
      () => _inbox(ref).rejectInvitation(_invitation),
      label: 'Reject Invitation',
    );
  }

  BusyNotifier    _busy(WidgetRef ref) => ref.read(roomsBusyProvider.notifier);
  InboxController _inbox(WidgetRef ref) => ref.read(inboxProvider.notifier);

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
              '${_invitation.inviterUsername ?? 'Someone'} invited you to a room',
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
