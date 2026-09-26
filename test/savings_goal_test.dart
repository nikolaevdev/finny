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

  test('savings stay manageable after the fifth and final period', () {
    const state = GameState(
      balance: 435,
      savings: 130,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 5,
      totalPeriods: 5,
      periodStatus: PeriodStatus.completed,
      budgetPlan: BudgetPlan(need: 80, want: 20, save: 20),
      budgetActuals: BudgetActuals(needSpent: 80, wantSpent: 0, saved: 20),
    );

    final deposited = state.depositToSavings(50);

    expect(state.allPeriodsCompleted, isTrue);
    expect(state.canManageSavings, isTrue);
    expect(deposited.balance, 385);
    expect(deposited.savings, 180);
    expect(deposited.budgetActuals.saved, 20);

    final withdrawn = deposited.withdrawFromSavings(30);
    expect(withdrawn.balance, 415);
    expect(withdrawn.savings, 150);
    expect(withdrawn.budgetActuals.saved, 20);
  });

  test('savings stay locked after a completed non-final period', () {
    const state = GameState(
      balance: 100,
      savings: 40,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 3,
      totalPeriods: 5,
      periodStatus: PeriodStatus.completed,
    );

    expect(state.canManageSavings, isFalse);
    expect(identical(state.depositToSavings(10), state), isTrue);
    expect(identical(state.withdrawFromSavings(10), state), isTrue);
  });
  test('completed goal spends its cost and selects the next goal', () {
    final state = plannedState(balance: 40, savings: 200);

    final result = state.completeSelectedGoal();

    expect(result.savings, 20);
    expect(result.completedGoalIds, contains(GameGoal.explorerCorner.id));
    expect(result.isGoalCompleted(GameGoal.explorerCorner), isTrue);
    expect(result.selectedGoal, GameGoal.treeHouse);
    expect(result.balance, 40);
    expect(result.budgetActuals.saved, 0);
  });

  test('goal cannot be completed before enough is saved', () {
    final state = plannedState(savings: 170);

    final result = state.completeSelectedGoal();

    expect(identical(result, state), isTrue);
    expect(result.completedGoalIds, isEmpty);
  });

}
