import 'package:finny/features/game/application/game_state_provider.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:finny/features/game/domain/game_state_repository.dart';
import 'package:finny/features/home/presentation/home_screen.dart';
import 'package:finny/features/pet/domain/pet.dart';
import 'package:finny/features/pet/domain/pet_appearance.dart';
import 'package:finny/features/profile/application/local_profile_provider.dart';
import 'package:finny/features/profile/domain/player_profile.dart';
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

void main() {
  testWidgets('home keeps financial tasks in the tasks section', (tester) async {
    const game = GameState(
      balance: 120,
      savings: 20,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 1,
      totalPeriods: 5,
      periodStatus: PeriodStatus.planned,
      completedTaskIds: ['budget_weekend'],
      rewardedTaskIds: ['budget_weekend'],
    );
    final profile = PlayerProfile(
      playerName: 'Игрок',
      demoMode: false,
      pet: const Pet(
        name: 'Финни',
        appearance: PetAppearance(
          colorIndex: 0,
          earsIndex: 0,
          patternIndex: 0,
        ),
      ),
      createdAt: DateTime.utc(2026, 9, 27),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateRepositoryProvider.overrideWithValue(_FakeGameRepository(game)),
          initialGameStateProvider.overrideWithValue(game),
          initialProfileProvider.overrideWithValue(profile),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // The next task title intentionally lives in the Tasks section rather than
    // consuming space on the main character scene.
    expect(find.text('Дальше: Ярмарка изобретателей'), findsNothing);
    expect(find.text('Задания'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
