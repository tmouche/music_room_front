import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_room/core/model/track.dart';

class HifiRepository {
  HifiRepository();

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool get isPlaying => _audioPlayer.playing;
  Duration get position => _audioPlayer.position;
  Duration get duration => _audioPlayer.duration ?? Duration.zero;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream.distinct();
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration> get durationStream => _audioPlayer.durationStream.map((s) => s ?? Duration.zero);

  Future<void>  setTrack(Track newTrack, Duration position) async {
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
    await seekTrack(position);
  }

  Future<void> resumeTrack() async {
    await _audioPlayer.play();
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
}