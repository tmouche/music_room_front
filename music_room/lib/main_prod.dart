import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/app/window_setup.dart';
import 'package:music_room/my_app.dart';

Future<void> main() async {
  await configureDesktopWindow();
  logger.init(minLevel: LogLevel.warning);
  runApp(
    const ProviderScope(
      child: MusicRoomApp()
    )
  );
}
