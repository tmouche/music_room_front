

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/user.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/screens/profile/widgets/music_taste_list.dart';
import 'package:music_room/screens/profile/widgets/style_card.dart';
import 'package:music_room/screens/profile/widgets/user_logo.dart';
import 'package:music_room/widgets/backgrounded_icons_button.dart';

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
  bool  _isLoading = false;
  bool  _isFriend = false;

  Future<void>  _onAdd() async {}

  Future<void>  _onRemove() async {}

  Future<void>  _onInvite() async {}

  Widget  _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (context.canPop()) BackgroundedIconsButton(
          onPressed: () => context.pop(),
          icon: CupertinoIcons.chevron_down,
          iconSize: 30,
          boxPadding: 5,
        ),
      ],
    );
  }

  Widget  __buildOption(String name, VoidCallback function) {
    return TextButton(
      onPressed: function,
      child: Container(
        padding: EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Coloring.onSurfaceVarient.shade700, width: 1),
          color: Coloring.onSurfaceVarient.shade900,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: Spacing.xs,
          children: [
            Icon(Icons.add),
            Text(name, style: Texting.titleSmall)
          ],
        ),
      ),
    );
  }

  Widget _buildNamedBox() {
    return Container(
      constraints: BoxConstraints(maxWidth: 450),
      child: Column(
        spacing: Spacing.md,
        children: [
          Container(
            padding: EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Coloring.onSurfaceVarient.shade700, width: 1),
              color: Coloring.onSurfaceVarient.shade900,
              boxShadow: [
                BoxShadow(
                  color: Coloring.primary,
                  blurRadius: 25,
                )
              ]
            ),
            child: Column(
              spacing: Spacing.sm,
              children: [
                UserLogo(size: 65),
                Text(widget.user.username, style: Texting.titleMedium),
              ]
            )
          ),
          SizedBox(
            child: Row(
              spacing: Spacing.md,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _isFriend ? _onAdd : _onRemove,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(Spacing.sm),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Coloring.primary.shade700,
                    ),
                    foregroundDecoration: BoxDecoration(
                      color: _isFriend ? Colors.black.withValues(alpha: 0.35) : Colors.transparent
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: Spacing.xs,
                      children: [
                        Icon(
                          _isFriend ? CupertinoIcons.person_badge_minus : CupertinoIcons.person_badge_plus,
                          size: 20,
                          color: Coloring.onSurface
                        ),
                        Text(
                          _isFriend ? 'Unfriend' : 'Friend',
                          style: Texting.titleMiddle
                        )
                      ],
                    ),
                  ),
                ),
                if (_isFriend) TextButton(
                  onPressed: _onInvite,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(Spacing.sm),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Coloring.tertiary.shade700,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: Spacing.xs,
                      children: [
                        Icon(Icons.my_library_music, size: 20, color: Coloring.onSurface,),
                      ],
                    ),
                  ),
                )
              ],
            )
          )
        ],
      )
    );
  }

  Widget  _buildMusicList(List<String> styles) {
    return SizedBox(
      height: 75,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: styles.length,
        separatorBuilder: (context, index) => SizedBox(width: Spacing.sm),
        itemBuilder: (context, index) => Center(child: StyleCard(style: styles[index])),
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.read(authProvider);
    final styles = authState.user!.favoriteGenres;

    return Scaffold(
      backgroundColor: Coloring.surfacePrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            spacing: Spacing.lg,
            children: [
              _buildHeader(),
              _buildNamedBox(),
              _buildMusicList(styles)
            ],
          ),
        ),
      )
    );  
  }
}