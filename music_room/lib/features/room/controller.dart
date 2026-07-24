
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/model/queue_item.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/model/room_user.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/features/player/controller.dart';
import 'package:music_room/features/player/provider.dart';
import 'package:music_room/features/room/impl_repository.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/features/room/state.dart';
import 'package:music_room/features/web_socket/controller.dart';
import 'package:music_room/features/web_socket/provider.dart';

class RoomController extends Notifier<RoomState> with WidgetsBindingObserver {

  @override
  RoomState build() {
    _repo = ref.read(roomRepositoryProvider);
    
    _audioPlayerController = ref.read(audioPlayerProvider.notifier);
    _webSocketController = ref.read(webSocketProvider.notifier);

    return RoomState();
  }

  late final RoomRepository         _repo;

  late final AudioPlayerController  _audioPlayerController;
  late final WebSocketController    _webSocketController;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refreshRoom());
    }
  }

  Future<void> refreshRoom() async {
    try {
      final newAvailableRooms = await _repo.getRooms();
      // if (newAvailableRooms == null) {return ;}
      state = state.copyWith(availableRooms: newAvailableRooms);
    } catch (e) {
      logger.error('Failed to refresh rooms', error: e);
      rethrow;
    }
  }

  Future<void> createRoom() async {
    try {
      final newRoom = await _repo.createRoom();
      await openRoom(newRoom);
      state = state.copyWith(
        availableRooms: [...state.availableRooms, newRoom],
        currentRoom: newRoom,
      );
      unawaited(refreshRoom());
    } catch (e) {
      logger.error('Failed to create room', error: e);
      rethrow;
    }
  }

  Future<void> openRoom(Room room) async {
    await _webSocketController.connect(room.id);
    state = state.copyWith(
      currentRoom: room,
      isInitialRoomState: true,
    );
  }

  Future<void> leaveRoom() async {
    await _audioPlayerController.stop();
    await _webSocketController.disconnect();
    state = state.copyWith(currentRoom: null);
    unawaited(refreshRoom());
  }

  void clearRoomClosedMessage() {
    state = state.copyWith(roomClosedMessage: null);
  }

  void clearPlayerErrorMessage() {
    state = state.copyWith(playerErrorMessage: null);
  }

  Future<void> privatizeRoom() async {
    try {
      await _repo.privatize(state.currentRoom!.id);
      state.copyWith(currentRoom: state.currentRoom!.copyWith(isPublic: false));
      unawaited(refreshRoom());
    } catch (e) {
      logger.error('Failed to toggle privacy', error: e);
      rethrow ;
    }
  }

  Future<void> publishRoom() async {
    try {
      await _repo.publish(state.currentRoom!.id);
      state.copyWith(currentRoom: state.currentRoom!.copyWith(isPublic: false));
      unawaited(refreshRoom());
    } catch (e) {
      logger.error('Failed to publish room', error: e);
      rethrow ;
    }
  }

  Future<void> disableLicense() async {
    try {
      await _repo.disableLicence(state.currentRoom!.id);
      state.copyWith(currentRoom: state.currentRoom!.copyWith(isLicensed: false));
    } catch (e) {
      logger.error('Failed to disable license');
      rethrow ;
    }
  }

  Future<void> enableLicense() async {
    try {
      await _repo.enableLicence(state.currentRoom!.id);
      state.copyWith(currentRoom: state.currentRoom!.copyWith(isLicensed: false));
    } catch (e) {
      logger.error('Failed to enable license');
      rethrow ;
    }
  }

  void promoteToOwner(RoomUser listener) async {
    try {
      await _repo.transferOwnership(state.currentRoom!.id, listener.id);
      state.copyWith(currentRoom: state.currentRoom!.copyWith(owner: listener.username));
    } catch (e) {
      logger.error('Failed to transfer ownership', error: e);
      rethrow ;
    }
    return ;
  }

  Future<void> addTrackToQueue(Track track) async {
    final room = state.currentRoom;
    if (room == null) return ;
    await _repo.addTrack(room.id, track.id);
  }

  Future<void> removeTrackFromQueue(QueueItem item) async {
    final room = state.currentRoom;
    if (room == null) return;
    await _repo.removeTrack(room.id, item.id);
  }

  Future<void> reorderQueueItem(
    int oldIndex,
    int newIndex,
  ) async {
    final newQueue = state.currentRoom!.queue;

    final item = newQueue[oldIndex];
    newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex, item);

    final newRoom = state.currentRoom!.copyWith(queue: newQueue);
    state = state.copyWith(currentRoom: newRoom);

    try {
      await _repo.reorderTrack(newRoom.id, item.id, newIndex as double);
    } catch (e) {
      logger.error('Failed to reorder queue', error: e);
      rethrow ;
    }
  }

  void  onUpdateQueue(List queueList) {
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

  Future<void> onUpdateTrack(Map<String, dynamic> payload) async {
    if (payload['current_track'] != null) {
      Track newTrack = Track.fromJson(payload['current_track']);
      final bool hasTrackChanged = 
        (state.currentTrack?.id != newTrack.id)
        || (state.isInitialRooms == true)
        || (!_audioPlayerController.isTrackStarted);

      // _currentRoom!.currentTrack = track;
      // ancienne ligne mais je vois pas le but dans l archi d ajd a voir si ya
      // des bugs

      if (hasTrackChanged) {
        final serverTimestamp = DateTime.parse(
          payload['timestamp'] as String,
        ).toUtc();
        final currentPositionMs = (payload['current_position'] as int?) ?? 0;
        _playTrack(newTrack, currentPositionMs, serverTimestamp);
      }
    }
    else {
      final newRoom = state.currentRoom!.copyWith(currentTrack: null);
      state = state.copyWith(currentRoom: newRoom);
      _audioPlayerController.stop();
    }
  }

  Future<Map<String, dynamic>>  searchTrack(String query) async {
    return await _repo.searchTrack(query);
  }

  Future<void>  onUpdatePlaying(Map<String, dynamic> payload, bool isPlaying) async {
      final newRoom = state.currentRoom!.copyWith(
        status: isPlaying ? 1 : 0
      );
      state = state.copyWith(currentRoom: newRoom);

      if (isPlaying && !_audioPlayerController.isPlaying) {
        await _audioPlayerController.play();
      } else if (!isPlaying && _audioPlayerController.isPlaying) {
        await _audioPlayerController.pause();
      }
  }

  Future<void>  onCurrentPosition(Map<String, dynamic> payload, bool isPlaying) async {
    int posMs = payload['current_position'] as int;
    if (isPlaying && payload['timestamp'] != null) {
      final playedAt = DateTime.parse(
        payload['timestamp'].toString()
      ).toUtc();
      final diff = DateTime.now().toUtc().difference(playedAt).inMilliseconds;
      if (diff > 0) posMs += diff;
    }

    final currentPosMs = _audioPlayerController.position.inMilliseconds;
    final seekDiff = (posMs - currentPosMs).abs();
    if (seekDiff > 1000) {
      await _audioPlayerController.seek(Duration(milliseconds: posMs));
    }
  }

  void  onUserChange(Map<String, dynamic> payload, List<RoomUser> newUsers) {
    final ownerId = payload['owner']?.toString();
    final newRoom = state.currentRoom!.copyWith(
      owner: ownerId ?? state.currentRoom!.owner,
      listeners: newUsers
    );
    state = state.copyWith(currentRoom: newRoom);
  }

  Future<void>  onRoomClose() async {
    state = state.copyWith(roomClosedMessage: 'Room closed by owner');
    await leaveRoom();
  }

  void  setRoomHasNotInitial() {
    state = state.copyWith(isInitialRoomState: false);
  }

  Future<void>  _playTrack(
    Track track,
    int serverPositionMs,
    DateTime serverTimestamp,
  ) async {
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

      final timeSinceServerTimestamp = loadStartTime.difference(
        serverTimestamp,
      );
      final position = Duration(
        milliseconds:
            serverPositionMs + timeSinceServerTimestamp.inMilliseconds,
      );

      await _audioPlayerController.start(newTrack, position);
      state = state.copyWith(currentRoom: newRoom);
    } catch (e) {
      logger.error('Error playing track', error: e);
      final playerErrorMessage = e is ApiException && e.statusCode == 500
          ? 'Error of the player: impossible to load the track.'
          : 'Error playing track.';
      state = state.copyWith(playerErrorMessage: playerErrorMessage);
    }
  }

  

}
