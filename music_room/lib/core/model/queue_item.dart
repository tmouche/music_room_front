import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/model/track_cache.dart';

class QueueItem {
  final String _id;
  final String _roomId;
  final String _trackId;
  final double _position;
  final Track _track;

  QueueItem({
    required this._id,
    required this._roomId,
    required this._trackId,
    required this._position,
    Track? track,
  }) : _track = track ?? getCachedTrack(_trackId);

  String get id => _id;
  String get roomId => _roomId;
  String get trackId => _trackId;
  double get position => _position;
  Track get track => _track;

  factory QueueItem.fromJson(Map<String, dynamic> json) {
    return QueueItem(
      id: json['id'],
      roomId: json['room_id'],
      trackId: json['track_id'],
      position: json['position'].toDouble(),
    );
  }
}
