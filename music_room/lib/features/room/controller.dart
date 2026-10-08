
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_room/core/model/queue_item.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/model/room_user.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/auth/state.dart';
import 'package:music_room/features/hifi/controller.dart';
import 'package:music_room/features/hifi/provider.dart';
import 'package:music_room/features/hifi/state.dart';
import 'package:music_room/features/room/impl_repository.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/features/room/socket.dart';
import 'package:music_room/features/room/state.dart';

class RoomController extends Notifier<RoomState> with WidgetsBindingObserver {
  @override
  RoomState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    return RoomState();
  }

  final RoomSocket  _socket = RoomSocket();
  StreamSubscription? _wsSubscription;
  ProviderSubscription? _processStateSubscription;
  static const Duration _wsEventTimeout = Duration(seconds: 15);

  RoomRepository get  _repo => ref.read(roomRepositoryProvider);
  HifiController get  _hifi => ref.read(hifiProvider.notifier);
  AuthState get       _auth => ref.read(authProvider);
  HifiState get       _hifiState => ref.read(hifiProvider);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshRoomsInBackground();
    }
  }

  Future<void> onRefreshRoom() async {
    final newAvailableRooms = await _repo.refreshRooms();
    state = state.copyWith(availableRooms: newAvailableRooms);
  }

  Future<void> onCreateRoom() async {
    final newRoom = await _repo.createRoom();
    state = state.copyWith(
      availableRooms: [...state.availableRooms, newRoom],
    );
    await _joinRoom(newRoom);
  }

  Future<void> onJoinRoom(Room room) async {
    if (state.currentRoom != null) await _leaveRoom();
    await _joinRoom(room);
  }

  Future<void> onLeaveRoom() async {
    if (state.currentRoom == null) return ;
    await _leaveRoom();
  }

   Future<void> onPrivatizeRoom() async {
    await _repo.privatizeRoom(state.currentRoom!.id);
    state = state.copyWith(currentRoom: state.currentRoom!.copyWith(isPublic: false));
    _refreshRoomsInBackground();
  }

  Future<void> onPublishRoom() async {
    await _repo.publishRoom(state.currentRoom!.id);
    state = state.copyWith(currentRoom: state.currentRoom!.copyWith(isPublic: true));
    _refreshRoomsInBackground();
  }

  Future<void> onDisableLicenseRoom() async {
    await _repo.disableLicenceRoom(state.currentRoom!.id);
    state = state.copyWith(currentRoom: state.currentRoom!.copyWith(isLicensed: false));
  }

  Future<void> onEnableLicenseRoom() async {
    await _repo.enableLicenceRoom(state.currentRoom!.id);
    state = state.copyWith(currentRoom: state.currentRoom!.copyWith(isLicensed: true));
  }

  Future<void> onPromoteToOwnerRoom(RoomUser listener) async {
    await _repo.transferOwnershipRoom(state.currentRoom!.id, listener.id);
    state = state.copyWith(currentRoom: state.currentRoom!.copyWith(owner: listener.id));
  }

  Future<void> onPlayNowTrack(Track track) async {
    final shouldSkip = state.currentRoom?.currentTrack != null;
    await _playNextTrack(track);
    if (shouldSkip) await _skipTrack();
  }

  Future<void> onPlayLastTrack(Track track) async {
    final room = state.currentRoom;
    if (room == null) return ;
    await _repo.addTrack(room.id, track.id);
  }

  Future<void> onPlayNextTrack(Track track) async {
    final room = state.currentRoom;
    if (room == null) return ;
    await _playNextTrack(track);
  }

  Future<void>  _playNextTrack(Track track) async {
    final room = state.currentRoom!;
    await _repo.addTrack(room.id, track.id);
    final length = room.queue.length;
    if (length > 0) await _reorderTrack(length, 0);
  }

  Future<void> onRemoveTrack(QueueItem item) async {
    final room = state.currentRoom;
    if (room == null) return;
    await _repo.removeTrack(room.id, item.trackId);
  }

  Future<void> onReorderTrack(int oldIndex, int newIndex,) async {
    await _reorderTrack(oldIndex, newIndex);
  }

  Future<List<Track>>  onSearchTrack(String query) async {
    final rawTracks = await _repo.searchTrack(query);
    final items = rawTracks['data']?['items'] as List<dynamic>? ?? [];
    return items.map((j) => Track.fromJson(j)).toList();
  }

  Future<Track?> onGetTrack(int trackId) async {
    return await _repo.getTrack(trackId);
  }

  Future<void> onResumeTrack() async {
    await _resumeTrack();
  }

  Future<void> onPauseTrack() async {
    await _pauseTrack();
  }


  Future<void> onSkipTrack() async {
    await _skipTrack();
  }

  Future<void> onRestartTrack() async {
    await _hifi.seekTrack(Duration.zero);
    _socket.sendSeek(Duration.zero);
  }

  Future<void> _connectToRoom(String roomId) async {
    await _disconnectFromRoom(roomId);
    final token = ref.read(authProvider).token;
    if (token == null) return ;
    await _socket.connect(roomId, token);
    _wsSubscription = _socket.events
      .asyncMap(_wsEvent)
      .listen((_) {}, onError: (Object e) => logger.error('WS event error', error: e));
    await _repo.joinRoom(roomId);
    _hifi.openSubscription();
    _processStateSubscription = ref.listen(hifiProvider.select((s) => s.processState), (_, processingState) async {
      final bool  amIRoomOwner = state.currentRoom?.owner == _auth.user?.id;
      if (processingState == ProcessingState.completed && amIRoomOwner) {
        await _skipTrack();
      }
    });
  }

  Future<void> _disconnectFromRoom(String roomId) async {
    await _closeSubscription();
    await _socket.disconnect();
    await _repo.leaveRoom(roomId);
  }

  Future<void>  _wsEvent(RoomEvent event) async {
    try {
      await switch (event) {
        RoomStateEvent e => _roomStateWsEvent(e),
        UserStateEvent e => _userStateWsEvent(e),
        RoomClosedEvent _ => _closeRoomWsEvent(),
        RoomDisconnectedEvent _ => _disconnectedWsEvent(),
      }.timeout(_wsEventTimeout);
    } catch (e){
      await _stopTrack();
      rethrow ;
    }
  }

  Future<void>  _roomStateWsEvent(RoomStateEvent event) async {
    final bool  hasTrackChanged = (
      state.currentRoom!.currentTrack != event.currentTrack 
      && state.currentRoom!.currentTrack?.id != event.currentTrack?.id
    );
    final bool  amIRoomOwner = state.currentRoom?.owner == _auth.user?.id;
    _roomStateWsEventQueueUpdate(event);
    if (hasTrackChanged) {
      await _roomStateWsEventUpdateTrack(event);
    } else if (
      state.currentRoom!.currentTrack == null
      && state.currentRoom!.queue.isNotEmpty
      && amIRoomOwner
    ) {
      await _roomStateWsEventStartTrack();
    } else if (
        state.currentRoom?.currentTrack != null
      && state.currentRoom?.currentTrack?.id == event.currentTrack?.id
    ) {
      await _roomStateWsEventUpdatePosition(event);
    } else {
    }
  }

  Future<void>  _userStateWsEvent(UserStateEvent event) async {
    final newRoom = state.currentRoom!.copyWith(
      owner: event.ownerId ?? state.currentRoom!.owner,
      listeners: event.listeners,
    );
    state = state.copyWith(currentRoom: newRoom);
  }

  Future<void>  _closeRoomWsEvent() async {
    state = state.copyWith(roomClosedMessage: 'Room closed by owner');
    await _leaveRoom();
  }

  Future<void>  _disconnectedWsEvent() async {
    if (state.currentRoom == null) return;
    state = state.copyWith(roomClosedMessage: 'Connection to the room lost');
    await _leaveRoom();
  }

  void  _roomStateWsEventQueueUpdate(RoomStateEvent event) {
    final newRoom = state.currentRoom!.copyWith(
      queue: event.queue,
    );
    state = state.copyWith(currentRoom: newRoom);
  }

  Future<void>  _roomStateWsEventUpdateTrack(RoomStateEvent event) async {
    final newRoom = state.currentRoom!.copyWith(
      currentTrack: event.currentTrack,
      status: 1,
      positionAtLastSync: Duration.zero,
      updatedAt: DateTime.now(),
    );
    final position = _eventLivePosition(event) ?? Duration.zero;
    state = state.copyWith(currentRoom: newRoom);
    if (event.currentTrack == null) {
      await _stopTrack();
    } else {
      await _playTrack(event.currentTrack!, position: position, play: event.isPlaying);
      await _roomStateWsEventUpdatePosition(event);
    }
  } 

  Future<void>  _roomStateWsEventStartTrack() async {
    await _skipTrack();
  }

  Future<void>  _roomStateWsEventUpdatePosition(RoomStateEvent event) async {
    if (_hifiState.isPlaying != event.isPlaying) {
      event.isPlaying ? _hifi.resumeTrack() : _hifi.pauseTrack();
    }
    final Duration? position = _eventLivePosition(event);
    if (position != null && _haveToChangePosition(position)) {
      await _hifi.seekTrack(position);
    }
  }

  Duration? _eventLivePosition(RoomStateEvent event) {
    if (event.position == null) return null;
    if (!event.isPlaying) return event.position;
    return event.position! + DateTime.now().toUtc().difference(event.timestamp);
  }

  Future<void>  _playTrack(Track newTrack, {Duration position = Duration.zero, bool play = true}) async {
    final streamUrl = await _repo.getStreamUrl(newTrack.id);
    final enrichedTrack = newTrack.copyWith(streamUrl: streamUrl);
    await _hifi.stopTrack();
    await _hifi.setTrack(enrichedTrack, position);
    if (play) _hifi.resumeTrack();
    final newRoom = state.currentRoom?.copyWith(currentTrack: enrichedTrack);
    state = state.copyWith(currentRoom: newRoom);
  }

  Future<void>  _resumeTrack() async {
    _hifi.resumeTrack();
    _socket.sendPlay(_hifiState.position);
  }

  Future<void>  _pauseTrack() async {
    _hifi.pauseTrack();
    _socket.sendPause(_hifiState.position);
  }

  Future<void> _stopTrack() async {
    final newRoom = state.currentRoom?.copyWith(currentTrack: null);
    state = state.copyWith(currentRoom: newRoom);
    await  _hifi.stopTrack();
  }

  Future<void> _joinRoom(Room room) async {
    await _connectToRoom(room.id);
    state = state.copyWith(
      currentRoom: room,
    );
  }

  Future<void>  _leaveRoom() async {
    try {
      await _stopTrack();
      await _disconnectFromRoom(state.currentRoom!.id);
    } finally {
      state = state.copyWith(currentRoom: null);
      _refreshRoomsInBackground();
    }
  }

  Future<void>  _skipTrack() async {
    await _stopTrack();
    _socket.sendNext();
  }

  Future<void> _reorderTrack(int oldIndex, int newIndex) async {
    final List<QueueItem> newQueue = state.currentRoom!.queue;
    final QueueItem       item = newQueue[oldIndex];
    final int             length = newQueue.length - 1;
    double                newPos;
    if (length == 0) return ;
    if (newIndex == 0) {
      newPos = newQueue[0].position - 100;
    } else if (newIndex == length) {
      newPos = newQueue[length].position + 100;
    } else {
      newPos = (newQueue[newIndex - 1].position + newQueue[newIndex].position) / 2;
    }
    await _repo.reorderTrack(state.currentRoom!.id, item.id, newPos);
    newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex, item);
    final newRoom = state.currentRoom!.copyWith(queue: newQueue);
    state = state.copyWith(currentRoom: newRoom);
  }

  void _refreshRoomsInBackground() {
    unawaited(onRefreshRoom().catchError((Object _) {}));
  }

  void clearRoomClosedMessage() {
    state = state.copyWith(roomClosedMessage: null);
  }

  bool  _haveToChangePosition(Duration position) {
      if ((
        _hifiState.position.inMilliseconds - position.inMilliseconds
      ).abs() > 1000) {
        return true;
      }
      return false;
  }

  Future<void> _closeSubscription() async {
    await _wsSubscription?.cancel();
    _wsSubscription = null;
    _processStateSubscription?.close();
    _processStateSubscription = null;
    _hifi.closeSubscription();
  }
}
