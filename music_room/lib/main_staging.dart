import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/my_app.dart';
import 'package:device_preview/device_preview.dart';

void main() {
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
