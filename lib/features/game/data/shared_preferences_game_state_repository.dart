import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/game_state.dart';
import '../domain/game_state_repository.dart';

class SharedPreferencesGameStateRepository implements GameStateRepository {
  SharedPreferencesGameStateRepository(this._preferences);

  static const _gameStateKey = 'finni.game_state.v1';

  final SharedPreferences _preferences;

  @override
  GameState? load() {
    final rawState = _preferences.getString(_gameStateKey);
    if (rawState == null || rawState.isEmpty) return null;

    try {
      final decoded = jsonDecode(rawState);
      if (decoded is! Map) return null;

      return GameState.fromJson(
        Map<String, Object?>.from(decoded),
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Future<void> save(GameState state) async {
    final saved = await _preferences.setString(
      _gameStateKey,
      jsonEncode(state.toJson()),
    );

    if (!saved) {
      throw StateError('Не удалось сохранить игровое состояние');
    }
  }

  @override
  Future<void> delete() async {
    final removed = await _preferences.remove(_gameStateKey);
    if (!removed && _preferences.containsKey(_gameStateKey)) {
      throw StateError('Не удалось удалить игровое состояние');
    }
  }
}
