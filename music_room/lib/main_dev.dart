import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/auth/mock_repository.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/my_app.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => ProviderScope(
        overrides: [
          authProvider.overrideWith(() => MockAuthController()),
        ],
        child: MusicRoomApp(),
      ),
    ),
  );
}