import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/model/room_user.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/data/fake_room.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/room/impl_repository.dart';

class MockRoomRepository extends RoomRepository {
  MockRoomRepository(this._ref)
  : super() {
    allRooms = [fakeRoom1, fakeRoom2, fakeRoom3, fakeRoom4, fakeRoom5, fakeRoom6, fakeRoom7];
  }

  final Ref       _ref;
  late List<Room> allRooms;

  @override
  Future<List<Room>> getRooms() async {
    await Future.delayed(Duration(seconds: 1));
    for (int idx = 0; idx < allRooms.length; idx++) {
      final currentRoom = allRooms[idx];
      if (currentRoom.people == 0) {
        allRooms.removeAt(idx);
      }
    }
    return allRooms;
  }

  @override
  Future<List<Room>> refreshRooms() async {
      return await getRooms();
  }

  @override
  Future<Room> createRoom() async {
    final authState = _ref.read(authProvider);
    
    final id = (allRooms.length + 1).toString();
    final users = [RoomUser(id: "1", username: authState.user!.username)];
    final newRoom = Room(
      id: id,
      name: 'Fake Vibes $id',
      owner: authState.user!.username,
      listeners: users
    );
    
    allRooms.add(newRoom);
    return newRoom;
  }

  @override
  Future<void> joinRoom(String roomId) async {
    final authState = _ref.read(authProvider);

    await Future.delayed(Duration(milliseconds: 1));
    for (int idx = 0; idx < allRooms.length; idx++) {
      final currentRoom = allRooms[idx];
      if (currentRoom.id == roomId) {
        final user = RoomUser(
          id: "${int.parse(currentRoom.listeners.last.id) + 1}",
          username: authState.user!.username
        );
        currentRoom.listeners.add(user);
        break;
      }
    }
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    final authState = _ref.read(authProvider);

    await Future.delayed(Duration(milliseconds: 1));
    for (int idx = 0; idx < allRooms.length; idx++) {
      final currentRoom = allRooms[idx];
      if (currentRoom.id == roomId) {
        for (var listener in currentRoom.listeners) {
          if (listener.username == authState.user!.username) {
            currentRoom.listeners.remove(listener);
            break;
          }
        }
        break;
      }
    }
  }


  @override
  Future<void>  privatizeRoom(String roomId) async {}

  @override
  Future<void>  publishRoom(String roomId) async {}

  @override
  Future<void>  disableLicenceRoom(String roomId) async {}

  @override
  Future<void>  enableLicenceRoom(String roomId) async {}

  @override
  Future<void>  transferOwnershipRoom(String roomId, String newOwnerId) async {}

  @override
  Future<void>  addTrack(String roomId, int trackId) async {}

  @override
  Future<void>  removeTrack(String roomId, int trackId) async {}

  @override
  Future<void>  reorderTrack(
    String roomId,
    String trackId,
    double newPosition,
  ) async {}

  @override
  Future<Map<String, dynamic>>  searchTrack(
    String query
  ) async {
    return {
      "data": {
        "items": [
          {
            'id': '1',
            'title': 'fakeTitle1',
            'artist': 'fakeArtist1',
            'duration': 200
          },
          {
            'id': '2',
            'title': 'fakeTitle2',
            'artist': 'fakeArtist2',
            'duration': 200
          },
          {
            'id': '3',
            'title': 'fakeTitle3',
            'artist': 'fakeArtist3',
            'duration': 200
          },
          {
            'id': '4',
            'title': 'fakeTitle4',
            'artist': 'fakeArtist4',
            'duration': 200
          },
          {
            'id': '5',
            'title': 'fakeTitle5',
            'artist': 'fakeArtist5',
            'duration': 200
          },
          {
            'id': '6',
            'title': 'fakeTitle6',
            'artist': 'fakeArtist6',
            'duration': 200
          },
          {
            'id': '7',
            'title': 'fakeTitle7',
            'artist': 'fakeArtist7',
            'duration': 200
          },
          {
            'id': '8',
            'title': 'fakeTitle8',
            'artist': 'fakeArtist8',
            'duration': 200
          },
        ]
      }
    };
  }

  @override
  Future<void> startTrack(Track newTrack, Duration position) async {}

  @override
  Future<Track?> getTrack(int trackId) async {}

  @override
  Future<void> createChannel(String roomId, String token) async {}

  @override
  Future<void> deleteChannel() async {}

  @override
  Future<String> getStreamUrl(int trackId) async {
    return "fakeStreamUrl";
  }
}
