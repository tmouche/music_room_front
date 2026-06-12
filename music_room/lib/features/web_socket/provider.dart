
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/web_socket/impl_repository.dart';

final webSocketRepositoryProvider = Provider<WebSocketRepository>((ref) {
  return WebSocketRepository();
});
