import 'package:just_audio/just_audio.dart';
import 'package:music_room/core/model/track.dart';

class HifiState {
  const HifiState({
    this._duration = Duration.zero,
    this._position = Duration.zero,
    this._volume = 0.5,
    this._playerErrorMessage,
    this._playerState,
  });

  final Duration      _duration;
  final Duration      _position;
  final double        _volume;
  final String?       _playerErrorMessage;
  final PlayerState?  _playerState;
  
  Duration get duration => _duration;
  bool get isPlaying => _playerState?.playing ?? false;
  Duration get position => _position;
  double get volume => _volume;
  String? get playerErrorMessage => _playerErrorMessage;
  PlayerState? get playerState => _playerState;
  ProcessingState? get processState => _playerState?.processingState;

  static const _unset = Object();

  HifiState copyWith({
    Duration? duration,
    Duration? position,
    double? volume,
    Object? playerErrorMessage = _unset,
    PlayerState? playerState,
    Track? track,
  }) {
    return HifiState(
      duration: duration ?? _duration,
      position: position ?? _position,
      volume: volume ?? _volume,
      playerErrorMessage: identical(playerErrorMessage, _unset) ? _playerErrorMessage : playerErrorMessage as String?,
      playerState: playerState ?? _playerState,
    );
  }
}