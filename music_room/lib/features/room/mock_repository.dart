import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/model/room.dart';
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
    return allRooms;
  }

  @override
  Future<List<Room>?> refreshRooms() async {
    return allRooms;
  }

  @override
  Future<Room> createRoom() async {
    final authState = _ref.read(authProvider);
    
    final id = (allRooms.length + 1).toString();
    final newRoom = Room(
      id: id,
      name: 'Fake Vibes $id',
      owner: authState.user!.username,
    );
    allRooms.add(newRoom);
    return newRoom;
  }

  @override
  Future<void>  addTrack(String roomId, String trackId) async {}

  @override
  Future<void>  removeTrack(String roomId, String trackId) async {}

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
  Future<void>  privatize(String roomId) async {}

  @override
  Future<void>  publish(String roomId) async {}

  @override
  Future<void>  disableLicence(String roomId) async {}

  @override
  Future<void>  enableLicence(String roomId) async {}

  @override
  Future<void>  transferOwnership(String roomId, String newOwnerId) async {
      print('Trasnfert ownerShip Mock');
  }

  @override
  Future<String> getStreamUrl(String trackId) async {
    return "fakeStreamUrl";
  }
}