import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  GameState state() => const GameState(
    balance: 100,
    savings: 20,
    selectedGoal: GameGoal.explorerCorner,
    currentPeriod: 1,
    totalPeriods: 5,
    periodStatus: PeriodStatus.planned,
  );

  test('first successful completion records task and awards coins once', () {
    final first = state().completeTask('budget_weekend', rewardCoins: 10);
    final second = first.completeTask('budget_weekend', rewardCoins: 10);

    expect(first.completedTaskIds, ['budget_weekend']);
    expect(first.rewardedTaskIds, ['budget_weekend']);
    expect(first.balance, 110);
    expect(identical(second, first), isTrue);
  });

  test('task reward earned during planning increases planning budget', () {
    const planning = GameState(
      balance: 120,
      savings: 0,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 1,
      totalPeriods: 5,
      periodStatus: PeriodStatus.planning,
      periodStartBalance: 120,
    );

    final rewarded = planning.completeTask('budget_weekend', rewardCoins: 10);

    expect(rewarded.balance, 130);
    expect(rewarded.periodStartBalance, 130);
    expect(rewarded.planningBudget, 130);
  });

  test('task progress and reward state are serialized', () {
    final original = state()
        .completeTask('budget_weekend', rewardCoins: 10)
        .completeTask('savings_gift', rewardCoins: 10);

    final restored = GameState.fromJson(original.toJson());

    expect(restored.completedTaskIds, ['budget_weekend', 'savings_gift']);
    expect(restored.rewardedTaskIds, ['budget_weekend', 'savings_gift']);
    expect(restored.hasCompletedTask('savings_gift'), isTrue);
    expect(restored.hasReceivedTaskReward('savings_gift'), isTrue);
    expect(restored.balance, 120);
  });
}
