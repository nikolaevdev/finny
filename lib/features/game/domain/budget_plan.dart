import 'package:flutter/foundation.dart';

enum BudgetCategory { need, want, save }

@immutable
class BudgetPlan {
  const BudgetPlan({this.need = 0, this.want = 0, this.save = 0});

  final int need;
  final int want;
  final int save;

  int get allocated => need + want + save;

  int remainingFrom(int available) => available - allocated;

  int amountFor(BudgetCategory category) {
    return switch (category) {
      BudgetCategory.need => need,
      BudgetCategory.want => want,
      BudgetCategory.save => save,
    };
  }

  BudgetPlan change({
    required BudgetCategory category,
    required int delta,
    required int available,
  }) {
    final current = amountFor(category);
    final next = current + delta;

    if (next < 0) return this;

    final candidate = switch (category) {
      BudgetCategory.need => BudgetPlan(need: next, want: want, save: save),
      BudgetCategory.want => BudgetPlan(need: need, want: next, save: save),
      BudgetCategory.save => BudgetPlan(need: need, want: want, save: next),
    };

    if (candidate.allocated > available) return this;
    return candidate;
  }

  Map<String, Object?> toJson() => {'need': need, 'want': want, 'save': save};

  factory BudgetPlan.fromJson(Map<String, Object?> json) {
    int safeAmount(Object? value) {
      final amount = value is num ? value.toInt() : 0;
      return amount < 0 ? 0 : amount;
    }

    return BudgetPlan(
      need: safeAmount(json['need']),
      want: safeAmount(json['want']),
      save: safeAmount(json['save']),
    );
  }
}
