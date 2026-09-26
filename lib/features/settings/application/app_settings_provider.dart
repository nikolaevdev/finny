import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_settings.dart';
import '../domain/app_settings_repository.dart';

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  throw StateError('appSettingsRepositoryProvider must be overridden at startup');
});

final initialAppSettingsProvider = Provider<AppSettings>(
  (ref) => const AppSettings(),
);

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(initialAppSettingsProvider);

  Future<void> setSoundEnabled(bool value) async {
    await _save(state.copyWith(soundEnabled: value));
  }

  Future<void> setAnimationsEnabled(bool value) async {
    await _save(state.copyWith(animationsEnabled: value));
  }

  Future<void> _save(AppSettings next) async {
    await ref.read(appSettingsRepositoryProvider).save(next);
    state = next;
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);
