import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/widgets/gradient_text.dart';
import 'package:music_room/widgets/music_room_logo.dart';

class LogoGlobal extends StatelessWidget {
  const LogoGlobal({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: Spacing.sm,
      children: [
        MusicRoomLogo(size: 86),
        GradientText(
          'Music Room',
          style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Coloring.primary,
              Coloring.secondary,
              Coloring.tertiary,
            ]
          )
        ),
        Text(
          'Listen Together, Anytime',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Coloring.onSurfaceVarient,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
