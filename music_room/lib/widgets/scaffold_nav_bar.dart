
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/app/theme/coloring.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
        selectedItemColor: Coloring.secondary,
        unselectedItemColor: Coloring.onSurfaceVarient.withValues(alpha: 0.75),
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.music_house,
              color: navigationShell.currentIndex == 0
              ? Coloring.onSurface
              : Coloring.onSurfaceVarient.withValues(alpha: 0.75)
            ),
            label: 'Listen Now'
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search,
              color: navigationShell.currentIndex == 1
              ? Coloring.onSurface
              : Coloring.onSurfaceVarient.withValues(alpha: 0.75)
            ),
            label: 'Search'
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person,
              color: navigationShell.currentIndex == 2
              ? Coloring.onSurface
              : Coloring.onSurfaceVarient.withValues(alpha: 0.75)
            ),
            label: 'Profile'
          ),
        ],
      ),
    );
  }
      
}