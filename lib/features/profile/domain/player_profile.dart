import 'package:flutter/foundation.dart';

import '../../pet/domain/pet.dart';

@immutable
class PlayerProfile {
  const PlayerProfile({
    required this.playerName,
    required this.demoMode,
    required this.pet,
    required this.createdAt,
  });

  static const schemaVersion = 1;

  final String playerName;
  final bool demoMode;
  final Pet pet;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
        'schemaVersion': schemaVersion,
        'playerName': playerName,
        'demoMode': demoMode,
        'pet': pet.toJson(),
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory PlayerProfile.fromJson(Map<String, Object?> json) {
    final version = json['schemaVersion'];
    if (version is! num || version.toInt() != schemaVersion) {
      throw const FormatException('Unsupported local profile version');
    }

    final rawPlayerName = json['playerName'];
    final playerName = rawPlayerName is String ? rawPlayerName.trim() : '';
    if (playerName.isEmpty) {
      throw const FormatException('Player name is missing');
    }

    final rawPet = json['pet'];
    if (rawPet is! Map) {
      throw const FormatException('Pet data is missing');
    }

    final rawCreatedAt = json['createdAt'];
    final createdAt = rawCreatedAt is String
        ? DateTime.tryParse(rawCreatedAt)
        : null;

    return PlayerProfile(
      playerName: playerName,
      demoMode: json['demoMode'] == true,
      pet: Pet.fromJson(Map<String, Object?>.from(rawPet)),
      createdAt: createdAt ?? DateTime.now().toUtc(),
    );
  }
}
