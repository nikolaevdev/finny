import 'package:flutter/foundation.dart';

@immutable
class AppSettings {
  const AppSettings({
    this.soundEnabled = true,
    this.animationsEnabled = true,
  });

  final bool soundEnabled;
  final bool animationsEnabled;

  AppSettings copyWith({
    bool? soundEnabled,
    bool? animationsEnabled,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
    );
  }

  Map<String, Object?> toJson() => {
        'soundEnabled': soundEnabled,
        'animationsEnabled': animationsEnabled,
      };

  factory AppSettings.fromJson(Map<String, Object?> json) {
    return AppSettings(
      soundEnabled: json['soundEnabled'] is bool
          ? json['soundEnabled'] as bool
          : true,
      animationsEnabled: json['animationsEnabled'] is bool
          ? json['animationsEnabled'] as bool
          : true,
    );
  }
}
