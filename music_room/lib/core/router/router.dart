
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/screens/log_in.dart';
import 'package:music_room/screens/rooms.dart';
import 'package:music_room/widgets/scaffold_nav_bar.dart';
import 'package:music_room/widgets/underConstruction.dart';

final routerProvider = Provider((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    redirect: (context, state) {
      if (!authState.isAuthenticated) return '/login';
      if (state.matchedLocation == '/') return '/rooms';
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
            GoRoute(path: '/rooms', builder: (_, __) => const RoomsPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/search', builder: (_, __) => const UnderConstructionPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const UnderConstructionPage()),
          ]),
        ]
      )
    ]
  );
});