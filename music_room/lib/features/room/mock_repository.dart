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