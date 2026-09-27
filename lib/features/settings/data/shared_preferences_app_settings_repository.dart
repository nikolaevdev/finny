import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';
import '../domain/app_settings_repository.dart';

class SharedPreferencesAppSettingsRepository implements AppSettingsRepository {
  SharedPreferencesAppSettingsRepository(this._preferences);

  static const _settingsKey = 'finni.app_settings.v1';

  final SharedPreferences _preferences;

  @override
  AppSettings load() {
    final rawSettings = _preferences.getString(_settingsKey);
    if (rawSettings == null || rawSettings.isEmpty) {
      return const AppSettings();
    }

    try {
      final decoded = jsonDecode(rawSettings);
      if (decoded is! Map) return const AppSettings();
      return AppSettings.fromJson(Map<String, Object?>.from(decoded));
    } on FormatException {
      return const AppSettings();
    } on TypeError {
      return const AppSettings();
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    final saved = await _preferences.setString(
      _settingsKey,
      jsonEncode(settings.toJson()),
    );

    if (!saved) {
      throw StateError('Не удалось сохранить настройки');
    }
  }
}
