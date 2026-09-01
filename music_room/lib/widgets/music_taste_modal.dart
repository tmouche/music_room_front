import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/data/music_taste.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/auth/state.dart';
import 'package:music_room/widgets/style_card.dart';

class MusicTasteModal extends ConsumerStatefulWidget {
  const MusicTasteModal({super.key});

  @override
  ConsumerState<MusicTasteModal> createState() => _MusicTasteModalState();
}


class _MusicTasteModalState extends ConsumerState<MusicTasteModal> {

  late AuthState _auth;

  void  _onStyleCardActivation(String style) {
    final newList = _auth.user!.favoriteGenres;
    newList.add(style);
    ref.read(authProvider.notifier).updateFavoriteGenres(newList);
  }

  void  _onStyleCardDeactivation(String style) {
    final newList = _auth.user!.favoriteGenres;
    newList.remove(style);
    ref.read(authProvider.notifier).updateFavoriteGenres(newList);
  }

  Widget  _buildInteractivStyleCard(String style) {
    final bool isDisable = !_auth.user!.favoriteGenres.contains(style);
    return TextButton(
      onPressed: () => isDisable ? _onStyleCardActivation(style) : _onStyleCardDeactivation(style), 
      style: TextButton.styleFrom(overlayColor: Colors.transparent),
      child: Container(
        foregroundDecoration: BoxDecoration(
          color: isDisable ? Colors.black.withValues(alpha: 0.50) : Colors.transparent,
        ),
        child: StyleCard(style: style),
      ),
    );
  }

  Widget  _buildInteractivStyleCardRow(String cardLeft, String? cardRight) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildInteractivStyleCard(cardLeft),
          if (cardRight != null) _buildInteractivStyleCard(cardRight)
        ],
      )
    );
  }


  Widget  _buildTasteList() {
    final List<String> styles = allMusicTaste.keys.toList();

    return SingleChildScrollView(
      child: Column(
        spacing: Spacing.md,
        children: [
          for (var i = 0; i < styles.length; i += 2)
            if (i + 1 < styles.length) _buildInteractivStyleCardRow(styles[i], styles[i+1]) 
            else _buildInteractivStyleCardRow(styles[i], null),
        ],
        ),
      );
  }


  @override
  Widget build(BuildContext context) {
    _auth = ref.watch(authProvider);
    return FractionallySizedBox(
      heightFactor: 0.75,
      child:  Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, Spacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          border: Border(top: BorderSide(
              color: const Color.fromARGB(255, 70, 70, 70),
            )
          ),
          color: const Color.fromARGB(255, 18, 18, 18),
        ),
        child: Column(
          spacing: Spacing.md,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Coloring.onSurfaceVarient.withValues(alpha: 0.4)
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text('Music Taste', style: Texting.titleMedium),
            ),
            Expanded(child: _buildTasteList()),
          ],
        )
      )
    ); 
  }
}