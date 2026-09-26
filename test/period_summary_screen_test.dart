import 'package:finny/features/game/application/game_state_provider.dart';
import 'package:finny/features/game/domain/budget_actuals.dart';
import 'package:finny/features/game/domain/budget_plan.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:finny/features/game/domain/game_state_repository.dart';
import 'package:finny/features/period/presentation/period_summary_screen.dart';
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
  testWidgets('period summary compares plan and fact and requires confirmation', (
    tester,
  ) async {
    final initial = const GameState(
      balance: 55,
      savings: 35,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 1,
      totalPeriods: 5,
      periodStatus: PeriodStatus.planned,
      periodStartBalance: 120,
      budgetPlan: BudgetPlan(need: 50, want: 30, save: 20),
      budgetActuals: BudgetActuals(needSpent: 45, wantSpent: 20, saved: 15),
    );
    final repository = _FakeGameStateRepository(initial);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateRepositoryProvider.overrideWithValue(repository),
          initialGameStateProvider.overrideWithValue(initial),
        ],
        child: const MaterialApp(home: PeriodSummaryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('План и факт'), findsOneWidget);
    expect(find.text('Период 1 из 5'), findsOneWidget);

    await tester.ensureVisible(find.text('Завершить период'));
    await tester.tap(find.text('Завершить период'));
    await tester.pumpAndSettle();

    expect(find.text('Завершить период?'), findsOneWidget);
    expect(repository.state!.periodStatus, PeriodStatus.planned);

    await tester.tap(find.widgetWithText(FilledButton, 'Завершить'));
    await tester.pumpAndSettle();

    expect(repository.state!.periodStatus, PeriodStatus.completed);
    expect(repository.state!.periodHistory, hasLength(1));
    expect(find.text('Период 1 завершён'), findsOneWidget);
    expect(find.text('Перейти к периоду 2'), findsOneWidget);
  });
}
