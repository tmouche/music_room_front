import 'package:just_audio/just_audio.dart';
import 'package:music_room/core/model/room.dart';

class RoomState {
  const RoomState({
    this._isPlaying = false,
    this._playerState,
    this._isConnected = false,
    this._currentRoom,
    this._availableRooms = const [],
    this._isInitialRoomState = false,
    this._roomClosedMessage,
    this._playerErrorMessage,
    this._volume = 0.5,
  });

  final bool _isPlaying;
  final PlayerState? _playerState;
  final bool _isConnected;
  final Room? _currentRoom;
  final List<Room> _availableRooms;
  final bool _isInitialRoomState;
  final String? _roomClosedMessage;
  final String? _playerErrorMessage;
  final double _volume;

  bool get isPlaying => _isPlaying;
  PlayerState? get playerState => _playerState;
  bool get isConnected => _isConnected;
  Room? get currentRoom => _currentRoom;
  List<Room> get availableRooms => _availableRooms;
  bool get isInitialRoomState => _isInitialRoomState;
  String? get roomClosedMessage => _roomClosedMessage;
  String? get playerErrorMessage => _playerErrorMessage;
  double get volume => _volume;

  static const _unset = Object();

  RoomState copyWith({
    bool? isPlaying,
    PlayerState? playerState,
    bool? isConnected,
    Object? currentRoom = _unset,
    Object? meHasUser = _unset,
    List<Room>? availableRooms,
    bool? isInitialRoomState,
    Object? roomClosedMessage = _unset,
    Object? playerErrorMessage = _unset,
    double? volume,
  }) {
    return RoomState(
      isPlaying: isPlaying ?? _isPlaying,
      playerState: playerState ?? _playerState,
      isConnected: isConnected ?? _isConnected,
      currentRoom: identical(currentRoom, _unset) ? _currentRoom : currentRoom as Room?,
      availableRooms: availableRooms ?? _availableRooms,
      isInitialRoomState: isInitialRoomState ?? _isInitialRoomState,
      roomClosedMessage: identical(roomClosedMessage, _unset) ? _roomClosedMessage : roomClosedMessage as String?,
      playerErrorMessage: identical(playerErrorMessage, _unset) ? _playerErrorMessage : playerErrorMessage as String?,
      volume: volume ?? _volume,
    );
  }
}