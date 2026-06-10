import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/my_app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MusicRoomApp()
    )
  );

}