import 'package:finny/features/game/domain/budget_actuals.dart';
import 'package:finny/features/game/domain/budget_plan.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:finny/features/shop/data/shop_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  GameState plannedState({int balance = 120}) {
    return GameState(
      balance: balance,
      savings: 0,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 1,
      totalPeriods: 5,
      periodStatus: PeriodStatus.planned,
      periodStartBalance: 120,
      budgetPlan: const BudgetPlan(need: 50, want: 30, save: 30),
      budgetActuals: const BudgetActuals(),
    );
  }

  test('purchase reduces balance and records need spending', () {
    final item = ShopCatalog.byId('food_set')!;
    final result = plannedState().purchase(item);

    expect(result.balance, 90);
    expect(result.budgetActuals.needSpent, 30);
    expect(result.budgetActuals.wantSpent, 0);
    expect(result.purchases, hasLength(1));
    expect(result.purchases.single.itemId, 'food_set');
    expect(result.petCare, 70);
  });

  test('purchase is blocked when balance is too low', () {
    final item = ShopCatalog.byId('star_lamp')!;
    final state = plannedState(balance: 20);
    final result = state.purchase(item);

    expect(identical(result, state), isTrue);
    expect(result.balance, 20);
    expect(result.purchases, isEmpty);
  });

  test('non-repeatable item becomes owned after purchase', () {
    final item = ShopCatalog.byId('explorer_journal')!;
    final first = plannedState().purchase(item);
    final second = first.purchase(item);

    expect(first.ownsItem('explorer_journal'), isTrue);
    expect(first.balance, 100);
    expect(identical(second, first), isTrue);
  });
}
