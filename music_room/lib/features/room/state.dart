import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/model/track.dart';

class RoomState {
  const RoomState({
    this._isPlaying = false,
    this._currentRoom,
    this._availableRooms = const [],
    this._isInitialRoomState = false,
    this._roomClosedMessage,
    this._playerErrorMessage,
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

  static const _unset = Object();

  RoomState copyWith({
    bool? isPlaying,
    Object? currentRoom = _unset,
    List<Room>? availableRooms,
    bool? isInitialRoomState,
    Object? roomClosedMessage = _unset,
    Object? playerErrorMessage = _unset,
  }) {
    return RoomState(
      isPlaying: isPlaying ?? _isPlaying,
      currentRoom: identical(currentRoom, _unset) ? _currentRoom : currentRoom as Room?,
      availableRooms: availableRooms ?? _availableRooms,
      isInitialRoomState: isInitialRoomState ?? _isInitialRoomState,
      roomClosedMessage: identical(roomClosedMessage, _unset) ? _roomClosedMessage : roomClosedMessage as String?,
      playerErrorMessage: identical(playerErrorMessage, _unset) ? _playerErrorMessage : playerErrorMessage as String?,
    );
  }
}