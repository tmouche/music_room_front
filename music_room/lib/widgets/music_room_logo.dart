
import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';

class MusicRoomLogo extends StatelessWidget {
  const MusicRoomLogo({
    required this.size
  });

  final double size;

  @override
  Widget  build(BuildContext context) {
    final double iconSize = size * 38 / 86;
    final double radius = size * 20 / 86;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Coloring.primary,
            Coloring.secondary,
            Coloring.tertiary,
          ]
        ),
      ),
      child: Icon(Icons.queue_music, size: iconSize, color: Colors.white),
    );
  }
}