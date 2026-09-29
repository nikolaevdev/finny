import 'package:flutter/foundation.dart';

@immutable
class AppSettings {
  const AppSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.animationsEnabled = true,
  });

  final bool soundEnabled;
  final bool musicEnabled;
  final bool animationsEnabled;

  AppSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? animationsEnabled,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
    );
  }

  Map<String, Object?> toJson() => {
        'soundEnabled': soundEnabled,
        'musicEnabled': musicEnabled,
        'animationsEnabled': animationsEnabled,
      };

  factory AppSettings.fromJson(Map<String, Object?> json) {
    final soundEnabled = json['soundEnabled'] is bool
        ? json['soundEnabled'] as bool
        : true;
    return AppSettings(
      soundEnabled: soundEnabled,
      // An old mute setting must also keep the newly introduced music quiet.
      musicEnabled: json['musicEnabled'] is bool
          ? json['musicEnabled'] as bool
          : soundEnabled,
      animationsEnabled: json['animationsEnabled'] is bool
          ? json['animationsEnabled'] as bool
          : true,
    );
  }
}
