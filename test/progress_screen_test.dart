import 'package:finny/features/game/application/game_state_provider.dart';
import 'package:finny/features/game/domain/budget_actuals.dart';
import 'package:finny/features/game/domain/budget_plan.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:finny/features/game/domain/game_state_repository.dart';
import 'package:finny/features/game/domain/period_summary.dart';
import 'package:finny/features/progress/presentation/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGameStateRepository implements GameStateRepository {
  _FakeGameStateRepository(this.state);

  GameState? state;

  @override
  Future<void> delete() async => state = null;

  @override
  GameState? load() => state;

  @override
  Future<void> save(GameState state) async => this.state = state;
}

void main() {
  testWidgets('progress screen shows tasks goal and latest period', (
    tester,
  ) async {
    const summary = PeriodSummary(
      period: 1,
      startBalance: 120,
      endBalance: 45,
      savingsAfter: 25,
      plan: BudgetPlan(need: 50, want: 30, save: 20),
      actuals: BudgetActuals(needSpent: 45, wantSpent: 20, saved: 25),
      purchaseCount: 2,
      petCareAfter: 70,
      petMoodAfter: 68,
    );
    const game = GameState(
      balance: 45,
      savings: 25,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 2,
      totalPeriods: 5,
      periodStatus: PeriodStatus.notStarted,
      completedTaskIds: ['budget_weekend', 'savings_gift', 'payment_snack'],
      periodHistory: [summary],
    );
    final repository = _FakeGameStateRepository(game);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateRepositoryProvider.overrideWithValue(repository),
          initialGameStateProvider.overrideWithValue(game),
        ],
        child: const MaterialApp(home: ProgressScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Мой прогресс'), findsOneWidget);
    expect(find.text('3/6'), findsOneWidget);
    expect(
      find.text('Накоплено 25 из 180. Осталось 155 монет.'),
      findsOneWidget,
    );
    expect(find.text('Планирование бюджета'), findsOneWidget);
    expect(find.text('Период 1'), findsWidgets);
    expect(find.text('План 50  •  Факт 45'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Словарик'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Словарик'), findsOneWidget);
  });
}
