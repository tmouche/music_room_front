import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/web_socket/controller.dart';
import 'package:music_room/features/web_socket/impl_repository.dart';
import 'package:music_room/features/web_socket/state.dart';

final webSocketRepositoryProvider = Provider<WebSocketRepository>((ref) {
  return WebSocketRepository();
});

final webSocketProvider = NotifierProvider<WebSocketController, WebSocketState>(
  () => WebSocketController(),
);
