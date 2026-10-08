import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/deep_link/controller.dart';
import 'package:music_room/features/deep_link/impl_repository.dart';

final deepLinkRepositoryProvider = Provider<DeepLinkRepository>((ref) {
  return DeepLinkRepository();
});

final deepLinkProvider = NotifierProvider<DeepLinkController, void>(
  () => DeepLinkController(),
);
