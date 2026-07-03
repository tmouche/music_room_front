import 'package:music_room/core/model/room.dart';
import 'package:music_room/data/fake_room.dart';
import 'package:music_room/features/room/impl_repository.dart';

class MockRoomRepository extends RoomRepository{

  @override
  Future<List<Room>> getRooms() async {
    await Future.delayed(Duration(seconds: 2));
    return [fakeRoom1, fakeRoom2, fakeRoom3, fakeRoom4, fakeRoom5, fakeRoom6, fakeRoom7];
    return [];
  }

  @override
  Future<Room> createRoom() async {
    final id = nextId.toString();
    nextId += 1;
    return Room(
      id: id,
      name: 'Fake Vibes $id',
      owner: 'me',
    );
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
  Future<void>  transferOwnership(String roomId, String newOwnerId) async {}

  @override
  Future<String> getStreamUrl(String trackId) async {
    return "fakeStreamUrl";
  }
}