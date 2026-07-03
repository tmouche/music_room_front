
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/features/player/impl_repository.dart';
import 'package:music_room/features/player/provider.dart';
import 'package:music_room/features/player/state.dart';
import 'package:music_room/features/web_socket/controller.dart';
import 'package:music_room/features/web_socket/provider.dart';

class AudioPlayerController extends Notifier<AudioPlayerState> {
  static const String _eventPlay = 'Play';
  static const String _eventPause = 'Pause';
  static const String _eventSeekTo = 'SeekTo';
  static const String _eventNextTrack = 'NextTrack';

  @override
  AudioPlayerState build() {
    _repo = ref.read(audioPlayerRepositoryProvider);
    _webSocketController = ref.read(webSocketProvider.notifier);
    return AudioPlayerState();    
  }

  late final AudioPlayerRepository  _repo;
  late final WebSocketController    _webSocketController;

  bool get isTrackStarted => state.currentTrack != null;
  bool get isPlaying => _repo.isPlaying;
  Duration get position => _repo.position;


  Future<void>  start(Track newTrack, Duration position) async {
    await _repo.start(newTrack, position);
    state = state.copyWith(currentTrack: newTrack);
  }

  Future<void>  play() async {
    if (!_repo.isPlaying) {
      _webSocketController.send(_eventPlay, {
        'position': _repo.position.inMilliseconds,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
      await _repo.play();
    } else {
      await _repo.pause();
    }
  }

  Future<void> pause() async {
    if (_repo.isPlaying) {
      await play();
    } else {
      _webSocketController.send(_eventPause, {
          'position': _repo.position.inMilliseconds,
        });
      await _repo.pause();
    }
  }

  Future<void> stop() async {
    await  _repo.stop();
    state = state.copyWith(currentTrack: null);
  }

  Future<void> seek(Duration position) async {
    _webSocketController.send(_eventSeekTo, {
      'position': position.inMilliseconds,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
    await _repo.seek(position);
  }

  Future<void> skipNext() async {
    _webSocketController.send(_eventNextTrack, {
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
  }


  Future<void> skipPrev() async {
    await seek(Duration());
  }
}