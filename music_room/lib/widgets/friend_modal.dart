import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/widgets/backgrounded_icons_button.dart';
import 'package:music_room/widgets/search_modal.dart';

void showFriendModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color.from(alpha: 0, red: 0, green: 0, blue: 0),
    builder: (_) => FriendModal()
  );
}

class FriendModal extends StatelessWidget{
  const FriendModal({
    super.key,
  });

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Friends', style: Texting.titleMedium),
        BackgroundedIconsButton(
          onPressed: context.pop,
          icon: Icons.close,
          iconSize: 15,
          boxPadding: 7,
        )
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
        children: [
          Expanded(
            child:  TextField(
              style: Texting.bodyMediumAccent,
              cursorColor: Coloring.onSurface,
              cursorWidth: 1,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Coloring.onSurfaceVarient.withValues(alpha: 0.30)),
                contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
                hintText: "Search friends",
                hintStyle: Texting.bodyMedium,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Coloring.borderFocused),
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Coloring.onSurfaceVarient.withValues(alpha: 0.25),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    width:  1,
                    color: Coloring.onSurfaceVarient.withValues(alpha: 0.30),
                  ),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: null,
            child: Container(
              padding: EdgeInsets.all(Spacing.md),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Coloring.primary.withValues(alpha: 0.8),
              ),
              child: Text('Search', style: Texting.bodyMediumAccent)
            )
          )
        ],
    );
  }

  Widget _buildFriendsList() {
    return Column(
      children: [
        Text('YOUR FRIENDS', style: Texting.bodyMiddle,),
        Column(
          children: []
        )
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.75, // 75%
          child: Container(
            padding: EdgeInsets.fromLTRB(Spacing.md, Spacing.lg, Spacing.md, 0),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(top: BorderSide(
                  color: const Color.fromARGB(255, 70, 70, 70),
                )
              ),
              color: const Color.fromARGB(255, 18, 18, 18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.md,
              children: [
                _buildHeaderRow(context),
                _buildSearchBar(),
                _buildFriendsList(),
              ],
            ),
          )
        ); 
  }
}