
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/room/provider.dart';

class WsEventHandler extends Notifier<void>{
  static const String _eventRoomState = 'RoomState';
  static const String _eventUserState = 'UserState';
  static const String _eventRoomClosed = 'RoomClosed';
  static const String _eventPlay = 'Play';
  static const String _eventPause = 'Pause';
  static const String _eventSeekTo = 'SeekTo';
  static const String _eventNextTrack = 'NextTrack';

  @override
  void build() {
    // TODO: implement build
  }

  Future<void>  handleWsEvent(String eventType, Map<String, dynamic> payload) async {
    if (ref.read(roomProvider).currentRoom == null) return;

    if (eventType == _eventRoomState) _handleEventRoom(payload);
  }

  Future<void>  _handleEventRoom(Map<String, dynamic> payload) async {

  }

  void  _roomQueue() {

  } 

}