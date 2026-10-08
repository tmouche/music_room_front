import 'dart:async';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/network/api_client.dart';
import 'package:music_room/core/network/api_path.dart';
import 'package:music_room/core/utils/exception.dart';

class RoomRepository {
  RoomRepository();
  
  Future<List<Room>> getRooms() async {
    final response = await ApiClient.get(ApiPath.rooms);
    if (response is List) {
      return response.map((data) => Room.fromJson(data)).toList();
    }
    return [];
  }

  Future<List<Room>> refreshRooms() async {
    return await getRooms();
  }

  Future<Room> createRoom() async {
    final response = await ApiClient.post(ApiPath.rooms);
    return Room.fromJson(response);
  }

  Future<void> joinRoom(String roomId) async {}

  Future<void> leaveRoom(String roomId) async {}

  Future<void> privatizeRoom(String roomId) async {
    await ApiClient.post(ApiPath.roomsPrivatize(roomId));
  }

  Future<void> publishRoom(String roomId) async {
    await ApiClient.post(ApiPath.roomsPublish(roomId));
  }

  Future<void> disableLicenceRoom(String roomId) async {
    await ApiClient.post(ApiPath.roomsLicenceDisable(roomId));
  }

  Future<void> enableLicenceRoom(String roomId) async {
    await ApiClient.post(ApiPath.roomsLicenceEnable(roomId));
  }

  Future<void> transferOwnershipRoom(String roomId, String newOwnerId) async {
    await ApiClient.post(
      ApiPath.roomsOwnershipTransfert(roomId),
      body: {'new_owner_id': newOwnerId}
    );
  }

  Future<void> addTrack(String roomId, int trackId) async {
    await ApiClient.post(
      ApiPath.roomsTrackManage(roomId),
      body: {'track_id': trackId}
    );
  }

  Future<void> removeTrack(String roomId, int trackId) async {
    await ApiClient.delete(
      ApiPath.roomsTrackManage(roomId),
      body: {'id': trackId}
    );
  }

  Future <void> reorderTrack(
    String roomId,
    String itemId,
    double newPosition,
  ) async {
    await ApiClient.patch(
      ApiPath.roomsTrackManage(roomId),
      body: {'id': itemId, 'new_position': newPosition}
    );
  }

  Future<Map<String, dynamic>> searchTrack(
    String query
  ) async {
    final encodedQuery = Uri.encodeComponent(query);
    final response = await ApiClient.get(ApiPath.hifiSearchTrack(encodedQuery));
    return response;
  }

  Future<Track?> getTrack(int trackId) async {
    final response = await ApiClient.get(ApiPath.hifiSearchTrack(trackId.toString()));
    if (response == null) return null;
    return Track.fromJson(response);
  }

  Future<String> getStreamUrl(int trackId) async {
    final response = await ApiClient.get(ApiPath.hifiTrackStream(trackId.toString()));
    final streamUrl = response['stream_url'] as String?;
    if (streamUrl == null || streamUrl.isEmpty) {
      throw StreamException('No stream Url found to track n*$trackId');
    }
    return streamUrl;
  }
}