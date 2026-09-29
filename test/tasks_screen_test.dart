import 'package:finny/features/game/application/game_state_provider.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:finny/features/game/domain/game_state_repository.dart';
import 'package:finny/features/profile/application/local_profile_provider.dart';
import 'package:finny/features/profile/domain/player_profile.dart';
import 'package:finny/features/pet/domain/pet.dart';
import 'package:finny/features/pet/domain/pet_appearance.dart';
import 'package:finny/features/tasks/presentation/tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGameStateRepository implements GameStateRepository {
  _FakeGameStateRepository(this.state);
  GameState? state;

  @override
  Future<void> delete() async {
    state = null;
  }

  @override
  GameState? load() => state;

  @override
  Future<void> save(GameState state) async {
    this.state = state;
  }
}

void main() {
  testWidgets('tasks screen shows required topics and progress', (tester) async {
    const game = GameState(
      balance: 100,
      savings: 20,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 1,
      totalPeriods: 5,
      periodStatus: PeriodStatus.planned,
      completedTaskIds: ['budget_weekend'],
    );
    final repository = _FakeGameStateRepository(game);
    final profile = PlayerProfile(
      playerName: 'Игрок',
      demoMode: true,
      pet: const Pet(
        name: 'Финни',
        appearance: PetAppearance(colorIndex: 0, earsIndex: 0, patternIndex: 0),
      ),
      createdAt: DateTime.utc(2026, 9, 26),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateRepositoryProvider.overrideWithValue(repository),
          initialGameStateProvider.overrideWithValue(game),
          initialProfileProvider.overrideWithValue(profile),
        ],
        child: const MaterialApp(home: TasksScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Задания'), findsOneWidget);
    expect(find.text('Пройдено 1 из 6'), findsOneWidget);
    expect(find.text('Планирование бюджета'), findsOneWidget);
    expect(
      find.text('Выбирай любую историю. За первое прохождение получишь монеты.'),
      findsOneWidget,
    );
  });
}
