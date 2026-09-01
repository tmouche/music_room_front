import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';

class NoRoomPage extends StatelessWidget {
  const NoRoomPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloring.surfacePrimary,
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(Spacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: Spacing.lg,
              children: [
                RadioLogo(),
                SizedBox(
                  child: Column(
                    spacing: Spacing.sm,
                    children: [
                      Text(
                        "No active room",
                        textAlign: TextAlign.center,
                        style: Texting.titleMedium,
                      ),
                      Text(
                        "You're not in any room right now. Join a live session or start one yourself.",
                        textAlign: TextAlign.center,
                        style: Texting.bodyMedium,
                      ),
                    ],
                  )
                ),
                Column(
                  spacing: Spacing.xs,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.all(Spacing.xs),
                      decoration: BoxDecoration(
                        color: Coloring.secondary.shade400,
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: TextButton(
                        onPressed: () => context.go('/rooms'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: Spacing.sm,
                          children: [
                            Icon(Icons.disc_full, size: 23, color: Coloring.onSurface),
                            Text('Browse Rooms', style: TextStyle(fontSize: 15, color: Coloring.onSurface),)
                          ]
                        )
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ) 
      ),
    );
  }
}

class RadioLogo extends StatelessWidget {
  const RadioLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Coloring.onSurfaceVarientMuted, width: 2),
        color: Coloring.surfacePrimary,
        boxShadow: [
          BoxShadow(
            color: Coloring.primary.withValues(alpha: 0.5),
            blurRadius: 15,
            spreadRadius: 0.5,
            offset: Offset(5, 5)
          )
        ]
      ),
      child: Icon(Icons.radio_outlined, size: 45, color: Coloring.onSurfaceVarient),
    );
  }
}