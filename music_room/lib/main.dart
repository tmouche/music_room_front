import 'package:flutter/material.dart';

void main() {
  runApp(const MusicRoomApp());
}


class MusicRoomApp extends StatelessWidget {
  const MusicRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Music Room',
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
