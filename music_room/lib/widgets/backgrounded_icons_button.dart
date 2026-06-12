import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';

class BackgroundedIconsButton extends StatelessWidget {
  const BackgroundedIconsButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.bgColor = Coloring.onSurfaceVarientMuted,
    this.iconColor = Coloring.onSurface,
    this.iconSize,
    this.boxPadding,
  });

    final Color bgColor;
    final VoidCallback onPressed;
    final IconData icon;
    final Color iconColor;
    final double? iconSize;
    final double? boxPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(45)
      ),
      child: IconButton(
        iconSize: iconSize,
        padding: EdgeInsets.all(boxPadding ?? 0),
        constraints: const BoxConstraints(),
        onPressed: onPressed,
        mouseCursor: SystemMouseCursors.click,
        icon: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }
}
