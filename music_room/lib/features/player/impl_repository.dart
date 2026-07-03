import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_room/core/model/track.dart';

class AudioPlayerRepository {
  AudioPlayerRepository({
    AudioPlayer? audioPlayer,
  }) : _audioPlayer = audioPlayer ?? AudioPlayer();

  late final AudioPlayer _audioPlayer;

  bool get isPlaying => _audioPlayer.playing;
  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;
  AudioPlayer get player => _audioPlayer;
  
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }

  Future<void>  start(Track newTrack, Duration position) async {
    await _audioPlayer.stop();

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
    await _audioPlayer.play();
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await  _audioPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }
}