import 'package:finny/features/game/application/game_state_provider.dart';
import 'package:finny/features/game/domain/budget_actuals.dart';
import 'package:finny/features/game/domain/budget_plan.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:finny/features/game/domain/game_state_repository.dart';
import 'package:finny/features/savings/presentation/savings_screen.dart';
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
  GameState createState() {
    return const GameState(
      balance: 90,
      savings: 40,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 1,
      totalPeriods: 5,
      periodStatus: PeriodStatus.planned,
      periodStartBalance: 120,
      budgetPlan: BudgetPlan(need: 50, want: 30, save: 30),
      budgetActuals: BudgetActuals(saved: 20),
    );
  }

  testWidgets('withdrawal requires confirmation and shows resulting savings', (
    tester,
  ) async {
    final initial = createState();
    final repository = _FakeGameStateRepository(initial);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateRepositoryProvider.overrideWithValue(repository),
          initialGameStateProvider.overrideWithValue(initial),
        ],
        child: const MaterialApp(home: SavingsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Накопления'), findsOneWidget);
    expect(find.text('Накоплено'), findsOneWidget);
    expect(find.text('Осталось'), findsOneWidget);

    await tester.ensureVisible(find.text('Снять 10 монет'));
    await tester.tap(find.text('Снять 10 монет'));
    await tester.pumpAndSettle();

    expect(find.text('Снять из накоплений?'), findsOneWidget);
    expect(find.text('После снятия останется: 30 монет.'), findsOneWidget);
    expect(find.text('На балансе станет: 100 монет.'), findsOneWidget);
    expect(repository.state!.savings, 40);

    await tester.tap(find.widgetWithText(FilledButton, 'Снять 10'));
    await tester.pumpAndSettle();

    expect(repository.state!.savings, 30);
    expect(repository.state!.balance, 100);
  });

  testWidgets('user can select another goal without losing savings', (
    tester,
  ) async {
    final initial = createState();
    final repository = _FakeGameStateRepository(initial);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateRepositoryProvider.overrideWithValue(repository),
          initialGameStateProvider.overrideWithValue(initial),
        ],
        child: const MaterialApp(home: SavingsScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Домик Финни'));
    await tester.tap(find.text('Домик Финни'));
    await tester.pumpAndSettle();

    expect(repository.state!.selectedGoal, GameGoal.treeHouse);
    expect(repository.state!.savings, 40);
    expect(find.text('Стоимость: 260 монет'), findsOneWidget);
  });
  testWidgets('final period balance can still be moved to savings', (
    tester,
  ) async {
    const initial = GameState(
      balance: 435,
      savings: 130,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 5,
      totalPeriods: 5,
      periodStatus: PeriodStatus.completed,
      budgetPlan: BudgetPlan(need: 80, want: 20, save: 20),
      budgetActuals: BudgetActuals(needSpent: 80, saved: 20),
    );
    final repository = _FakeGameStateRepository(initial);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateRepositoryProvider.overrideWithValue(repository),
          initialGameStateProvider.overrideWithValue(initial),
        ],
        child: const MaterialApp(home: SavingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Все 5 периодов завершены'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Перевести 10 монет'));
    await tester.tap(find.text('Перевести 10 монет'));
    await tester.pumpAndSettle();

    expect(repository.state!.balance, 425);
    expect(repository.state!.savings, 140);
    expect(repository.state!.budgetActuals.saved, 20);
  });

}
