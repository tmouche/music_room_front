import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/features/web_socket/impl_repository.dart';
import 'package:music_room/features/web_socket/provider.dart';
import 'package:music_room/features/web_socket/state.dart';

class WebSocketController extends Notifier<WebSocketState> {
  static const String _eventRoomState = 'RoomState';
  static const String _eventUserState = 'UserState';
  static const String _eventRoomClosed = 'RoomClosed';
  static const String _eventPlay = 'Play';
  static const String _eventPause = 'Pause';
  static const String _eventSeekTo = 'SeekTo';
  static const String _eventNextTrack = 'NextTrack';

  @override
  WebSocketState  build() {
    _repo = ref.read(webSocketRepositoryProvider);

    ref.onDispose(() async {
      await _repo.deleteChannel();
      await _subscription?.cancel();
    });

    return WebSocketState();
  }

  late final WebSocketRepository  _repo;
  StreamSubscription?             _subscription;

  Future<void>  connect(String roomId) async {
    await disconnect();

    final token = ref.read(authProvider).token;
    if (token == null) return ;

    try {
      _repo.createChannel(roomId, token);
      _subscription = _repo.channel!.stream.listen(
        _onMessage,
        onError: (err) => logger.error('WebSocker error', error: err),
        onDone: () {
          state = state.copyWith(isConnected: false);
        },
      );
      state = state.copyWith(isConnected: true);
    } catch (e) {
      logger.error('Failed to connect to WebSocket', error: e);
      state = state.copyWith(isConnected: false);
    }
  }

  Future<void>  disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _repo.deleteChannel();
    state = state.copyWith(isConnected: false);
  }

  void  send(String eventType, Map<String, dynamic> payload) {
    if (_repo.channel == null) {
      logger.error('Web Socket not connected');
      return ;
    }
    
    try {
      final event = {'type': eventType, 'payload': payload};
      _repo.channel!.sink.add(jsonEncode(event));
    } catch (e) {
      logger.error('Web Socket error', error: e);
    }
  }


  Future<void>  _onMessage(dynamic message) async {
    final data = jsonDecode(message as String);
    if (data is! Map<String, dynamic>) return ;

    final eventType = data['type']?.toString() ?? '';
    final payload = Map<String, dynamic>.from(
      data['payload'] as Map? ?? const {},
    );

    if (ref.read(roomProvider).currentRoom == null) return ;
    if (eventType == _eventRoomState) {
      await _onRoomEvent(payload);
    }
  }

  Future<void>  _onRoomEvent(Map<String, dynamic> payload) async {
    final roomController = ref.read(roomProvider.notifier);

    if (payload['queue'] is List) roomController.onUpdateQueue(payload['queue'] as List);
    if (payload['current_track'] != null) roomController.onUpdateTrack(Track.fromJson(payload['current_track']));
  }
}
