
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/friend/controller.dart';
import 'package:music_room/features/friend/impl_repository.dart';
import 'package:music_room/features/friend/state.dart';

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepository();
});

final friendProvider = NotifierProvider<FriendController, FriendState>(
  () => FriendController(),
);
