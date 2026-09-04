
import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';

class DropDownList extends StatelessWidget {
  const DropDownList({
    super.key,
    required this._title,
    required this._children,
  });

  final Widget        _title;
  final List<Widget>  _children;
  
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: _title,
      iconColor: Coloring.onSurfaceVarient,
      collapsedIconColor: Coloring.onSurface,
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.symmetric(vertical: Spacing.sm),
      initiallyExpanded: true,
      children:  [
        Column(
          spacing: Spacing.sm,
          children: _children,
        ),
      ],
    );
  }
}