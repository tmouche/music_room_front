
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/model/user.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/log_in/log_in.dart';
import 'package:music_room/screens/log_in/provider.dart';
import 'package:music_room/screens/no_room.dart';
import 'package:music_room/screens/profile/other_profile.dart';
import 'package:music_room/screens/profile/profile.dart';
import 'package:music_room/screens/room/room.dart';
import 'package:music_room/screens/rooms/rooms.dart';
import 'package:music_room/widgets/scaffold_nav_bar.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier(ref.read(logInViewProvider));
  final subscription = ref.listen(
    logInViewProvider,
    (_, next) => authNotifier.value = next,
  );

  final router = GoRouter(
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = authNotifier.value;
      final loggingIn = state.matchedLocation == '/login';

      if (!authState.isLogged) return loggingIn ? null : '/login';
      if (loggingIn || state.matchedLocation == '/') return '/rooms';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LogInPage()),
      GoRoute(
        path: '/users/:id',
        builder: (_, state) => OtherProfile(user: state.extra as User)
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ScaffoldWithNavBar(
          navigationShell: navigationShell,
          routerState: state,
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/rooms',
              builder: (_, _) => const RoomsPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => RoomPage(room: state.extra as Room)
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/myRoom', builder: (_, __) => const _MyRoomGate()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          ]),
        ]
      )
    ]
  );

  ref.onDispose(() {
    subscription.close();
    authNotifier.dispose();
    router.dispose();
  });

  return router;
});

class _MyRoomGate extends ConsumerWidget {
  const _MyRoomGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoom = ref.watch(roomProvider.select((s) => s.currentRoom));
    return currentRoom != null ? RoomPage(room: currentRoom) : const NoRoomPage();
  }
}