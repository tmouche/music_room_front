import 'package:music_room/core/model/track.dart';

class AudioPlayerState {
  const AudioPlayerState({
    this._currentTrack
  });

  final Track?  _currentTrack;

  Track? get currentTrack => _currentTrack;

  AudioPlayerState copyWith({
    Track? currentTrack
  }) {
    return AudioPlayerState(
      currentTrack: currentTrack ?? _currentTrack,
    );
  }
}
