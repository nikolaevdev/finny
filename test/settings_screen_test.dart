import 'package:finny/features/game/application/game_state_provider.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:finny/features/game/domain/game_state_repository.dart';
import 'package:finny/features/profile/application/local_profile_provider.dart';
import 'package:finny/features/profile/domain/player_profile.dart';
import 'package:finny/features/profile/domain/profile_repository.dart';
import 'package:finny/features/pet/domain/pet.dart';
import 'package:finny/features/pet/domain/pet_appearance.dart';
import 'package:finny/features/settings/application/app_settings_provider.dart';
import 'package:finny/features/settings/domain/app_settings.dart';
import 'package:finny/features/settings/domain/app_settings_repository.dart';
import 'package:finny/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSettingsRepository implements AppSettingsRepository {
  AppSettings value = const AppSettings();

  @override
  AppSettings load() => value;

  @override
  Future<void> save(AppSettings settings) async => value = settings;
}

class _FakeGameRepository implements GameStateRepository {
  _FakeGameRepository(this.state);

  GameState? state;

  @override
  Future<void> delete() async => state = null;

  @override
  GameState? load() => state;

  @override
  Future<void> save(GameState state) async => this.state = state;
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.profile);

  PlayerProfile? profile;

  @override
  Future<void> delete() async => profile = null;

  @override
  PlayerProfile? load() => profile;

  @override
  Future<void> save(PlayerProfile profile) async => this.profile = profile;
}

PlayerProfile _profile() => PlayerProfile(
      playerName: 'Игрок',
      demoMode: false,
      pet: const Pet(
        name: 'Финни',
        appearance: PetAppearance(colorIndex: 0, earsIndex: 0, patternIndex: 0),
      ),
      createdAt: DateTime.utc(2026, 9, 26),
    );

void main() {
  testWidgets('sound setting is persisted', (tester) async {
    final settingsRepository = _FakeSettingsRepository();
    final profile = _profile();
    final game = GameState.initial(demoMode: false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsRepositoryProvider.overrideWithValue(settingsRepository),
          initialAppSettingsProvider.overrideWithValue(const AppSettings()),
          profileRepositoryProvider.overrideWithValue(_FakeProfileRepository(profile)),
          initialProfileProvider.overrideWithValue(profile),
          gameStateRepositoryProvider.overrideWithValue(_FakeGameRepository(game)),
          initialGameStateProvider.overrideWithValue(game),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Настройки'), findsOneWidget);
    await tester.tap(find.text('Звуки интерфейса'));
    await tester.pumpAndSettle();

    expect(settingsRepository.value.soundEnabled, isFalse);
  });

  testWidgets('game progress reset requires confirmation', (tester) async {
    final settingsRepository = _FakeSettingsRepository();
    final profile = _profile();
    const progressed = GameState(
      balance: 80,
      savings: 100,
      selectedGoal: GameGoal.treeHouse,
      currentPeriod: 4,
      totalPeriods: 5,
      periodStatus: PeriodStatus.completed,
      completedTaskIds: ['budget_weekend'],
    );
    final gameRepository = _FakeGameRepository(progressed);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsRepositoryProvider.overrideWithValue(settingsRepository),
          initialAppSettingsProvider.overrideWithValue(const AppSettings()),
          profileRepositoryProvider.overrideWithValue(_FakeProfileRepository(profile)),
          initialProfileProvider.overrideWithValue(profile),
          gameStateRepositoryProvider.overrideWithValue(gameRepository),
          initialGameStateProvider.overrideWithValue(progressed),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Сбросить игровой прогресс'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Сбросить игровой прогресс'));
    await tester.pumpAndSettle();

    expect(find.text('Сбросить игровой прогресс?'), findsOneWidget);
    expect(gameRepository.state!.balance, 80);

    await tester.tap(find.widgetWithText(FilledButton, 'Сбросить'));
    await tester.pumpAndSettle();

    expect(gameRepository.state!.balance, 0);
    expect(gameRepository.state!.savings, 0);
    expect(gameRepository.state!.currentPeriod, 1);
    expect(gameRepository.state!.periodStatus, PeriodStatus.notStarted);
    expect(gameRepository.state!.completedTaskIds, isEmpty);
  });
}
