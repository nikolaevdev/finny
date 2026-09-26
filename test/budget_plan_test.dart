import 'package:finny/features/game/domain/budget_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('budget cannot exceed available coins', () {
    const start = BudgetPlan(need: 50, want: 30, save: 30);

    final changed = start.change(
      category: BudgetCategory.save,
      delta: 20,
      available: 120,
    );

    expect(identical(changed, start), isTrue);
    expect(changed.allocated, 110);
  });

  test('budget category cannot become negative', () {
    const start = BudgetPlan(need: 0, want: 20, save: 10);

    final changed = start.change(
      category: BudgetCategory.need,
      delta: -10,
      available: 120,
    );

    expect(identical(changed, start), isTrue);
    expect(changed.need, 0);
  });

  test('budget keeps free coins when not everything is allocated', () {
    const plan = BudgetPlan(need: 50, want: 30, save: 30);

    expect(plan.allocated, 110);
    expect(plan.remainingFrom(120), 10);
  });
}
