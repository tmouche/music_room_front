
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/friend.dart';
import 'package:music_room/screens/profile/widgets/user_logo.dart';

class FriendCard extends StatelessWidget {
  const FriendCard({
    super.key,
    required this._friend,
  });

  final Friend _friend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 160,
      padding: EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Coloring.onSurfaceVarientMuted,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            spacing: Spacing.sm,
            children: [
              UserLogo(size: 45),
              Text(_friend.username ?? "No name friend", style: Texting.titleMiddle, overflow: TextOverflow.ellipsis,),
            ],
          ),
          IconButton(
            onPressed: null,
            icon: Icon(CupertinoIcons.ellipsis) 
          )
        ],
      )
    );
  }
}