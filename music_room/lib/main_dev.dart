import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/auth/mock_repository.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/cover_palette/mock_repository.dart';
import 'package:music_room/features/cover_palette/provider.dart';
import 'package:music_room/features/deep_link/mock_repository.dart';
import 'package:music_room/features/deep_link/provider.dart';
import 'package:music_room/features/friend/mock_repository.dart';
import 'package:music_room/features/friend/provider.dart';
import 'package:music_room/features/inbox/mock_repository.dart';
import 'package:music_room/features/inbox/provider.dart';
import 'package:music_room/features/room/mock_repository.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/app/window_setup.dart';
import 'package:music_room/my_app.dart';
import 'package:device_preview/device_preview.dart';

Future<void> main() async {
  await configureDesktopWindow();
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => MockAuthRepository()),
          roomRepositoryProvider.overrideWith((ref) => MockRoomRepository(ref)),
          friendRepositoryProvider.overrideWith((ref) => MockFriendRepository()),
          inboxRepositoryProvider.overrideWith((ref) => MockInboxRepository()),
          deepLinkRepositoryProvider.overrideWith((ref) => MockDeepLinkRepository()),
          coverPaletteRepositoryProvider.overrideWith((ref) => MockCoverPaletteRepository()),
        ],
        child: MusicRoomApp(),
      ),
    ),
  );
}