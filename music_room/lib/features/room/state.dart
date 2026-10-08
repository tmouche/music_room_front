import 'package:music_room/core/model/room.dart';

class RoomState {
  const RoomState({
    this._currentRoom,
    this._availableRooms = const [],
    this._roomClosedMessage,
  });

  final Room? _currentRoom;
  final List<Room> _availableRooms;
  final String? _roomClosedMessage;

  Room? get currentRoom => _currentRoom;
  List<Room> get availableRooms => _availableRooms;
  String? get roomClosedMessage => _roomClosedMessage;

  static const _unset = Object();

  RoomState copyWith({
    Object? currentRoom = _unset,
    List<Room>? availableRooms,
    Object? roomClosedMessage = _unset,
  }) {
    return RoomState(
      currentRoom: identical(currentRoom, _unset) ? _currentRoom : currentRoom as Room?,
      availableRooms: availableRooms ?? _availableRooms,
      roomClosedMessage: identical(roomClosedMessage, _unset) ? _roomClosedMessage : roomClosedMessage as String?,
    );
  }
}