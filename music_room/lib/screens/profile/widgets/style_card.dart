import 'package:flutter/material.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/data/music_taste.dart';

class StyleCard extends StatelessWidget {
  const StyleCard({
    super.key,
    required this.style,
  });

  final String style;

  Widget _buildTintedImage(String imgUrl, Color color, BlendMode blendMode) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, blendMode),
      child: Image.asset(
        imgUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = allMusicTaste[style]!;
    final Color color = data["color"] as Color;
    final String imgUrl = data["img_url"] as String;

    return Container(
      width: 140,
      height: 70,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildTintedImage(imgUrl, color, BlendMode.color),
          Opacity(
            opacity: 0.5, // ajuste selon le rendu voulu (0 = que "color", 1 = que "multiply")
            child: _buildTintedImage(imgUrl, color, BlendMode.multiply),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 0.6)],
                ),
              ),
            ),
          ),
          Positioned(
            left: Spacing.sm,
            bottom: Spacing.sm,
            right: Spacing.sm,
            child: Text(
              style,
              style: Texting.titleMiddle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
