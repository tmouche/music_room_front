import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/core/utils/ui_utils.dart';
import 'package:music_room/data/music_taste.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/friend/provider.dart';
import 'package:music_room/widgets/friend_card.dart';
import 'package:music_room/widgets/music_room_logo.dart';
import 'package:music_room/widgets/music_taste_modal.dart';
import 'package:music_room/widgets/separator.dart';
import 'package:music_room/widgets/style_card.dart';
import 'package:music_room/widgets/user_logo.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isLoading = false;

  Future<void>  _onResendEmail() async {
    return ;
  }

  Future<void>  _onSubscribe() async {
    return ;
  }

  Future<void>  _onSettings() async {
    return ;
  }

  Future<void>  _onMusicTasteSettings() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MusicTasteModal()
    );
  }

  Future<void>  _onLogOut() async {
    setState(() => _isLoading = true);

    try {
      ref.read(authProvider.notifier).logout();
    } on ApiException catch (e) {
      logger.debug('API Error on logout: $e');
      if (mounted) UiUtils.showError(context, 'LogOut Failed, Server Error.');
    } catch (e) {
      logger.debug('Error logout: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

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

  Widget  __buildSubCard() {
    return Container(
      padding: EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Coloring.primary.withValues(alpha: 0.05),
      ),
      child: Row(
        spacing: Spacing.sm2,
        children: [
          Icon(Icons.diamond, size: 30, color: Coloring.tertiary,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Premium Subsciption", style: Texting.titleMiddle.copyWith(color: Coloring.tertiary)),
                Text("Subscribe to the premium version to private room", style: Texting.bodyMedium),
                TextButton(
                  onPressed: _onSubscribe,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    "Subscribe",
                    style: Texting.titleMiddle.copyWith(color: Coloring.tertiary)
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget  __buildConfirmEmail() {
    final authState = ref.read(authProvider);
    return Container(
      padding: EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Coloring.primary.withValues(alpha: 0.05),
      ),
      child: Row(
        spacing: Spacing.sm2,
        children: [
          Icon(CupertinoIcons.mail, size: 30, color: Coloring.tertiary,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Verify your email", style: Texting.titleMiddle.copyWith(color: Coloring.tertiary)),
                Text("Confirm ${authState.user!.email} to unlock rooms", style: Texting.bodyMedium),
                TextButton(
                  onPressed: _onResendEmail,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    "Resend",
                    style: Texting.titleMiddle.copyWith(color: Coloring.tertiary)
                  ),
                )
              ],
            ),
          )
        ],
      ),
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
                ],)
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
          if (!authState.user!.isEmailConfirmed) __buildConfirmEmail() else if (!authState.user!.premiumUser) __buildSubCard()
        ],
      ) 
    );
  }


  Widget  _buildMusicTasteList() {
    final authState = ref.watch(authProvider);
    final styles = authState.user!.favoriteGenres;

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
              Text("Music Tastes", style: Texting.titleMedium,),
              IconButton(
                onPressed: _onMusicTasteSettings,
                icon: Icon(CupertinoIcons.slider_horizontal_3)
              )
            ],
          ),
          SizedBox(
            height: 75,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: styles.length,
              separatorBuilder: (context, index) => SizedBox(width: Spacing.sm),
              itemBuilder: (context, index) => Center(child: StyleCard(style: styles[index])),
            ),
          ),
        ],
      ),
    );
  }

  Widget  _buildFriendList() {
    final friendsList = ref.watch(friendProvider).friends;
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
                onPressed: _onMusicTasteSettings,
                icon: Icon(CupertinoIcons.slider_horizontal_3)
              )
            ],
          ),
          SizedBox(
            height: 165,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: friendsList.length,
              separatorBuilder: (context, index) => SizedBox(width: Spacing.sm),
              itemBuilder: (context, index) => Center(child: FriendCard(friend: friendsList[index])),
            ),
          ),
        ],
      )
    );
  }

  Widget  _buildLogOut() {
    return TextButton(
      onPressed: _isLoading ? null : _onLogOut,
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
              _buildMusicTasteList(),
              _buildFriendList(),
              _buildLogOut(),
            ],
          ),
        ),
      ),
    );
  }
}

