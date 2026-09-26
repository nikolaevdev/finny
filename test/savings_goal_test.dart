import 'package:finny/features/game/domain/budget_actuals.dart';
import 'package:finny/features/game/domain/budget_plan.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  GameState plannedState({
    int balance = 100,
    int savings = 40,
    BudgetActuals actuals = const BudgetActuals(),
  }) {
    return GameState(
      balance: balance,
      savings: savings,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 1,
      totalPeriods: 5,
      periodStatus: PeriodStatus.planned,
      periodStartBalance: 120,
      budgetPlan: const BudgetPlan(need: 50, want: 30, save: 30),
      budgetActuals: actuals,
    );
  }

  test('deposit moves coins from balance to savings and records actual', () {
    final result = plannedState().depositToSavings(30);

    expect(result.balance, 70);
    expect(result.savings, 70);
    expect(result.budgetActuals.saved, 30);
    expect(result.remainingToGoal, 110);
  });

  test('deposit cannot exceed available balance', () {
    final state = plannedState(balance: 20);
    final result = state.depositToSavings(30);

    expect(identical(result, state), isTrue);
    expect(result.balance, 20);
    expect(result.savings, 40);
  });

  test('savings transfer is blocked while budget is being planned', () {
    final state = plannedState().copyWith(periodStatus: PeriodStatus.planning);

    final deposit = state.depositToSavings(10);
    final withdrawal = state.withdrawFromSavings(10);

    expect(identical(deposit, state), isTrue);
    expect(identical(withdrawal, state), isTrue);
  });

  test('withdrawal returns coins to balance and reduces current actual savings', () {
    final state = plannedState(
      actuals: const BudgetActuals(saved: 30),
    );
    final result = state.withdrawFromSavings(20);

    expect(result.balance, 120);
    expect(result.savings, 20);
    expect(result.budgetActuals.saved, 10);
  });

  test('withdrawal never makes current actual savings negative', () {
    final state = plannedState(
      savings: 60,
      actuals: const BudgetActuals(saved: 10),
    );
    final result = state.withdrawFromSavings(40);

    expect(result.balance, 140);
    expect(result.savings, 20);
    expect(result.budgetActuals.saved, 0);
  });

  test('changing active goal keeps accumulated savings', () {
    final state = plannedState();
    final result = state.selectGoal(GameGoal.treeHouse);

    expect(result.selectedGoal, GameGoal.treeHouse);
    expect(result.savings, 40);
    expect(result.remainingToGoal, 220);
  });

  test('goal is reached when accumulated amount covers its cost', () {
    final state = plannedState(savings: 180);

    expect(state.goalProgress, 1);
    expect(state.remainingToGoal, 0);
    expect(state.goalReached, isTrue);
  });
}
