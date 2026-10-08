import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/hifi/controller.dart';
import 'package:music_room/features/hifi/impl_repository.dart';
import 'package:music_room/features/hifi/state.dart';

final hifiRepositoryProvider = Provider<HifiRepository>((ref) {
  return HifiRepository();
});

final hifiProvider = NotifierProvider<HifiController, HifiState>(
  () => HifiController(),
);