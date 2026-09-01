
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_room/core/model/queue_item.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/model/room_user.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/storage/settings_strorage.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/auth/state.dart';
import 'package:music_room/features/room/impl_repository.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/features/room/state.dart';

class RoomController extends Notifier<RoomState> with WidgetsBindingObserver {
  static const String _eventRoomState = 'RoomState';
  static const String _eventRoomClosed = 'RoomClosed';
  static const String _eventUserState = 'UserState';
  static const String _eventTrackPlay = 'Play';
  static const String _eventTrackPause = 'Pause';
  static const String _eventTrackSeekTo = 'SeekTo';
  static const String _eventTrackNext = 'NextTrack';

  @override
  RoomState build() {
    final initialState = RoomState();
    _repo = ref.read(roomRepositoryProvider);
    _auth = ref.read(authProvider);
    _loadPersistedVolume();
    return initialState;
  }

  late final RoomRepository _repo;
  late final AuthState      _auth;
  StreamSubscription? _wsSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  int? _loadingTrackId;

  Future<void> dispose() async {
    await _repo.dispose();
    await _closeSubscription();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshRoomsInBackground();
    }
  }

  Future<void> _loadPersistedVolume() async {
    final savedVolume = await SettingsStrorage.getVolume();
    if (savedVolume != null) {
      await _repo.setVolume(savedVolume);
      state = state.copyWith(volume: savedVolume);
    }
  }

  Future<void> refreshRoom() async {
    try {
      final newAvailableRooms = await _repo.refreshRooms();
      state = state.copyWith(availableRooms: newAvailableRooms);
    } catch (e) {
      logger.error('Failed to refresh rooms', error: e);
      rethrow;
    }
  }

  Future<void> createRoom() async {
    try {
      final newRoom = await _repo.createRoom();
      state = state.copyWith(
        availableRooms: [...state.availableRooms, newRoom],
      );
      await joinRoom(newRoom);
      _refreshRoomsInBackground();
    } catch (e) {
      logger.error('Failed to create room', error: e);
      rethrow;
    }
  }

  Future<void> joinRoom(Room room) async {
    await _connectToRoom(room.id);
    state = state.copyWith(
      currentRoom: room,
      isInitialRoomState: true,
    );
    _refreshRoomsInBackground();
  }

  Future<void> _connectToRoom(String roomId) async {
    await _disconnectFromRoom(roomId);
    final token = ref.read(authProvider).token;
    if (token == null) return ;
    try {
      await _repo.createChannel(roomId, token);
      _wsSubscription = _repo.channel?.stream.listen(
        _onWsMessage,
        onError: (err) => logger.error('WebSocker error', error: err),
        onDone: () {
          state = state.copyWith(isConnected: false);
        },
      );
      _playerStateSubscription = _repo.playerStateStream.listen((playerState) async {
        if (playerState.processingState == ProcessingState.completed) {
          final isOwner = state.currentRoom?.owner == _auth.user?.id;
          if (isOwner && playerState.playing) {
            await skipNextTrack();
          }
        }
        if (state.isPlaying != playerState.playing) {
          state = state.copyWith(isPlaying: playerState.playing);
        }
      });
      _durationSubscription = _repo.durationStream.listen((duration) {
        final track = state.currentRoom?.currentTrack?.copyWith(duration: duration);
        final room = state.currentRoom?.copyWith(currentTrack: track);
        state = state.copyWith(currentRoom: room);
      });

      state = state.copyWith(isConnected: true);
    } catch (e) {
      logger.error('Failed to connect to WebSocket', error: e);
      state = state.copyWith(isConnected: false);
    }
    await _repo.joinRoom(roomId);
  }

  Future<void>  _onWsMessage(dynamic message) async {
    try {
      final data = jsonDecode(message as String);
      if (data is! Map<String, dynamic>) return ;
      final eventType = data['type']?.toString() ?? '';
      final payload = Map<String, dynamic>.from(
        data['payload'] as Map? ?? const {},
      );
      if (state.currentRoom == null) return ;
      if (eventType == _eventRoomState) {
        await _onWsEventRoom(payload);
      }
      else if (eventType == _eventUserState) {
        await _onWsEventUser(payload);
      }
      else if (eventType == _eventRoomClosed) {
        await _onWsRoomCloseEvent();
      }
    } catch (e, st) {
      logger.error('Failed to handle WebSocket event', error: e, stackTrace: st);
    }
  }

  Future<void>  _onWsEventRoom(Map<String, dynamic> payload) async {
    if (payload['queue'] is List) {
      _onWsEventRoomUpdateQueue(payload['queue'] as List);
    }
    await _onWsEventRoomUpdateTrack(payload);
    // await _onWsEventRoomUpdatePlaying(payload, isPlaying);
    // if (payload['current_position'] != null) {
    //   await _onWsEventRoomCurrentPosition(payload, state.isPlaying);
    // }
  }
  
  void  _onWsEventRoomUpdateQueue(List queueList) {
    final newQueue = queueList.asMap().entries.map<QueueItem>((entry) {
      final queuedTrackJson = entry.value as Map<String, dynamic>;
      final trackJson = queuedTrackJson['track'] as Map<String, dynamic>;
      final position =
        (queuedTrackJson['position'] as num?)?.toDouble() ??
        entry.key.toDouble();
      final track = Track.fromJson(trackJson);
      return QueueItem(
        id: queuedTrackJson['id'] as String,
        roomId: state.currentRoom!.id,
        trackId: track.id,
        position: position,
      );
    }).toList();
    final newRoom = state.currentRoom!.copyWith(queue: newQueue);
    state = state.copyWith(currentRoom: newRoom);
  }

  Future<void> _onWsEventRoomUpdateTrack(Map<String, dynamic> payload) async {
    if (payload['current_track'] != null) {
      Track newTrack = Track.fromJson(payload['current_track']);
      final bool hasTrackChanged = 
        (state.currentRoom!.currentTrack == null)
        ||  (state.currentRoom!.currentTrack!.id != newTrack.id)
        || (state.isInitialRoomState == true);

      if (hasTrackChanged) {
        final serverTimestamp = DateTime.parse(
          payload['timestamp'] as String,
        ).toUtc();
        final currentPositionMs = (payload['current_position'] as int?) ?? 0;
        _onWsEventRoomUpdateTrackPlayTrack(newTrack, currentPositionMs, serverTimestamp);
      }
    }
    else {
      await stopTrack();
      if (state.currentRoom!.queue.isNotEmpty && state.isInitialRoomState) {
        await skipNextTrack();
        state = state.copyWith(isInitialRoomState: false);
      } else if (state.currentRoom!.queue.isEmpty) {
        state = state.copyWith(isInitialRoomState: true);
      }
    }
  }

  Future<void>  _onWsEventRoomUpdateTrackPlayTrack(
    Track track,
    int serverPositionMs,
    DateTime serverTimestamp,
  ) async {
    if (_loadingTrackId == track.id) return ;
    _loadingTrackId = track.id;
    try {
      final loadStartTime = DateTime.now().toUtc();
      final streamUrl = await _repo.getStreamUrl(track.id);
      final newTrack = track.copyWith(streamUrl: streamUrl);
      final newRoom = state.currentRoom!.copyWith(
        currentTrack: newTrack,
        status: 1,
        positionAtLastSync: Duration.zero,
        updatedAt: DateTime.now(),
      );
      state = state.copyWith(currentRoom: newRoom);
      final timeSinceServerTimestamp = loadStartTime.difference(
        serverTimestamp,
      );
      final position = Duration(
        milliseconds:
            serverPositionMs + timeSinceServerTimestamp.inMilliseconds,
      );
      await startTrack(newTrack, position);
    } catch (e) {
      logger.error('Error playing track', error: e);
      final playerErrorMessage = e is ApiException && e.statusCode == 500
          ? 'Error of the player: impossible to load the track.'
          : 'Error playing track.';
      state = state.copyWith(playerErrorMessage: playerErrorMessage);
    } finally {
      _loadingTrackId = null;
    }
  }

  // Future<void>  _onWsEventRoomUpdatePlaying(Map<String, dynamic> payload, bool isPlaying) async {
  //     final newRoom = state.currentRoom!.copyWith(
  //       status: isPlaying ? 1 : 0
  //     );
  //     state = state.copyWith(currentRoom: newRoom);

  //     if (isPlaying && !_repo.isPlaying) {
  //       await playTrack();
  //     } else if (!isPlaying && _repo.isPlaying) {
  //       await pauseTrack();
  //     }
  // }

  // Future<void>  _onWsEventRoomCurrentPosition(Map<String, dynamic> payload, bool isPlaying) async {
  //   int posMs = payload['current_position'] as int;
  //   if (isPlaying && payload['timestamp'] != null) {
  //     final playedAt = DateTime.parse(
  //       payload['timestamp'].toString()
  //     ).toUtc();
  //     final diff = DateTime.now().toUtc().difference(playedAt).inMilliseconds;
  //     if (diff > 0) posMs += diff;
  //   }

  //   final currentPosMs = _repo.position.inMilliseconds;
  //   final seekDiff = (posMs - currentPosMs).abs();
  //   if (seekDiff > 1000) {
  //     await seekTrack(Duration(milliseconds: posMs));
  //   }
  // }

  Future<void>  _onWsEventUser(Map<String, dynamic> payload) async {
    final users = payload['user_list'];
    if (users is! List) return;

    final newListeners = users
      .map((u) => _onWsEventUserRoomUserFromPayload(u))
      .whereType<RoomUser>()
      .toList();
    _onWsEventUserChange(payload, newListeners);
  }

  RoomUser? _onWsEventUserRoomUserFromPayload(dynamic payload) {
    if (payload is! Map) return null;
    final id = payload['user_id']?.toString();
    final username = payload['username']?.toString();
    if (id == null || username == null) return null;
    return RoomUser(id: id, username: username);
  }

  void  _onWsEventUserChange(Map<String, dynamic> payload, List<RoomUser> newUsers) {
    final ownerId = payload['owner']?.toString();
    final newRoom = state.currentRoom!.copyWith(
      owner: ownerId ?? state.currentRoom!.owner,
      listeners: newUsers
    );
    state = state.copyWith(currentRoom: newRoom);
  }

  Future<void>  _onWsRoomCloseEvent() async {
    state = state.copyWith(roomClosedMessage: 'Room closed by owner');
    await leaveRoom();
  }

  Future<void> leaveRoom() async {
    final room = state.currentRoom;
    if (room == null) return ;
    state = state.copyWith(currentRoom: null);
    try {
      await stopTrack();
    } catch (e) {
      logger.error('Failed to stop player on leave', error: e);
    }
    await _disconnectFromRoom(room.id);
    _refreshRoomsInBackground();
  }

  Future<void> _disconnectFromRoom(String roomId) async {
    await _closeSubscription();
    await _repo.deleteChannel();
    state = state.copyWith(isConnected: false);
    await _repo.leaveRoom(roomId);
  }

  Future<void> privatizeRoom() async {
    try {
      await _repo.privatizeRoom(state.currentRoom!.id);
      state.copyWith(currentRoom: state.currentRoom!.copyWith(isPublic: false));
      _refreshRoomsInBackground();
    } catch (e) {
      logger.error('Failed to toggle privacy', error: e);
      rethrow ;
    }
  }

  Future<void> publishRoom() async {
    try {
      await _repo.publishRoom(state.currentRoom!.id);
      state.copyWith(currentRoom: state.currentRoom!.copyWith(isPublic: false));
      _refreshRoomsInBackground();
    } catch (e) {
      logger.error('Failed to publish room', error: e);
      rethrow ;
    }
  }

  Future<void> disableLicenseRoom() async {
    try {
      await _repo.disableLicenceRoom(state.currentRoom!.id);
      state.copyWith(currentRoom: state.currentRoom!.copyWith(isLicensed: false));
    } catch (e) {
      logger.error('Failed to disable license');
      rethrow ;
    }
  }

  Future<void> enableLicenseRoom() async {
    try {
      await _repo.enableLicenceRoom(state.currentRoom!.id);
      state.copyWith(currentRoom: state.currentRoom!.copyWith(isLicensed: false));
    } catch (e) {
      logger.error('Failed to enable license');
      rethrow ;
    }
  }

  void promoteToOwnerRoom(RoomUser listener) async {
    try {
      await _repo.transferOwnershipRoom(state.currentRoom!.id, listener.id);
      state.copyWith(currentRoom: state.currentRoom!.copyWith(owner: listener.username));
    } catch (e) {
      logger.error('Failed to transfer ownership', error: e);
      rethrow ;
    }
    return ;
  }

  Future<void> overrideCurrentTrack(Track track) async {
    try {
      final shouldSkip = state.currentRoom?.currentTrack == null;
      await addTrackToHead(track);
      if (!shouldSkip) await skipNextTrack();
    } catch (e) {
      logger.error('Failed to override current Track', error: e);
      rethrow ;
    }
    return ;
  }

  Future<void> addTrackToQueue(Track track) async {
    final room = state.currentRoom;
    if (room == null) return ;
    await _repo.addTrack(room.id, track.id);
  }

  Future<void> addTrackToHead(Track track) async {
    final room = state.currentRoom;
    if (room == null) return ;
    await _repo.addTrack(room.id, track.id);
    final length = room.queue.length;
    if (length > 0) {
      await reorderQueueItem(length, 0);
    }
    await _repo.refreshRooms();
  }

  Future<void> removeTrackFromQueue(QueueItem item) async {
    final room = state.currentRoom;
    if (room == null) return;
    await _repo.removeTrack(room.id, item.trackId);
  }

  Future<void> reorderQueueItem(
    int oldIndex,
    int newIndex,
  ) async {
    final List<QueueItem> newQueue = state.currentRoom!.queue;
    final QueueItem       item = newQueue[oldIndex];
    final int             length = newQueue.length - 1;
    double                newPos;

    print('OLD INDEX $oldIndex');
    print('NEW INDEX $newIndex');
    print('LEN $length');

    for (int idx = 0; idx < newQueue.length; idx++) {
      print("ITEM $idx ${newQueue[idx].track.title} ${newQueue[idx].position}");
    }

    // YA TOUJOURS UN BUG QUAND LES ON ESSAYE DE BOUGER LES ITEMS A LA MAIN

    if (length <= 0) return ;
    if (newIndex == 0) {
      print("PASS IN NEWINDEX == 0");
      newPos = newQueue[0].position - 100;
    } else if (newIndex == length) {
      print("PASS IN NEWINDEX == length");
      newPos = newQueue[length - 1].position + 100;
    } else {
      print("PASS ELSE");
      newPos = (newQueue[newIndex - 1].position + newQueue[newIndex].position) / 2;
    }
    print('NEW POS $newPos');
    try {
      await _repo.reorderTrack(state.currentRoom!.id, item.id, newPos);
    } catch (e) {
      logger.error('Failed to reorder queue', error: e);
      rethrow ;
    }
    newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex, item);
    final newRoom = state.currentRoom!.copyWith(queue: newQueue);
    state = state.copyWith(currentRoom: newRoom);
  }

  Future<Map<String, dynamic>>  searchTrack(String query) async {
    return await _repo.searchTrack(query);
  }

  Future<void> startTrack(Track newTrack, Duration position) async {
    await _repo.startTrack(newTrack, position);
    final newRoom = state.currentRoom?.copyWith(currentTrack: newTrack);
    state = state.copyWith(currentRoom: newRoom);
  }


  Future<void> playTrack() async {
    if (!_repo.isPlaying) {
      _toWsMessage(_eventTrackPlay, {
        'position': _repo.position.inMilliseconds,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
      await _repo.playTrack();
    }
  }

  Future<void> pauseTrack() async {
    if (_repo.isPlaying) {
      _toWsMessage(_eventTrackPause, {
          'position': _repo.position.inMilliseconds,
        });
      await _repo.pauseTrack();
    }
  }

  Future<void> stopTrack() async {
    await  _repo.stopTrack();
    final newRoom = state.currentRoom?.copyWith(currentTrack: null);
    state = state.copyWith(currentRoom: newRoom, isPlaying: false);
  }

  Future<void> seekTrack(Duration position) async {
    _toWsMessage(_eventTrackSeekTo, {
      'position': position.inMilliseconds,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
    await _repo.seekTrack(position);
  }

  Future<void> setVolume(double volume) async {
    await _repo.setVolume(volume);
    state = state.copyWith(volume: volume);
    await SettingsStrorage.saveVolume(volume);
  }

  Future<void> skipNextTrack() async {
    await stopTrack();
    _toWsMessage(_eventTrackNext, {
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> skipPrevTrack() async {
    await stopTrack();
    await seekTrack(Duration());
  }

  Future<Track?> getTrack(int trackId) async {
    return await _repo.getTrack(trackId);
  }

  void  _toWsMessage(String eventType, Map<String, dynamic> payload) {
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

  void _refreshRoomsInBackground() {
    unawaited(refreshRoom().catchError((Object _) {}));
  }

  Future<void> _closeSubscription() async {
    await _wsSubscription?.cancel();
    _wsSubscription = null;
    await _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
  }

  void clearRoomClosedMessage() {
    state = state.copyWith(roomClosedMessage: null);
  }

  void clearPlayerErrorMessage() {
    state = state.copyWith(playerErrorMessage: null);
  }

}
