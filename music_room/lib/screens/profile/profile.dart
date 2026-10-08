import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/notification/notification.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/friend/provider.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/profile/provider.dart';
import 'package:music_room/screens/profile/widgets/confirm_email_card.dart';
import 'package:music_room/screens/profile/widgets/friend_card.dart';
import 'package:music_room/screens/profile/widgets/friend_search.dart';
import 'package:music_room/screens/profile/widgets/music_taste_list.dart';
import 'package:music_room/screens/profile/widgets/profile_settings_modal.dart';
import 'package:music_room/screens/profile/widgets/subscription_card.dart';
import 'package:music_room/widgets/music_room_logo.dart';
import 'package:music_room/widgets/search_modal.dart';
import 'package:music_room/widgets/separator.dart';
import 'package:music_room/screens/profile/widgets/user_logo.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  BusyNotifier get _busy => ref.read(profileBusyProvider.notifier);

  void  _onSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProfileSettingsModal()
    );
  }

  void  _onFriendsSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SearchModal(
        topic: "Friends",
        contentBuilder: ({String? content}) => FriendSearch(query: content),
      )
    );
  }

  Future<void>  _onLogOut() async {
    await _busy.run(() => ref.read(roomProvider.notifier).onLeaveRoom());
    await _busy.run(() => ref.read(authProvider.notifier).logout(),
      label: 'LogOut',
      apiErrorKind: NotificationKind.error
    );
    return ;
  }

  Widget  _buildHeader() {
    return Row(
      spacing: Spacing.md,
      children: [
        MusicRoomLogo(size: 35),
        Text("MusicRoom Account", style: Texting.titleMiddle,)
      ],
    );
  }

  Widget  _buildNameBox() {
    final authState = ref.read(authProvider);
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
        spacing: Spacing.md,
        children: [
          Row(
            spacing: Spacing.md,
            children: [
              UserLogo(size: 65),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(authState.user!.username, style: Texting.titleMedium),
                  Text(authState.user!.email!, style: Texting.bodyMedium),
                ],
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: separator(),
              ),
              TextButton(
                onPressed: _onSettings,
                child: Row(
                  spacing: Spacing.xs,
                  children: [
                    Icon(CupertinoIcons.settings, color: Coloring.onSurfaceVarient,),
                    Text('Settings', style: Texting.titleMiddle.copyWith(color: Coloring.onSurfaceVarient),)
                  ],
                )
              )
            ],
          ),
          if (!authState.user!.isEmailConfirmed) ConfirmEmailCard() else if (!authState.user!.premiumUser) SubscriptionCard()
        ],
      ) 
    );
  }

  Widget  _buildFriendList() {
    final friendsList = ref.watch(friendProvider).acceptedFriends;
    return Container(
      padding: EdgeInsets.all(Spacing.sm2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Coloring.onSurfaceVarient.withValues(alpha: 0.15), width: 1),
        color: Coloring.surfaceVarient
      ),
      width: double.infinity,
      child: Column(
        spacing: Spacing.sm,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Friends", style: Texting.titleMedium,),
              IconButton(
                onPressed: _onFriendsSettings,
                icon: Icon(CupertinoIcons.slider_horizontal_3)
              )
            ],
          ),
          if (friendsList.isNotEmpty) SizedBox(
            height: 165,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: friendsList.length,
              separatorBuilder: (context, index) => SizedBox(width: Spacing.sm),
              itemBuilder: (context, index) => Center(child: FriendCard(friend: friendsList[index])),
            ),
          ) else Center(
            child: Text("You currently do not have friend but don't worry you can join a room and make some.")
          ,),
        ],
      )
    );
  }

  Widget  _buildLogOut() {
    final busy = ref.watch(profileBusyProvider);
    return TextButton(
      onPressed: busy ? null : _onLogOut,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: Spacing.sm,
        children: [
          Icon(Icons.exit_to_app, color: Coloring.secondary, size: 20),
          Text('Log Out', style: Texting.titleMiddle.copyWith(color: Coloring.secondary))
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final styles = ref.watch(authProvider.select((s) => s.user?.favoriteGenres));
    if (styles == null) return SizedBox.shrink();
    return Scaffold(
      backgroundColor: Coloring.surfacePrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            spacing: Spacing.lg,
            children: [
              _buildHeader(),
              _buildNameBox(),
              MusicTasteList(styles: styles),
              _buildFriendList(),
              _buildLogOut(),
            ],
          ),
        ),
      ),
    );
  }
}

