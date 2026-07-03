import 'package:flutter/material.dart';
import 'package:music_room/core/model/queue_item.dart';
import 'package:music_room/core/model/room_user.dart';
import 'package:music_room/core/model/track.dart';

class Room {
  Room({
    required this._id,
    required this._name,
    required this._owner,
    this._isPublic = true,
    this._isLicensed = false,
    this._listeners = const [],
    this._positionAtLastSync = Duration.zero,
    this._queue = const [],
    this._status = 0,
    this._currentTrack,
    this._gradientColor,
    DateTime? updatedAt,
  }) : _updatedAt = updatedAt ?? DateTime.now().toUtc();

  final String          _id;
  final String          _name;
  final String          _owner;
  final bool            _isPublic;
  final bool            _isLicensed;
  final List<RoomUser>  _listeners;
  final Duration        _positionAtLastSync;
  final List<QueueItem> _queue;
  final int             _status;
  final Track?          _currentTrack;
  final List<Color>?    _gradientColor;
  final DateTime?       _updatedAt;

  String get id => _id;
  String get name => _name;
  Track? get currentTrack => _currentTrack;
  String get owner => _owner;
  List<QueueItem> get queue => _queue;
  List<Color>? get gradientColor => _gradientColor;
  List<RoomUser> get listeners => _listeners;
  bool get isPublic => _isPublic;
  bool get isLicensed => _isLicensed;


  int get people => _listeners.length;

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'] ?? 'Unnamed Room',
      owner: json['owner_id'],
      isPublic: json['is_public'] ?? true,
      isLicensed: json['has_license'] ?? json['is_licensed'] ?? false,
      status: (json['is_playing'] == true) ? 1 : 0,
      positionAtLastSync: Duration(
        milliseconds: (json['current_position']?.toDouble() ?? 0.0).toInt(),
      ),
    );
  }

  Room copyWith({
    String? id,
    String? name,
    String? owner,
    bool? isPublic,
    bool? isLicensed,
    List<RoomUser>? listeners,
    Duration? positionAtLastSync,
    List<QueueItem>? queue,
    int? status,
    Track? currentTrack,
    List<Color>? gradientColor,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? _id,
      name: name ?? _name,
      owner: owner ?? _owner,
      isPublic: isPublic ?? _isPublic,
      isLicensed: isLicensed ?? _isLicensed,
      listeners: listeners ?? _listeners,
      positionAtLastSync: positionAtLastSync ?? _positionAtLastSync,
      queue: queue ?? _queue,
      status: status ?? _status,
      currentTrack: currentTrack ?? _currentTrack,
      gradientColor: gradientColor ?? _gradientColor,
      updatedAt: updatedAt ?? _updatedAt,
    );
  }

  Duration get currentPosition {
    if (_currentTrack == null) return Duration.zero;
    if (_status != 1) return _positionAtLastSync;

    final now = DateTime.now();
    final elapsed = now.difference(_updatedAt!);
    final calculatedPos = _positionAtLastSync + elapsed;

    if (calculatedPos > _currentTrack.duration) {
      return _currentTrack.duration;
    }
    return calculatedPos;
  }

}
