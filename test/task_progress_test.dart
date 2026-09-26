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

  test('successful task can be recorded only once', () {
    final first = state().completeTask('budget_weekend');
    final second = first.completeTask('budget_weekend');

    expect(first.completedTaskIds, ['budget_weekend']);
    expect(identical(second, first), isTrue);
  });

  test('task progress is serialized', () {
    final original = state()
        .completeTask('budget_weekend')
        .completeTask('savings_gift');

    final restored = GameState.fromJson(original.toJson());

    expect(restored.completedTaskIds, ['budget_weekend', 'savings_gift']);
    expect(restored.hasCompletedTask('savings_gift'), isTrue);
  });
}
