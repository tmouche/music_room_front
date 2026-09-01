import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/network/api_client.dart';
import 'package:music_room/core/network/api_path.dart';
import 'package:music_room/core/storage/settings_strorage.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RoomRepository {
  RoomRepository();

  final AudioPlayer _audioPlayer = AudioPlayer();
  WebSocketChannel? _channel;

  WebSocketChannel? get channel => _channel;
  bool get isPlaying => _audioPlayer.playing;
  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;
  AudioPlayer get player => _audioPlayer;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream.distinct();
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration> get durationStream => _audioPlayer.durationStream.map((s) => s ?? Duration.zero);
  
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    await deleteChannel();
  }

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

  // Future<List<Room>> getRooms() async {
  //   final response = await ApiClient.get(ApiPath.rooms);
  //   final random = Random();
  //   if (response is List) {
  //     return Future.wait(response.map((data) async {
  //       Room newRoom = Room.fromJson(data);
  //       final currentTrackId = data['current_track'];
  //       if (currentTrackId != null) {
  //         print('SEARCHING for $currentTrackId FOR TYPE ${currentTrackId.runtimeType}');
  //         final currentTrack = await getTrack(currentTrackId);
  //         newRoom = newRoom.copyWith(currentTrack: currentTrack);
  //       }
  //       return newRoom.copyWith(gradientColor: Coloring.cardColors[random.nextInt(Coloring.cardColors.length)]);
  //     }));
  //   }
  //   return [];
  // }

  Future<List<Room>> refreshRooms() async {
    return await getRooms();
  }

  Future<Room> createRoom() async {
    final response = await ApiClient.post(ApiPath.rooms);
    return Room.fromJson(response);
  }

  Future<void> joinRoom(String roomId) async {
  }

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

  Future<void> startTrack(Track newTrack, Duration position) async {
    await stopTrack();
    final audioSource = AudioSource.uri(
      Uri.parse(newTrack.streamUrl),
      tag: MediaItem(
        id: newTrack.id.toString(),
        title: newTrack.title,
        artist: newTrack.artist,
        artUri: newTrack.imageUrl != null ? Uri.parse(newTrack.imageUrl!) : null,
      ),
    );
    await _audioPlayer.setAudioSource(audioSource);
    await _audioPlayer.seek(position);
    await playTrack();
  }

  Future<void> playTrack() async {
    unawaited(_audioPlayer.play().catchError((Object e) {
      logger.error('Audio playback ended with error', error: e);
    }));
  }

  Future<void> pauseTrack() async {
    await _audioPlayer.pause();
  }

  Future<void> stopTrack() async {
    await  _audioPlayer.stop();
  }

  Future<void> seekTrack(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<Track?> getTrack(int trackId) async {
    final response = await ApiClient.get(ApiPath.hifiSearchTrack(trackId.toString()));
    if (response == null) return null;
    return Track.fromJson(response);
  }

  Future<void>  createChannel(String roomId, String token) async {
    final uri = Uri.parse(
      '${ApiClient.baseUrl.replaceFirst('http', 'ws')}${ApiPath.roomsWebSocket(roomId)}',
    ).replace(queryParameters: {'token': token});
    _channel = WebSocketChannel.connect(uri);
    await _channel!.ready;
  }

  Future<void>  deleteChannel() async {
    await _channel?.sink.close();
    _channel = null;
  }

  Future<String> getStreamUrl(int trackId) async {
    final response = await ApiClient.get(ApiPath.hifiTrackStream(trackId));
    final streamUrl = response['stream_url'] as String?;
    if (streamUrl == null || streamUrl.isEmpty) {
      throw StreamException('No stream Url found to track n*$trackId');
    }
    return streamUrl;
  }
}