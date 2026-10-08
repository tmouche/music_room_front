import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_room/core/model/track.dart';
import 'package:music_room/core/storage/settings_strorage.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/features/hifi/impl_repository.dart';
import 'package:music_room/features/hifi/provider.dart';
import 'package:music_room/features/hifi/state.dart';

class HifiController extends Notifier<HifiState> with WidgetsBindingObserver {
  StreamSubscription<PlayerState>?  _playerStateSubscription;
  StreamSubscription<Duration>?     _playerDurationSubscription;
  StreamSubscription<Duration>?     _playerPositionSubscription;

  HifiRepository get _repo => ref.read(hifiRepositoryProvider);

  @override
  HifiState build() {
    final initialState = HifiState();
    _loadPersistedVolume();
    return initialState;
  }

  Future<void> _loadPersistedVolume() async {
    final savedVolume = (await SettingsStrorage.getVolume())?.clamp(0.0, 1.0);
    if (savedVolume != null) {
      await _repo.setVolume(savedVolume);
      state = state.copyWith(volume: savedVolume);
    }
  }

  Future<void> closeSubscription() async {
    await _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    await _playerDurationSubscription?.cancel();
    _playerDurationSubscription = null;
    await _playerPositionSubscription?.cancel();
    _playerPositionSubscription = null;
  }

  void openSubscription() async {
    _playerStateSubscription = _repo.playerStateStream.listen(
      (playerState) => state = state.copyWith(playerState: playerState)
    );
    _playerDurationSubscription = _repo.durationStream.listen(
      (duration) => state = state.copyWith(duration: duration)
    );
    _playerPositionSubscription = _repo.positionStream.listen(
      (position) => state = state.copyWith(position: position)
    );
  }

  Future<void>  setTrack(Track newTrack, Duration position) async {
    try {
      await _repo.setTrack(newTrack, position);
    } catch (e) {
      state = state.copyWith(playerErrorMessage: "Player's error: impossible to laod the track");
    }
  }

  void clearPlayerErrorMessage() {
    state = state.copyWith(playerErrorMessage: null);
  }

  void  resumeTrack() async {
    unawaited(_repo.resumeTrack());
  }

  void pauseTrack() async {
    unawaited(_repo.pauseTrack());
  }

  static const Duration _playerTimeout = Duration(seconds: 5);

  Future<void> stopTrack() async {
    try {
      await _repo.stopTrack().timeout(_playerTimeout);
    } on TimeoutException {
      logger.warning('Player stop timed out');
    }
  }

  Future<void> seekTrack(Duration position) async {
    try {
      await _repo.seekTrack(position).timeout(_playerTimeout);
    } on TimeoutException {
      logger.warning('Player seek timed out');
    }
  }

  Future<void> setVolume(double volume) async {
    volume = volume.clamp(0.0, 1.0);
    state = state.copyWith(volume: volume);
    await SettingsStrorage.saveVolume(volume);
    await _repo.setVolume(volume);
  }
}