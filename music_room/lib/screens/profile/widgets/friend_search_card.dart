import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/core/model/friend.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/core/utils/ui_utils.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/friend/provider.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/profile/widgets/user_logo.dart';
import 'package:music_room/screens/room/widgets/glass_pop_menu.dart';

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
  bool  _isLoading = false;

  Future<void>  _onAcceptFriend() async {
    setState(() => _isLoading = true);

    try {
      ref.read(friendProvider.notifier).acceptFriendInvite(widget._friend.friendId);
    } on ApiException catch (e) {
      logger.debug('API Error on reset password: $e');
      if (mounted) UiUtils.showError(context, 'Reset Password Failed, Server Error.');
    } catch (e) {
      logger.debug('Error on reset password: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void>  _onInviteToRoom() async {
    setState(() => _isLoading = true);

    try {
      final roomId = ref.read(roomProvider).currentRoom?.id;
      if (roomId != null) {
        ref.read(friendProvider.notifier).inviteToRoom(roomId, widget._friend.friendId);
      } else {
        logger.debug('User not in Room');
        if (mounted) UiUtils.showError(context, 'Join a room before invite someone else');
      }
    } on ApiException catch (e) {
      logger.debug('API Error on reset password: $e');
      if (mounted) UiUtils.showError(context, 'Reset Password Failed, Server Error.');
    } catch (e) {
      logger.debug('Error on reset password: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void>  _onRejectFriend() async {
    setState(() => _isLoading = true);

    try {
      ref.read(friendProvider.notifier).rejectFriendInvite(widget._friend.friendId);
    } on ApiException catch (e) {
      logger.debug('API Error on reset password: $e');
      if (mounted) UiUtils.showError(context, 'Reset Password Failed, Server Error.');
    } catch (e) {
      logger.debug('Error on reset password: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void>  _onRemoveFriend() async {
    setState(() => _isLoading = true);

    try {
      ref.read(friendProvider.notifier).deleteFriend(widget._friend.friendId);
    } on ApiException catch (e) {
      logger.debug('API Error on reset password: $e');
      if (mounted) UiUtils.showError(context, 'Reset Password Failed, Server Error.');
    } catch (e) {
      logger.debug('Error on reset password: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
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
                GlassPopMenuItem(icon: Icons.check, label: 'Accept', onTap: _isLoading ? null : _onAcceptFriend)
              : GlassPopMenuItem(icon: Icons.my_library_music, label: 'Invite', onTap: _isLoading ? null : _onInviteToRoom),
              widget._isPending ?
                GlassPopMenuItem(icon: Icons.close, label: 'Reject', onTap: _isLoading ? null : _onRejectFriend)
              : GlassPopMenuItem(icon: Icons.person_remove, label: 'Remove', onTap: _isLoading ? null : _onRemoveFriend),
            ]
          )
        ],
      ) 
    );
  }
}