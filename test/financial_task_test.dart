import 'package:finny/features/game/domain/budget_plan.dart';
import 'package:finny/features/tasks/data/financial_task_catalog.dart';
import 'package:finny/features/tasks/domain/financial_task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog contains at least six tasks across all required topics', () {
    expect(FinancialTaskCatalog.tasks.length, greaterThanOrEqualTo(6));

    for (final topic in FinancialTaskTopic.values) {
      expect(
        FinancialTaskCatalog.tasks.where((task) => task.topic == topic).length,
        greaterThanOrEqualTo(2),
      );
    }

    for (final task in FinancialTaskCatalog.tasks) {
      expect(task.rewardCoins, greaterThan(0));
    }
  });

  test('budget task accepts balanced allocation and explains weak one', () {
    final task = FinancialTaskCatalog.byId('budget_weekend')!;

    final good = task.evaluateAllocation(
      const BudgetPlan(need: 40, want: 30, save: 20),
    );
    final weak = task.evaluateAllocation(
      const BudgetPlan(need: 30, want: 50, save: 10),
    );

    expect(good.isSuccessful, isTrue);
    expect(good.explanation, isNotEmpty);
    expect(weak.isSuccessful, isFalse);
    expect(weak.explanation, isNotEmpty);
  });

  test('savings task distinguishes balanced and risky amount', () {
    final task = FinancialTaskCatalog.byId('savings_gift')!;

    expect(task.evaluateSavingsAmount(20).isSuccessful, isTrue);
    expect(task.evaluateSavingsAmount(50).isSuccessful, isFalse);
  });

  test('payment task provides consequences for both actions', () {
    final task = FinancialTaskCatalog.byId('payment_snack')!;
    final good = task.actions.firstWhere((action) => action.id == 'water');
    final weak = task.actions.firstWhere((action) => action.id == 'sweet');

    expect(task.evaluateAction(good).isSuccessful, isTrue);
    expect(task.evaluateAction(weak).isSuccessful, isFalse);
    expect(good.feedback, isNotEmpty);
    expect(weak.feedback, isNotEmpty);
  });
}
