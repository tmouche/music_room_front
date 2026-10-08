import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/inbox/controller.dart';
import 'package:music_room/features/inbox/impl_repository.dart';
import 'package:music_room/features/inbox/state.dart';

final inboxRepositoryProvider = Provider<InboxRepository>((ref) {
  return InboxRepository();
});

final inboxProvider = NotifierProvider<InboxController, InboxState>(
  () => InboxController(),
);
