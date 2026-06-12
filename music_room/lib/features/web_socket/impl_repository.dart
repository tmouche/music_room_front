import 'dart:async';

import 'package:music_room/core/network/api_client.dart';
import 'package:music_room/core/network/api_path.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketRepository {
  WebSocketRepository({
    this._channel,
  });

  WebSocketChannel? _channel;

  WebSocketChannel? get channel => _channel;

  Future<void>  createChannel(String roomId, String token) async {
    final baseUrl = '${ApiClient.baseUrl.replaceFirst('http', 'ws')}${ApiPath.roomsWebSocket(roomId)})';

    _channel = IOWebSocketChannel.connect(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void>  deleteChannel() async {
    await _channel?.sink.close();
    _channel = null;
  }
}