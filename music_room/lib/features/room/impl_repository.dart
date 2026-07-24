import 'dart:math';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/network/api_client.dart';
import 'package:music_room/core/network/api_path.dart';
import 'package:music_room/core/utils/exception.dart';

class RoomRepository {
  RoomRepository();

  Future<List<Room>> getRooms() async {
    final response = await ApiClient.get(ApiPath.rooms);
    final random = Random();
    if (response is List) {
      return response.map((data) {
        final newRoom = Room.fromJson(data);
        return newRoom.copyWith(gradientColor: Coloring.cardColors[random.nextInt(Coloring.cardColors.length)]);
      }).toList();
    }
    return [];
  }

  Future<List<Room>?> refreshRooms() async {
    return await getRooms();
  }

  Future<Room> createRoom() async {
    final response = await ApiClient.post(ApiPath.rooms);
    return Room.fromJson(response);
  }

  Future<void> addTrack(String roomId, String trackId) async {
    await ApiClient.post(
      ApiPath.roomsTrackManage(roomId),
      body: {'track_id': trackId}
    );
  }

  Future<void> removeTrack(String roomId, String trackId) async {
    await ApiClient.delete(
      ApiPath.roomsTrackManage(roomId),
      body: {'id': trackId}
    );
  }

  Future <void> reorderTrack(
    String roomId,
    String trackId,
    double newPosition,
  ) async {
    await ApiClient.patch(
      ApiPath.roomsTrackManage(roomId),
      body: {'id': trackId, 'new_position': newPosition}
    );
  }

  Future<Map<String, dynamic>> searchTrack(
    String query
  ) async {
    final encodedQuery = Uri.encodeComponent(query);
    final response = await ApiClient.get(ApiPath.hifiSearchTrack(encodedQuery));

    return response;
  }

  Future<void> privatize(String roomId) async {
    await ApiClient.post(ApiPath.roomsPrivatize(roomId));
  }

  Future<void> publish(String roomId) async {
    await ApiClient.post(ApiPath.roomsPublish(roomId));
  }

  Future<void> disableLicence(String roomId) async {
    await ApiClient.post(ApiPath.roomsLicenceDisable(roomId));
  }

  Future<void> enableLicence(String roomId) async {
    await ApiClient.post(ApiPath.roomsLicenceEnable(roomId));
  }

  Future<void> transferOwnership(String roomId, String newOwnerId) async {
    print('Trasnfert ownerShip Impl');
    await ApiClient.post(
      ApiPath.roomsOwnershipTransfert(roomId),
      body: {'new_owner_id': newOwnerId}
    );
  }

  Future<String> getStreamUrl(String trackId) async {
    final response = await ApiClient.get(ApiPath.hifiTrackStream(trackId));
    final streamUrl = response['stream_url'] as String?;

    if (streamUrl == null || streamUrl.isEmpty) {
      throw StreamException('No stream Url found to track n*$trackId');
    }
    return streamUrl;
  }
}