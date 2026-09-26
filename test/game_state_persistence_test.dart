import 'package:finny/features/game/data/shared_preferences_game_state_repository.dart';
import 'package:finny/features/game/domain/budget_plan.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('game state is saved and restored', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesGameStateRepository(preferences);

    const state = GameState(
      balance: 120,
      savings: 40,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 1,
      totalPeriods: 5,
      periodStatus: PeriodStatus.planned,
      periodIncome: 120,
      periodIncomeSource: GameState.defaultPeriodIncomeSource,
      periodStartBalance: 120,
      budgetPlan: BudgetPlan(need: 50, want: 30, save: 30),
    );

    await repository.save(state);
    final restored = repository.load();

    expect(restored, isNotNull);
    expect(restored!.balance, 120);
    expect(restored.savings, 40);
    expect(restored.selectedGoal, GameGoal.explorerCorner);
    expect(restored.currentPeriod, 1);
    expect(restored.periodStatus, PeriodStatus.planned);
    expect(restored.budgetPlan.need, 50);
    expect(restored.budgetPlan.want, 30);
    expect(restored.budgetPlan.save, 30);
  });

  test('demo mode initial state starts with goal progress', () {
    final state = GameState.initial(demoMode: true);

    expect(state.balance, 0);
    expect(state.savings, 120);
    expect(state.selectedGoal, GameGoal.explorerCorner);
    expect(state.periodStatus, PeriodStatus.notStarted);
  });
}
