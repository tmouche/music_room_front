import 'dart:async';
import 'dart:convert';
import 'package:music_room/core/model/queue_item.dart';
import 'package:music_room/core/model/room_user.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/network/api_client.dart';
import 'package:music_room/core/network/api_path.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

sealed class RoomEvent{}


class RoomStateEvent extends RoomEvent {
  RoomStateEvent({
    required this.queue,
    required this.currentTrack,
    required this.isPlaying,
    required this.position,
    required this.timestamp,
  });

  final List<QueueItem> queue;
  final Track?          currentTrack;
  final bool            isPlaying;
  final Duration?        position;
  final DateTime        timestamp;
}


class UserStateEvent extends RoomEvent {
  UserStateEvent({required this.listeners, this.ownerId});
  final List<RoomUser>  listeners;
  final String?         ownerId;
}

class RoomClosedEvent extends RoomEvent {}

class RoomDisconnectedEvent extends RoomEvent {}


class RoomSocket {
  static const String _eventRoomState = 'RoomState';
  static const String _eventRoomClosed = 'RoomClosed';
  static const String _eventUserState = 'UserState';
  static const String _eventTrackPlay = 'Play';
  static const String _eventTrackPause = 'Pause';
  static const String _eventTrackSeekTo = 'SeekTo';
  static const String _eventTrackNext = 'NextTrack';
  static const Duration _connectTimeout = Duration(seconds: 3);
  static const Duration _closeTimeout = Duration(seconds: 2);
  final _events = StreamController<RoomEvent>.broadcast();
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;

  Stream<RoomEvent> get events => _events.stream;
  bool              get isConnected => _channel != null;

  Future<void>  connect(String roomId, String token) async {
    final uri = Uri.parse(
      '${ApiClient.baseUrl.replaceFirst('http', 'ws')}${ApiPath.roomsWebSocket(roomId)}',
    ).replace(queryParameters: {'token': token});
    final channel = WebSocketChannel.connect(uri);
    try {
      await channel.ready.timeout(_connectTimeout);
    } catch (_) {
      unawaited(_closeChannel(channel));
      rethrow;
    }
    _channel = channel;
    _channelSubscription = channel.stream.listen(
      _onRaw,
      onError: (Object e) => logger.error('WS error', error: e),
      onDone: () => _onDone(channel),
      cancelOnError: true,
    );
  }

  Future<void>  disconnect() async {
    final channel = _channel;
    _channel = null;
    final subscription = _channelSubscription;
    _channelSubscription = null;
    await subscription?.cancel();
    if (channel != null) await _closeChannel(channel);
  }

  Future<void>  _closeChannel(WebSocketChannel channel) async {
    try {
      await channel.sink.close().timeout(_closeTimeout);
    } catch (_) {}
  }

  void  _onDone(WebSocketChannel channel) {
    if (!identical(_channel, channel)) return;
    _channel = null;
    _channelSubscription = null;
    _events.add(RoomDisconnectedEvent());
  }

  void  _onRaw(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      final payload = Map<String, dynamic>.from(data['payload'] ?? {});
      final event = switch (data['type']) {
        _eventRoomState => _parseRoomState(payload),
        _eventUserState => _parseUserState(payload),
        _eventRoomClosed => RoomClosedEvent(),
        _ => null,
      };
      if (event != null) _events.add(event);
    } catch (e) {
      logger.error('WS bad message', error: e);
    }
  }

  void  sendPlay(Duration position) => _send(_eventTrackPlay,{
    'position': position.inMilliseconds,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
  });

  void  sendPause(Duration position) => _send(
    _eventTrackPause, {'position': position.inMilliseconds}
  );

  void  sendSeek(Duration position) => _send(_eventTrackSeekTo, {
    'position': position.inMilliseconds,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
  });

  void  sendNext() => _send(_eventTrackNext, {
    'timestamp': DateTime.now().toUtc().toIso8601String(),
  });

  void  _send(String type, Map<String, dynamic> payload) =>
    _channel?.sink.add(jsonEncode({'type': type, 'payload': payload}));

  RoomStateEvent  _parseRoomState(Map<String, dynamic> payload) {
    final List<QueueItem>       queue = _parseRoomStateQueue(payload['queue']);
    final Map<String, dynamic>? rawCurrentTrack = payload['current_track'];
    final Track?                currentTrack = (
      rawCurrentTrack != null ?
      Track.fromJson(rawCurrentTrack)
      : null
    );
    final bool                  isPlaying = payload['is_playing'];

    final Duration?              position = payload['current_position'] == null ? null : Duration(
      milliseconds: (payload['current_position'] as num).toInt()
    );
    final DateTime              timestamp = DateTime.parse(
      payload['timestamp'] as String
    ).toUtc();
    return RoomStateEvent(
      queue: queue,
      currentTrack: currentTrack,
      isPlaying: isPlaying,
      position: position,
      timestamp: timestamp,
    );
  }

  UserStateEvent  _parseUserState(Map<String, dynamic> payload) {
    final List<RoomUser>  listeners = _parseUserStateListeners(payload['user_list']);
    final String?         ownerId = payload['owner']?.toString();
    return UserStateEvent(
      ownerId: ownerId,
      listeners: listeners
    );
  }

  List<QueueItem> _parseRoomStateQueue(List rawQueue) {
    return rawQueue.asMap().entries.map<QueueItem>((entry) {
      final queuedTrackJson = entry.value as Map<String, dynamic>;
      final trackJson = queuedTrackJson['track'] as Map<String, dynamic>;
      final position =(queuedTrackJson['position'] as num?)?.toDouble() ?? entry.key.toDouble();
      final track = Track.fromJson(trackJson);
      return QueueItem(
        id: queuedTrackJson['id'] as String,
        roomId: 'DOITETREDANSLENTRY',
        trackId: track.id,
        position: position,
      );
    }).toList();
  }

  List<RoomUser> _parseUserStateListeners(List rawListeners) {
    return rawListeners
      .map((u) {
        final id = u['user_id']?.toString();
        final username = u['username']?.toString();
        if (id == null || username == null) return null;
        return RoomUser(id: id, username: username);
      })
      .whereType<RoomUser>()
      .toList();
  }
}