import 'package:finny/features/budget/presentation/budget_screen.dart';
import 'package:finny/features/game/application/game_state_provider.dart';
import 'package:finny/features/game/domain/budget_plan.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:finny/features/game/domain/game_state_repository.dart';
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
  testWidgets('budget planning scene fits narrow phone and keeps categories', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const game = GameState(
      balance: 120,
      savings: 20,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 1,
      totalPeriods: 5,
      periodStatus: PeriodStatus.planning,
      periodStartBalance: 120,
      budgetPlan: BudgetPlan(need: 50, want: 30, save: 30),
    );
    final repository = _FakeGameRepository(game);
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
          gameStateRepositoryProvider.overrideWithValue(repository),
          initialGameStateProvider.overrideWithValue(game),
          initialProfileProvider.overrideWithValue(profile),
        ],
        child: const MaterialApp(home: BudgetScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('План на период'), findsOneWidget);
    expect(find.text('Нужно'), findsWidgets);
    expect(find.text('Хочу'), findsWidgets);
    expect(find.text('Коплю'), findsWidgets);
    expect(find.text('Подтвердить план'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
