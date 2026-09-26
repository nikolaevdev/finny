import 'package:finny/features/game/data/shared_preferences_game_state_repository.dart';
import 'package:finny/features/game/domain/budget_actuals.dart';
import 'package:finny/features/game/domain/budget_plan.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:finny/features/shop/domain/purchase_record.dart';
import 'package:finny/features/shop/domain/shop_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('game state is saved and restored', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesGameStateRepository(preferences);

    const state = GameState(
      balance: 90,
      savings: 40,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 1,
      totalPeriods: 5,
      periodStatus: PeriodStatus.planned,
      periodIncome: 120,
      periodIncomeSource: GameState.defaultPeriodIncomeSource,
      periodStartBalance: 120,
      budgetPlan: BudgetPlan(need: 50, want: 30, save: 30),
      budgetActuals: BudgetActuals(needSpent: 30),
      purchases: [
        PurchaseRecord(
          itemId: 'food_set',
          title: 'Набор еды',
          price: 30,
          category: ShopCategory.need,
        ),
      ],
      ownedItemIds: ['bandana'],
      petCare: 70,
      petMood: 60,
    );

    await repository.save(state);
    final restored = repository.load();

    expect(restored, isNotNull);
    expect(restored!.balance, 90);
    expect(restored.savings, 40);
    expect(restored.selectedGoal, GameGoal.explorerCorner);
    expect(restored.currentPeriod, 1);
    expect(restored.periodStatus, PeriodStatus.planned);
    expect(restored.budgetPlan.need, 50);
    expect(restored.budgetActuals.needSpent, 30);
    expect(restored.purchases, hasLength(1));
    expect(restored.purchases.single.itemId, 'food_set');
    expect(restored.ownsItem('bandana'), isTrue);
    expect(restored.petCare, 70);
  });

  test('stage 3 state migrates to current schema', () {
    final state = GameState.fromJson({
      'schemaVersion': 1,
      'balance': 120,
      'savings': 0,
      'selectedGoal': 'explorer_corner',
      'currentPeriod': 1,
      'totalPeriods': 5,
      'periodStatus': 'planned',
      'periodIncome': 120,
      'periodIncomeSource': GameState.defaultPeriodIncomeSource,
      'periodStartBalance': 120,
      'budgetPlan': {
        'need': 50,
        'want': 30,
        'save': 30,
      },
    });

    expect(state.balance, 120);
    expect(state.purchases, isEmpty);
    expect(state.budgetActuals.needSpent, 0);
    expect(state.petCare, 60);
    expect(state.petMood, 60);
  });

  test('stage 4 state keeps savings data in stage 5', () {
    final state = GameState.fromJson({
      'schemaVersion': 2,
      'balance': 65,
      'savings': 55,
      'selectedGoal': 'tree_house',
      'currentPeriod': 1,
      'totalPeriods': 5,
      'periodStatus': 'planned',
      'periodIncome': 120,
      'periodIncomeSource': GameState.defaultPeriodIncomeSource,
      'periodStartBalance': 120,
      'budgetPlan': {
        'need': 50,
        'want': 30,
        'save': 30,
      },
      'budgetActuals': {
        'needSpent': 30,
        'wantSpent': 25,
        'saved': 20,
      },
      'purchases': <Object?>[],
      'ownedItemIds': <Object?>[],
      'petCare': 70,
      'petMood': 65,
    });

    expect(state.balance, 65);
    expect(state.savings, 55);
    expect(state.selectedGoal, GameGoal.treeHouse);
    expect(state.budgetActuals.saved, 20);
    expect(state.remainingToGoal, 205);
  });

  test('demo mode initial state starts with goal progress', () {
    final state = GameState.initial(demoMode: true);

    expect(state.balance, 0);
    expect(state.savings, 120);
    expect(state.selectedGoal, GameGoal.explorerCorner);
    expect(state.periodStatus, PeriodStatus.notStarted);
  });
}
