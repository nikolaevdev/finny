import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/player_profile.dart';
import '../domain/profile_repository.dart';

class SharedPreferencesProfileRepository implements ProfileRepository {
  SharedPreferencesProfileRepository(this._preferences);

  static const _profileKey = 'finni.local_profile.v1';

  final SharedPreferences _preferences;

  @override
  PlayerProfile? load() {
    final rawProfile = _preferences.getString(_profileKey);
    if (rawProfile == null || rawProfile.isEmpty) return null;

    try {
      final decoded = jsonDecode(rawProfile);
      if (decoded is! Map) return null;

      return PlayerProfile.fromJson(
        Map<String, Object?>.from(decoded),
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Future<void> save(PlayerProfile profile) async {
    final saved = await _preferences.setString(
      _profileKey,
      jsonEncode(profile.toJson()),
    );

    if (!saved) {
      throw StateError('Не удалось сохранить локальный профиль');
    }
  }

  @override
  Future<void> delete() async {
    final removed = await _preferences.remove(_profileKey);
    if (!removed && _preferences.containsKey(_profileKey)) {
      throw StateError('Не удалось удалить локальный профиль');
    }
  }
}
