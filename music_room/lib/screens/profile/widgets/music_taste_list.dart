
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/screens/profile/widgets/music_taste_modal.dart';
import 'package:music_room/screens/profile/widgets/style_card.dart';

class MusicTasteList extends StatelessWidget {
  const MusicTasteList({
    super.key,
    required this._styles,
  });

  final List<String> _styles;

    void  _onMusicTasteSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MusicTasteModal()
    );
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => _onMusicTasteSettings(context),
                icon: Icon(CupertinoIcons.slider_horizontal_3)
              )
            ],
          ),
          if (_styles.isNotEmpty) SizedBox(
            height: 75,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _styles.length,
              separatorBuilder: (context, index) => SizedBox(width: Spacing.sm),
              itemBuilder: (context, index) => Center(child: StyleCard(style: _styles[index])),
            ),
          ) else Center(
            child: Text("Go to music tastes settings and add some!!")
          ,),
        ],
      ),
    );    
  }
}
