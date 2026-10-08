import 'package:collection/collection.dart';
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
import 'package:music_room/features/friend/provider.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/profile/provider.dart';
import 'package:music_room/screens/profile/widgets/music_taste_list.dart';
import 'package:music_room/screens/profile/widgets/user_logo.dart';
import 'package:music_room/widgets/backgrounded_icons_button.dart';
import 'package:music_room/widgets/separator.dart';

class OtherProfile extends ConsumerStatefulWidget {
  const OtherProfile({
    super.key,
    required this.user,
  });

  final User  user;

  @override
  ConsumerState<OtherProfile> createState() => _OtherProfileState();
}

class _OtherProfileState extends ConsumerState<OtherProfile> {
  FriendStatus  status = FriendStatus.unknown;
  
  BusyNotifier get _busy => ref.read(profileBusyProvider.notifier);

  Future<void>  _onAdd() async {
    await _busy.run(
      () => ref.read(friendProvider.notifier).addFriend(widget.user.username),
      label: "Add Friend",
    );
  }

  Future<void>  _onRemove() async {
    await _busy.run(
      () => ref.read(friendProvider.notifier).deleteFriend(widget.user.id),
      label: 'Remove Friend',
    );
  }

  Future<void>  _onInvite() async {
    final currentRoomId = ref.read(roomProvider).currentRoom!.id;
    await _busy.run(
      () => ref.read(friendProvider.notifier).inviteToRoom(currentRoomId, widget.user.id),
      label: 'Invite to Room',
    );
  }

  Future<void>  _onAccept() async {
    await _busy.run(
      () => ref.read(friendProvider.notifier).acceptFriendInvite(widget.user.id),
      label: 'Accept Friend',
    );
  }

  Future<void>  _onReject() async {
    await _busy.run(
      () => ref.read(friendProvider.notifier).rejectFriendInvite(widget.user.id),
      label: 'Reject Friend',
    );
  }

  Widget  _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: Spacing.md,
      children: [
        if (context.canPop()) BackgroundedIconsButton(
          onPressed: () => context.pop(),
          icon: CupertinoIcons.chevron_down,
          iconSize: 30,
          boxPadding: 5,
        ),
        Text(
          '@${widget.user.username}',
          style: Texting.titleMiddle.copyWith(color: Coloring.onSurfaceVarient),
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }

  Widget  _conditionalButton(
    VoidCallback?  callback,
    Icon          icon,
    Text          text,
  ) {
    return TextButton(
      onPressed: callback,
      child: Row(
        spacing: Spacing.xs,
        children: [
            icon,
            text
        ],
      )
    );
  }

  Widget _rightButton(Friend? friend) {
    final busy = ref.watch(profileBusyProvider);
    if (status == FriendStatus.friend) {
      return _conditionalButton(
        busy ? null : _onRemove,
        Icon(CupertinoIcons.person_badge_minus, color: Coloring.secondary,),
        Text('Remove', style: Texting.titleMiddle.copyWith(color: Coloring.secondary),)
      );
    } else if (status == FriendStatus.pending) {
      if (friend!.isSender) {
        return _conditionalButton(
          null,
          Icon(CupertinoIcons.scribble, color: Coloring.onSurfaceVarient,),
          Text('Request Pending', style: Texting.titleMiddle.copyWith(color: Coloring.onSurfaceVarient),)
        );
      }
      return Row(
        children: [
          _conditionalButton(
            busy ? null : _onAccept,
            Icon(CupertinoIcons.check_mark, color: Colors.green,),
            Text('Accept', style: Texting.titleMiddle.copyWith(color: Colors.green),)
          ),
          _conditionalButton(
            busy ? null : _onReject,
            Icon(CupertinoIcons.clear, color: Colors.red,),
            Text('Reject', style: Texting.titleMiddle.copyWith(color: Colors.red),)
          )
        ],
      );
    }
    return _conditionalButton(
      busy ? null : _onAdd,
      Icon(CupertinoIcons.person_add, color: Coloring.tertiary,),
      Text('Add', style: Texting.titleMiddle.copyWith(color: Coloring.tertiary),)
    );
  }

  Widget  _buildNameBox(Friend? friend) {
    return Container(
      constraints: BoxConstraints(maxWidth: 450),
      padding: EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Coloring.onSurfaceVarient.withValues(alpha: 0.15), width: 1),
        color: Coloring.surfaceVarient
      ),
      width: double.infinity,
      child: Column(
        spacing: Spacing.sm,
        children: [
          Row(
            spacing: Spacing.md,
            children: [
              UserLogo(size: 65),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.user.username, style: Texting.titleMedium),
                  if (widget.user.email != null) Text(widget.user.email!, style: Texting.bodyMedium),
                ],)
            ],
          ),
          Row(
            children: [
              Expanded(
                child: separator(),
              ),
              _rightButton(friend)
            ],
          ),
        ],
      ) 
    );
  }

  Widget  _buildInviteButton() {
    final busy = ref.watch(profileBusyProvider);
    return TextButton(
      onPressed: busy ? null : _onInvite,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: 450),
        padding: EdgeInsets.all(Spacing.sm2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Coloring.onSurfaceVarient.withValues(alpha: 0.15), width: 1),
          gradient: LinearGradient(
            colors: [
              Coloring.primary,
              Coloring.secondary,
              Coloring.tertiary,
            ]),
        ),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: Spacing.xs,
          children: [
            Icon(CupertinoIcons.double_music_note, color: Coloring.onSurface,),
            Text('Invite', style: Texting.titleMiddle)
          ],
        ),
      )
    );
  }

  Widget  _privateProfile() {
    return Container(
      constraints: BoxConstraints(maxWidth: 450),
      child: Column(
        spacing: Spacing.xs,
        children: [
          Row(
            spacing: Spacing.sm,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.lock, color: Coloring.onSurfaceVarient,),
              Text('This profile is private', style: Texting.bodyMedium,)
            ],
          ),
          Text('This person chose to not display his music taste! What can he hide ?', style: Texting.bodyMedium, textAlign: TextAlign.center,)
        ],
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    final Friend? friend = ref.watch(friendProvider).friends.firstWhereOrNull(
      (friend) => friend.friendId == widget.user.id
    );
    if (friend != null) {
      if (friend.isPending == false) {
        status = FriendStatus.friend;
      } else {status = FriendStatus.pending;}
    } else {status = FriendStatus.unknown;}
    bool private = false;
    if (
      widget.user.privacyLevel == "Private" 
      || (widget.user.privacyLevel == "Friend" && friend == null)
    ) {private = true;}
    final isCurrentInRoom = ref.read(roomProvider).currentRoom?.id != null;
    return Scaffold(
      backgroundColor: Coloring.surfacePrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            spacing: Spacing.lg,
            children: [
              _buildHeader(),
              _buildNameBox(friend),
              if (status == FriendStatus.friend && isCurrentInRoom) _buildInviteButton(),
              private ? _privateProfile() : MusicTasteList(
                styles: widget.user.favoriteGenres,
                visitor: true,
              )
            ],
          ),
        ),
      )
    );  
  }
}