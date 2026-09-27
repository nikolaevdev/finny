import 'package:finny/features/game/domain/budget_actuals.dart';
import 'package:finny/features/game/domain/budget_plan.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:finny/features/game/domain/period_summary.dart';
import 'package:finny/features/game/domain/pet_progress.dart';
import 'package:finny/features/shop/data/shop_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PeriodSummary goodSummary(int period) => PeriodSummary(
    period: period,
    startBalance: 120,
    endBalance: 60,
    savingsAfter: period * 20,
    plan: const BudgetPlan(need: 40, want: 20, save: 20),
    actuals: const BudgetActuals(needSpent: 30, wantSpent: 10, saved: 20),
    purchaseCount: 2,
    petCareAfter: 70,
    petMoodAfter: 70,
  );

  test('need purchase now also changes mood a little', () {
    const state = GameState(
      balance: 120,
      savings: 0,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 1,
      totalPeriods: 5,
      periodStatus: PeriodStatus.planned,
      petMood: 60,
    );

    final next = state.purchase(ShopCatalog.items.first);

    expect(next.petCare, 70);
    expect(next.petMood, 62);
  });

  test(
    'period result explains mood and updates it from financial decisions',
    () {
      const state = GameState(
        balance: 70,
        savings: 20,
        selectedGoal: GameGoal.explorerCorner,
        currentPeriod: 1,
        totalPeriods: 5,
        periodStatus: PeriodStatus.planned,
        periodStartBalance: 120,
        budgetPlan: BudgetPlan(need: 40, want: 20, save: 20),
        budgetActuals: BudgetActuals(needSpent: 30, wantSpent: 0, saved: 20),
        petMood: 60,
      );

      final completed = state.completeCurrentPeriod();

      expect(state.periodMoodDelta, 5);
      expect(completed.petMood, 65);
      expect(completed.lastPeriodSummary!.petMoodAfter, 65);
      expect(state.periodMoodReason, contains('позаботился'));
      expect(state.periodMoodReason, contains('сохранить'));
    },
  );

  test('development requires decisions across several periods', () {
    final one = PetDevelopmentProgress.fromHistory([goodSummary(1)]);
    final two = PetDevelopmentProgress.fromHistory([
      goodSummary(1),
      goodSummary(2),
    ]);
    final four = PetDevelopmentProgress.fromHistory([
      goodSummary(1),
      goodSummary(2),
      goodSummary(3),
      goodSummary(4),
    ]);

    expect(one.stage, PetDevelopmentStage.little);
    expect(two.stage, PetDevelopmentStage.growing);
    expect(four.stage, PetDevelopmentStage.confident);
  });

  test('need-only periods can grow Finni but do not unlock final stage', () {
    PeriodSummary needOnly(int period) => PeriodSummary(
      period: period,
      startBalance: 120,
      endBalance: 80,
      savingsAfter: 0,
      plan: const BudgetPlan(need: 40, want: 0, save: 20),
      actuals: const BudgetActuals(needSpent: 30),
      purchaseCount: 1,
      petCareAfter: 75,
      petMoodAfter: 65,
    );

    final progress = PetDevelopmentProgress.fromHistory([
      needOnly(1),
      needOnly(2),
      needOnly(3),
      needOnly(4),
      needOnly(5),
    ]);

    expect(progress.stage, PetDevelopmentStage.growing);
    expect(progress.savingPeriods, 0);
  });
}
