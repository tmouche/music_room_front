import 'dart:async';

import 'package:music_room/core/audio/audio_service.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/network/websocket_service.dart';
import 'package:music_room/features/room/impl_repository.dart';

class RoomState {
  const RoomState({
    this._isPlaying = false,
    this._currentRoom,
    this._availableRooms = const [],
    this._isInitialRoomState = false,
    this._roomClosedMessage,
    this._playerErrorMessage
  });

  final bool _isPlaying;
  final Room? _currentRoom;
  final List<Room> _availableRooms;
  final bool _isInitialRoomState;
  final String? _roomClosedMessage;
  final String? _playerErrorMessage;

  bool get isPlaying => _isPlaying;
  Room? get currentRoom => _currentRoom;
  List<Room> get availableRooms => _availableRooms;
  bool get isInitialRooms => _isInitialRoomState;
  String? get roomClosedMessage => _roomClosedMessage;
  String? get playerErrorMessage => _playerErrorMessage;

  Track? get currentTrack => _currentRoom?.currentTrack;

  RoomState copyWith({
    bool? isPlaying,
    Room? currentRoom,
    List<Room>? availableRooms,
    bool? isInitialRoomState,
    String? roomClosedMessage,
    String? playerErrorMessage,
  }) {
    return RoomState(
      isPlaying: isPlaying ?? _isPlaying,
      currentRoom: currentRoom ?? _currentRoom,
      availableRooms: availableRooms ?? _availableRooms,
      isInitialRoomState: isInitialRoomState ?? _isInitialRoomState,
      roomClosedMessage: roomClosedMessage ?? _roomClosedMessage,
      playerErrorMessage: playerErrorMessage ?? _playerErrorMessage,
    );
  }
}