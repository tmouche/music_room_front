
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_room/core/audio/audio_service.dart';
import 'package:music_room/core/model/queue_item.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/network/websocket_service.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/features/room/room_repository.dart';
import 'package:music_room/features/room/state.dart';

class RoomController extends Notifier<RoomState> with WidgetsBindingObserver {
  static const String _eventRoomState = 'RoomState';
  
  @override
  RoomState build() {
    _roomRepository = RoomRepository();
    return RoomState();
  }

  late final RoomRepository _roomRepository;
  // late final WsRep

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.resumed) {
      refreshRoom();
    }
  }


  void refreshRoom() {
    return ;
  }

  void createRoom() {
    return ;
  }

  void openRoom() {
    return ;  
  }

  void leaveRoom() {
    return ;
  }

  void privatizeRoom() {
    return ;
  }

  void publishRoom() {
    return ;
  }

  void disableLicense() {
    return ;
  }

  void enableLicense() {
    return ;
  }

  void promoteToUser() {
    return ;
  }

  void addTrackToQueue() {
    return ;
  }

  void removeTrackFromQueue() {
    return ;
  }

  void reorderQueueItem() {
    return ;
  }

  void  onUpdateQueue(List queueList) {
    final newQueue = queueList.asMap().entries.map<QueueItem>((entry) {
      final queuedTrackJson = entry.value as Map<String, dynamic>;
      final trackJson = queuedTrackJson['track'] as Map<String, dynamic>;
      final position =
        (queuedTrackJson['position'] as num?)?.toDouble() ??
        entry.key.toDouble();

      Track.fromJson(trackJson);

      return QueueItem(
        id: queuedTrackJson['id'] as String,
        roomId: state.currentRoom!.id,
        trackId: trackJson['id'] as int,
        position: position,
      );
    }).toList();
    final newRoom = state.currentRoom!.copyWith(queue: newQueue);
    state = state.copyWith(currentRoom: newRoom);
  }

  void onUpdateTrack(Track newTrack) {
    final bool trackChanged = 
      (state.currentTrack?.id != newTrack.id)
      || (state.isInitialRooms == true)
      || ()
  }
}
