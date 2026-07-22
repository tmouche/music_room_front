import 'package:music_room/features/web_socket/impl_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MockWebSocketRepository extends WebSocketRepository {
  MockWebSocketRepository() : super();

  @override
  WebSocketChannel? get channel => null;

  @override
  Future<void>  createChannel(String roomId, String token) async {}

  @override
  Future<void>  deleteChannel() async {}
}