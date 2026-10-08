import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/router/router.dart';
import 'package:music_room/features/deep_link/provider.dart';
import 'package:music_room/widgets/notification_host.dart';

class MusicRoomApp extends ConsumerWidget {
  const MusicRoomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    ref.watch(deepLinkProvider);
    return MaterialApp.router(
      routerConfig: router,
      title: 'MusicRoom',
      // App shell: window-fixed chrome (notification banner) drawn above the
      // navigator and its routes.
      builder: (context, child) => NotificationHost(child: child!),
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          surface: Colors.black,
          onSurface: Colors.white,
          onSurfaceVariant: Colors.grey,
          primary: Colors.pink,
          onPrimary: Colors.white,
          secondary: Colors.red,
          onSecondary: Colors.white,
          tertiary: Colors.orange,
          onTertiary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          outline: Colors.grey,
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 18, color: Colors.grey),
          bodyMedium: TextStyle(fontSize: 13, color: Colors.grey),
          bodySmall: TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ),
    );
  }
}