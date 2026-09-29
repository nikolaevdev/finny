import 'dart:async';

import 'package:flutter/services.dart';

enum AudioCue { tap, success, warning, purchase }

enum MusicScene { main, calm, shop }

/// Audio lives on Android so no media package or network permission is needed.
/// A missing native channel (for example in widget tests) is harmless.
class FinniAudio {
  FinniAudio._();

  static final instance = FinniAudio._();
  static const _channel = MethodChannel('ru.mishanikolaev.finny/audio');

  bool _effectsEnabled = true;
  bool? _lastMusicEnabled;
  bool? _lastEffectsEnabled;
  MusicScene? _lastMusicScene;

  Future<void> configure({
    required bool effectsEnabled,
    required bool musicEnabled,
  }) async {
    _effectsEnabled = effectsEnabled;
    if (_lastEffectsEnabled == effectsEnabled &&
        _lastMusicEnabled == musicEnabled) {
      return;
    }
    _lastEffectsEnabled = effectsEnabled;
    _lastMusicEnabled = musicEnabled;
    try {
      await _channel.invokeMethod<void>('configure', {
        'effects': effectsEnabled,
        'music': musicEnabled,
      });
    } on MissingPluginException {
      // Widget tests and unsupported host platforms have no Android player.
    } on PlatformException {
      // Audio is optional; gameplay must keep working if a device rejects it.
    }
  }

  Future<void> setMusicScene(MusicScene scene) async {
    if (_lastMusicScene == scene) return;
    _lastMusicScene = scene;
    try {
      await _channel.invokeMethod<void>('setMusicScene', scene.name);
    } on MissingPluginException {
      // Widget tests and unsupported host platforms have no Android player.
    } on PlatformException {
      // Navigation must not fail if the device rejects an audio change.
    }
  }

  void play(AudioCue cue) {
    if (!_effectsEnabled) return;
    unawaited(_play(cue));
  }

  Future<void> _play(AudioCue cue) async {
    try {
      await _channel.invokeMethod<void>('playEffect', cue.name);
    } on MissingPluginException {
      // No audio backend in widget tests or on unsupported host platforms.
    } on PlatformException {
      // Never interrupt a financial action due to a sound failure.
    }
  }
}
