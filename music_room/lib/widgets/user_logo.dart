import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';

class UserLogo extends StatelessWidget {
  const UserLogo({
    super.key,
    required this._size,  
  });

  final double _size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Coloring.onSurfaceVarientMuted, width: 1.5),
        color: Colors.white.withValues(alpha: 0.1),
      ),
      child: Icon(
        CupertinoIcons.headphones,
        size: _size / 2,
        color: Colors.white.withValues(alpha: 0.5)),
    );
  }

}