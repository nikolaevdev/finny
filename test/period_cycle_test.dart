import 'package:finny/features/game/domain/budget_actuals.dart';
import 'package:finny/features/game/domain/budget_plan.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  GameState plannedState({int period = 1}) {
    return GameState(
      balance: 55,
      savings: 35,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: period,
      totalPeriods: 5,
      periodStatus: PeriodStatus.planned,
      periodIncome: 120,
      periodIncomeSource: GameState.defaultPeriodIncomeSource,
      periodStartBalance: 120,
      budgetPlan: const BudgetPlan(need: 50, want: 30, save: 20),
      budgetActuals: const BudgetActuals(
        needSpent: 45,
        wantSpent: 20,
        saved: 15,
      ),
      petCare: 70,
      petMood: 65,
      completedTaskIds: const ['budget_weekend'],
    );
  }

  test('completing period stores plan fact summary', () {
    final completed = plannedState().completeCurrentPeriod();

    expect(completed.periodStatus, PeriodStatus.completed);
    expect(completed.periodHistory, hasLength(1));

    final summary = completed.periodHistory.single;
    expect(summary.period, 1);
    expect(summary.startBalance, 120);
    expect(summary.endBalance, 55);
    expect(summary.savingsAfter, 35);
    expect(summary.plan.need, 50);
    expect(summary.actuals.needSpent, 45);
    expect(summary.actuals.saved, 15);
    expect(summary.reachedSavingsPlan, isFalse);
  });

  test('next period keeps long term state and resets period data', () {
    final completed = plannedState().completeCurrentPeriod();
    final next = completed.advanceToNextPeriod();

    expect(next.currentPeriod, 2);
    expect(next.periodStatus, PeriodStatus.notStarted);
    expect(next.balance, 55);
    expect(next.savings, 35);
    expect(next.completedTaskIds, ['budget_weekend']);
    expect(next.periodHistory, hasLength(1));
    expect(next.periodIncome, 0);
    expect(next.periodStartBalance, isNull);
    expect(next.budgetPlan.allocated, 0);
    expect(next.budgetActuals.totalSpent, 0);
    expect(next.purchases, isEmpty);
  });

  test('fifth completed period does not advance further', () {
    final completed = plannedState(period: 5).completeCurrentPeriod();
    final next = completed.advanceToNextPeriod();

    expect(completed.allPeriodsCompleted, isTrue);
    expect(identical(next, completed), isTrue);
    expect(next.currentPeriod, 5);
  });
}
