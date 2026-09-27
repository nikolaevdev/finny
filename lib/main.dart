import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/game/application/game_state_provider.dart';
import 'features/game/data/shared_preferences_game_state_repository.dart';
import 'features/game/domain/game_state.dart';
import 'features/profile/application/local_profile_provider.dart';
import 'features/profile/data/shared_preferences_profile_repository.dart';
import 'features/settings/application/app_settings_provider.dart';
import 'features/settings/data/shared_preferences_app_settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();

  final profileRepository = SharedPreferencesProfileRepository(preferences);
  final initialProfile = profileRepository.load();

  final gameStateRepository = SharedPreferencesGameStateRepository(preferences);
  final storedGameState = gameStateRepository.load();
  final initialGameState = initialProfile == null
      ? null
      : storedGameState ?? GameState.initial(demoMode: initialProfile.demoMode);

  final appSettingsRepository = SharedPreferencesAppSettingsRepository(
    preferences,
  );
  final initialAppSettings = appSettingsRepository.load();

  runApp(
    ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(profileRepository),
        initialProfileProvider.overrideWithValue(initialProfile),
        gameStateRepositoryProvider.overrideWithValue(gameStateRepository),
        initialGameStateProvider.overrideWithValue(initialGameState),
        appSettingsRepositoryProvider.overrideWithValue(appSettingsRepository),
        initialAppSettingsProvider.overrideWithValue(initialAppSettings),
      ],
      child: FinniApp(hasLocalProfile: initialProfile != null),
    ),
  );
}
