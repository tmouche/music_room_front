import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/auth/mock_repository.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/room/mock_repository.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/features/web_socket/mock_repository.dart';
import 'package:music_room/features/web_socket/provider.dart';
import 'package:music_room/my_app.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => MockAuthRepository()),
          roomRepositoryProvider.overrideWith((ref) => MockRoomRepository(ref)),
          webSocketRepositoryProvider.overrideWith((ref) => MockWebSocketRepository()),
        ],
        child: MusicRoomApp(),
      ),
    ),
  );
}