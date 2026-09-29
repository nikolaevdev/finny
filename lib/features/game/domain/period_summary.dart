import 'package:flutter/foundation.dart';

import 'budget_actuals.dart';
import 'budget_plan.dart';

@immutable
class PeriodSummary {
  const PeriodSummary({
    required this.period,
    required this.startBalance,
    required this.endBalance,
    required this.savingsAfter,
    required this.plan,
    required this.actuals,
    required this.purchaseCount,
    required this.petCareAfter,
    required this.petMoodAfter,
  });

  final int period;
  final int startBalance;
  final int endBalance;
  final int savingsAfter;
  final BudgetPlan plan;
  final BudgetActuals actuals;
  final int purchaseCount;
  final int petCareAfter;
  final int petMoodAfter;

  int get needDifference => actuals.needSpent - plan.need;
  int get wantDifference => actuals.wantSpent - plan.want;
  int get saveDifference => actuals.saved - plan.save;

  bool get stayedWithinNeedPlan => actuals.needSpent <= plan.need;
  bool get stayedWithinWantPlan => actuals.wantSpent <= plan.want;
  bool get reachedSavingsPlan => actuals.saved >= plan.save;

  int get matchedDirections {
    var result = 0;
    if (stayedWithinNeedPlan) result += 1;
    if (stayedWithinWantPlan) result += 1;
    if (reachedSavingsPlan) result += 1;
    return result;
  }

  Map<String, Object?> toJson() => {
        'period': period,
        'startBalance': startBalance,
        'endBalance': endBalance,
        'savingsAfter': savingsAfter,
        'plan': plan.toJson(),
        'actuals': actuals.toJson(),
        'purchaseCount': purchaseCount,
        'petCareAfter': petCareAfter,
        'petMoodAfter': petMoodAfter,
      };

  factory PeriodSummary.fromJson(Map<String, Object?> json) {
    int safeNonNegative(Object? value, {int fallback = 0}) {
      final number = value is num ? value.toInt() : fallback;
      return number < 0 ? fallback : number;
    }

    int safePercent(Object? value, {int fallback = 60}) {
      final number = value is num ? value.toInt() : fallback;
      return number.clamp(0, 100).toInt();
    }

    final rawPlan = json['plan'];
    final rawActuals = json['actuals'];

    return PeriodSummary(
      period: safeNonNegative(json['period'], fallback: 1),
      startBalance: safeNonNegative(json['startBalance']),
      endBalance: safeNonNegative(json['endBalance']),
      savingsAfter: safeNonNegative(json['savingsAfter']),
      plan: rawPlan is Map
          ? BudgetPlan.fromJson(Map<String, Object?>.from(rawPlan))
          : const BudgetPlan(),
      actuals: rawActuals is Map
          ? BudgetActuals.fromJson(Map<String, Object?>.from(rawActuals))
          : const BudgetActuals(),
      purchaseCount: safeNonNegative(json['purchaseCount']),
      petCareAfter: safePercent(json['petCareAfter']),
      petMoodAfter: safePercent(json['petMoodAfter']),
    );
  }
}
