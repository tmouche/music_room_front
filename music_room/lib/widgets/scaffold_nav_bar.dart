
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/core/notification/provider.dart';
import 'package:music_room/features/room/provider.dart';

class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this._navigationShell,
    required this._routerState,
  });

  final StatefulNavigationShell _navigationShell;
  final GoRouterState _routerState;

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBar();
}

class _ScaffoldWithNavBar extends ConsumerState<ScaffoldWithNavBar> {
  static final int indexListenNow = 0;
  static final int indexMyRoom = 1;
  static final int indexProfile = 2;

  void  onTap(int index) {
    if (index == indexListenNow) {
      unawaited(ref.read(roomProvider.notifier).onRefreshRoom().catchError(
        (err) {
          ref.read(notificationProvider.notifier).hint(
            'Refresh room failed',
            description: err,
          );
        }
      ));
      final openedRoomId = widget._routerState.pathParameters['id'];
      final currentRoomId = ref.read(roomProvider).currentRoom?.id;
      if (openedRoomId == currentRoomId && (openedRoomId != null || currentRoomId != null)) {
        widget._navigationShell.goBranch(indexMyRoom);
      }
      widget._navigationShell.goBranch(indexListenNow);
    }
    widget._navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget._navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget._navigationShell.currentIndex,
        onTap: onTap,
        selectedItemColor: Coloring.secondary,
        unselectedItemColor: Coloring.onSurfaceVarient.withValues(alpha: 0.75),
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.music_house,
              color: widget._navigationShell.currentIndex == indexListenNow
              ? Coloring.onSurface
              : Coloring.onSurfaceVarient.withValues(alpha: 0.75)
            ),
            label: 'Listen Now'
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.dot_radiowaves_left_right,
              color: widget._navigationShell.currentIndex == indexMyRoom
              ? Coloring.onSurface
              : Coloring.onSurfaceVarient.withValues(alpha: 0.75)
            ),
            label: 'My Room'
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person,
              color: widget._navigationShell.currentIndex == indexProfile
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