import 'package:music_room/core/model/track_cache.dart';

class Track {
  final int _id;
  final String _title;
  final String _artist;
  final String? _imageUrl;
  final Duration _duration;
  final String _streamUrl;

  Track({
    required this._id,
    required this._title,
    required this._artist,
    this._imageUrl,
    required this._duration,
    this._streamUrl =
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  });

  int get id => _id;
  String get title => _title;
  String get artist => _artist;
  String? get imageUrl => _imageUrl;
  String get streamUrl => _streamUrl;
  Duration get duration => _duration;

  factory Track.fromJson(Map<String, dynamic> json) {
    String artistName = 'Unknown Artist';
    if (json['artists'] != null && (json['artists'] as List).isNotEmpty) {
      artistName = json['artists'][0]['name'] ?? 'Unknown Artist';
    }

    String? coverUrl;
    if (json['album'] != null && json['album']['cover'] != null) {
      final String cover = json['album']['cover'];
      final formattedCover = cover.replaceAll('-', '/');
      coverUrl =
          'https://resources.tidal.com/images/$formattedCover/320x320.jpg';
    }

    final track = Track(
      id: json['id'],
      title: json['title'] ?? 'Unknown Title',
      artist: artistName,
      duration: Duration(seconds: json['duration'] ?? 0),
      imageUrl: coverUrl,
    );

    cacheTrack(track);
    return track;
  }

  Track copyWith({
    int? id,
    String? title,
    String? artiste,
    String? imageUrl,
    Duration? duration,
    String? streamUrl,
  }) {
    return Track(
      id: id ?? _id,
      title: title ?? _title,
      artist: artiste ?? _artist,
      imageUrl: imageUrl ?? _imageUrl,
      duration: duration ?? _duration,
      streamUrl: streamUrl ?? _streamUrl,
    );
  }
}
