
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/log_in/log_in.dart';
import 'package:music_room/screens/no_room.dart';
import 'package:music_room/screens/profile/profile.dart';
import 'package:music_room/screens/room/room.dart';
import 'package:music_room/screens/rooms/rooms.dart';
import 'package:music_room/widgets/scaffold_nav_bar.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier(ref.read(authProvider));
  ref.listen(authProvider, (_, next) => authNotifier.value = next);

  return GoRouter(
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = authNotifier.value;
      final loggingIn = state.matchedLocation == '/login';

      if (!authState.isAuthenticated) return loggingIn ? null : '/login';
      if (loggingIn || state.matchedLocation == '/') return '/rooms';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LogInPage()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ScaffoldWithNavBar(
          navigationShell: navigationShell
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/rooms',
              builder: (_, __) => const RoomsPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => RoomPage(room: state.extra as Room)
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/myRoom', builder: (_, state) {
              final currentRoom = ref.read(roomProvider).currentRoom;
              return currentRoom != null ? RoomPage(room: currentRoom) : NoRoomPage();
            } 
          )]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          ]),
        ]
      )
    ]
  );
});