import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/log_in.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    const ProviderScope(
      child: MusicRoomApp(),
    )
  );
}

class MusicRoomApp extends StatelessWidget {
  const MusicRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Room',
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
      navigatorKey: navigatorKey,
      home: LogInPage()
    );
  }
}
