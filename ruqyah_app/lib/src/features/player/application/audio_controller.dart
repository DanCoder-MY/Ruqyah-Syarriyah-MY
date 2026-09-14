import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../library/domain/dua.dart';

/// Immutable snapshot of playback + user-controlled options.
class AudioUiState {
  const AudioUiState({
    this.dua,
    this.speed = 1.0,
    this.loopCount = 1,
    this.abStart,
    this.abEnd,
    this.sleepTimerEnd,
  });

  final Dua? dua;
  final double speed;

  /// 0 means infinite loop.
  final int loopCount;

  final Duration? abStart;
  final Duration? abEnd;
  final DateTime? sleepTimerEnd;

  bool get hasAbRepeat => abStart != null && abEnd != null;

  AudioUiState copyWith({
    Dua? dua,
    double? speed,
    int? loopCount,
    Duration? abStart,
    Duration? abEnd,
    bool clearAb = false,
    DateTime? sleepTimerEnd,
    bool clearSleep = false,
  }) {
    return AudioUiState(
      dua: dua ?? this.dua,
      speed: speed ?? this.speed,
      loopCount: loopCount ?? this.loopCount,
      abStart: clearAb ? null : (abStart ?? this.abStart),
      abEnd: clearAb ? null : (abEnd ?? this.abEnd),
      sleepTimerEnd: clearSleep ? null : (sleepTimerEnd ?? this.sleepTimerEnd),
    );
  }
}

class AudioController extends StateNotifier<AudioUiState> {
  AudioController() : super(const AudioUiState()) {
    _positionSub = player.positionStream.listen(_onPosition);
  }

  final AudioPlayer player = AudioPlayer();
  StreamSubscription<Duration>? _positionSub;
  Timer? _sleepTimer;

  void _onPosition(Duration pos) {
    // A-B repeat: seek back to A once we pass B.
    if (state.hasAbRepeat && pos >= state.abEnd!) {
      player.seek(state.abStart);
    }
  }

  Future<void> playDua(Dua dua, BuildContext context) async {
    state = state.copyWith(dua: dua, clearAb: true);
    final source = _sourceFor(dua);
    if (source == null) return;
    try {
      await player.setAudioSource(source);
      await player.setSpeed(state.speed);
      await _applyLoop();
      await player.play();
      if (context.mounted) context.pushNamed('player');
    } catch (e) {
      debugPrint('Audio load failed: $e');
    }
  }

  AudioSource? _sourceFor(Dua dua) {
    final tag = MediaItem(
      id: dua.id,
      title: dua.titleFor('en'),
      album: "Ruqyah Syar'iyyah",
    );
    if (dua.audioAsset != null) {
      return AudioSource.asset(dua.audioAsset!, tag: tag);
    }
    if (dua.audioUrl != null) {
      return AudioSource.uri(Uri.parse(dua.audioUrl!), tag: tag);
    }
    return null;
  }

  Future<void> _applyLoop() async {
    await player.setLoopMode(
      state.loopCount == 0 ? LoopMode.one : LoopMode.off,
    );
  }

  Future<void> togglePlay() async {
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> setSpeed(double speed) async {
    state = state.copyWith(speed: speed);
    await player.setSpeed(speed);
  }

  Future<void> cycleLoop() async {
    // 1 -> infinite (0) -> 1
    final next = state.loopCount == 1 ? 0 : 1;
    state = state.copyWith(loopCount: next);
    await _applyLoop();
  }

  /// Tap once to set point A, tap again to set point B. Tapping while an
  /// A-B loop is active starts a fresh A point.
  void markAbPoint(Duration position) {
    if (state.abStart == null || state.hasAbRepeat) {
      state = AudioUiState(
        dua: state.dua,
        speed: state.speed,
        loopCount: state.loopCount,
        abStart: position,
        sleepTimerEnd: state.sleepTimerEnd,
      );
    } else if (position > state.abStart!) {
      state = state.copyWith(abEnd: position);
    }
  }

  void clearAb() => state = state.copyWith(clearAb: true);

  void setSleepTimer(Duration? duration) {
    _sleepTimer?.cancel();
    if (duration == null) {
      state = state.copyWith(clearSleep: true);
      return;
    }
    state = state.copyWith(sleepTimerEnd: DateTime.now().add(duration));
    _sleepTimer = Timer(duration, () {
      player.pause();
      state = state.copyWith(clearSleep: true);
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _sleepTimer?.cancel();
    player.dispose();
    super.dispose();
  }
}

final audioControllerProvider =
    StateNotifierProvider<AudioController, AudioUiState>((ref) {
  return AudioController();
});

/// Combined position + duration + playing state for the UI.
class PlaybackProgress {
  const PlaybackProgress(this.position, this.buffered, this.total, this.playing);
  final Duration position;
  final Duration buffered;
  final Duration total;
  final bool playing;
}

final playbackProgressProvider = StreamProvider<PlaybackProgress>((ref) {
  final player = ref.watch(audioControllerProvider.notifier).player;
  return player.positionStream.map((pos) => PlaybackProgress(
        pos,
        player.bufferedPosition,
        player.duration ?? Duration.zero,
        player.playing,
      ));
});

final playingStateProvider = StreamProvider<bool>((ref) {
  final player = ref.watch(audioControllerProvider.notifier).player;
  return player.playingStream;
});
