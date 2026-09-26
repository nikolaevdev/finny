import 'package:finny/features/adult/presentation/adult_screen.dart';
import 'package:finny/features/game/application/game_state_provider.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:finny/features/game/domain/game_state_repository.dart';
import 'package:finny/features/pet/domain/pet.dart';
import 'package:finny/features/pet/domain/pet_appearance.dart';
import 'package:finny/features/profile/application/local_profile_provider.dart';
import 'package:finny/features/profile/domain/player_profile.dart';
import 'package:finny/features/profile/domain/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  testWidgets('demo profile can be reset after confirmation', (tester) async {
    final profile = PlayerProfile(
      playerName: 'Эксперт',
      demoMode: true,
      pet: const Pet(
        name: 'Финни',
        appearance: PetAppearance(colorIndex: 0, earsIndex: 0, patternIndex: 0),
      ),
      createdAt: DateTime.utc(2026, 9, 26),
    );
    const progressed = GameState(
      balance: 435,
      savings: 130,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 5,
      totalPeriods: 5,
      periodStatus: PeriodStatus.completed,
      completedTaskIds: ['budget_weekend', 'savings_gift'],
    );
    final gameRepository = _FakeGameRepository(progressed);
    final profileRepository = _FakeProfileRepository(profile);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateRepositoryProvider.overrideWithValue(gameRepository),
          initialGameStateProvider.overrideWithValue(progressed),
          profileRepositoryProvider.overrideWithValue(profileRepository),
          initialProfileProvider.overrideWithValue(profile),
        ],
        child: const MaterialApp(home: AdultScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Зачем нужен Финни'), findsOneWidget);
    expect(find.text('Демонстрационный режим'), findsOneWidget);

    await tester.ensureVisible(find.text('Сбросить демо-прогресс'));
    await tester.tap(find.text('Сбросить демо-прогресс'));
    await tester.pumpAndSettle();

    expect(find.text('Сбросить демо-прогресс?'), findsOneWidget);
    expect(gameRepository.state!.balance, 435);

    await tester.tap(find.widgetWithText(FilledButton, 'Сбросить'));
    await tester.pumpAndSettle();

    expect(gameRepository.state!.currentPeriod, 1);
    expect(gameRepository.state!.periodStatus, PeriodStatus.notStarted);
    expect(gameRepository.state!.balance, 0);
    expect(gameRepository.state!.savings, 120);
    expect(gameRepository.state!.completedTaskIds, isEmpty);
  });
}
