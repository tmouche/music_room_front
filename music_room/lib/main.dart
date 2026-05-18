import 'package:flutter/material.dart';
import 'screens/log_in.dart';

void main() {
  runApp(const MusicRoomApp());
}


class MusicRoomApp extends StatelessWidget {
  const MusicRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Music Room',
      home: LogInPage(),
    );
  }
}
