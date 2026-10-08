import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/app/window_setup.dart';
import 'package:music_room/my_app.dart';
import 'package:device_preview/device_preview.dart';

Future<void> main() async {
  await configureDesktopWindow();
  logger.init();
  runApp(
    DevicePreview(
      enabled: true,
      builder:  (context) => ProviderScope(
        child: MusicRoomApp()
      )
    )
  );
}
