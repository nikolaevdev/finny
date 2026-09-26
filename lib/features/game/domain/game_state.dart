import 'package:flutter/foundation.dart';

import 'budget_plan.dart';
import 'game_goal.dart';

enum PeriodStatus { notStarted, planning, planned }

@immutable
class GameState {
  const GameState({
    required this.balance,
    required this.savings,
    required this.selectedGoal,
    required this.currentPeriod,
    required this.totalPeriods,
    required this.periodStatus,
    this.periodIncome = 0,
    this.periodIncomeSource,
    this.periodStartBalance,
    this.budgetPlan = const BudgetPlan(),
  });

  static const schemaVersion = 1;
  static const defaultPeriodIncome = 120;
  static const defaultPeriodIncomeSource = 'Карманные монеты на период';
  static const requiredPeriods = 5;

  final int balance;
  final int savings;
  final GameGoal selectedGoal;
  final int currentPeriod;
  final int totalPeriods;
  final PeriodStatus periodStatus;
  final int periodIncome;
  final String? periodIncomeSource;
  final int? periodStartBalance;
  final BudgetPlan budgetPlan;

  bool get periodStarted => periodStatus != PeriodStatus.notStarted;
  bool get budgetConfirmed => periodStatus == PeriodStatus.planned;

  int get planningBudget => periodStartBalance ?? balance;

  double get goalProgress {
    if (selectedGoal.cost <= 0) return 0;
    return (savings / selectedGoal.cost).clamp(0.0, 1.0).toDouble();
  }

  factory GameState.initial({required bool demoMode}) {
    return GameState(
      balance: 0,
      savings: demoMode ? 120 : 0,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 1,
      totalPeriods: requiredPeriods,
      periodStatus: PeriodStatus.notStarted,
    );
  }

  GameState copyWith({
    int? balance,
    int? savings,
    GameGoal? selectedGoal,
    int? currentPeriod,
    int? totalPeriods,
    PeriodStatus? periodStatus,
    int? periodIncome,
    String? periodIncomeSource,
    int? periodStartBalance,
    BudgetPlan? budgetPlan,
  }) {
    return GameState(
      balance: balance ?? this.balance,
      savings: savings ?? this.savings,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      totalPeriods: totalPeriods ?? this.totalPeriods,
      periodStatus: periodStatus ?? this.periodStatus,
      periodIncome: periodIncome ?? this.periodIncome,
      periodIncomeSource: periodIncomeSource ?? this.periodIncomeSource,
      periodStartBalance: periodStartBalance ?? this.periodStartBalance,
      budgetPlan: budgetPlan ?? this.budgetPlan,
    );
  }

  Map<String, Object?> toJson() => {
        'schemaVersion': schemaVersion,
        'balance': balance,
        'savings': savings,
        'selectedGoal': selectedGoal.id,
        'currentPeriod': currentPeriod,
        'totalPeriods': totalPeriods,
        'periodStatus': periodStatus.name,
        'periodIncome': periodIncome,
        'periodIncomeSource': periodIncomeSource,
        'periodStartBalance': periodStartBalance,
        'budgetPlan': budgetPlan.toJson(),
      };

  factory GameState.fromJson(Map<String, Object?> json) {
    final version = json['schemaVersion'];
    if (version is! num || version.toInt() != schemaVersion) {
      throw const FormatException('Unsupported game state version');
    }

    int safeNonNegative(Object? value, {int fallback = 0}) {
      final number = value is num ? value.toInt() : fallback;
      return number < 0 ? fallback : number;
    }

    final rawStatus = json['periodStatus'];
    final status = PeriodStatus.values.where(
      (value) => value.name == rawStatus,
    );

    final rawPlan = json['budgetPlan'];
    final plan = rawPlan is Map
        ? BudgetPlan.fromJson(Map<String, Object?>.from(rawPlan))
        : const BudgetPlan();

    final startBalance = json['periodStartBalance'];

    return GameState(
      balance: safeNonNegative(json['balance']),
      savings: safeNonNegative(json['savings']),
      selectedGoal: GameGoal.fromId(json['selectedGoal']),
      currentPeriod: safeNonNegative(json['currentPeriod'], fallback: 1)
          .clamp(1, requiredPeriods)
          .toInt(),
      totalPeriods: safeNonNegative(
        json['totalPeriods'],
        fallback: requiredPeriods,
      ),
      periodStatus:
          status.isEmpty ? PeriodStatus.notStarted : status.first,
      periodIncome: safeNonNegative(json['periodIncome']),
      periodIncomeSource: json['periodIncomeSource'] is String
          ? json['periodIncomeSource'] as String
          : null,
      periodStartBalance: startBalance is num && startBalance >= 0
          ? startBalance.toInt()
          : null,
      budgetPlan: plan,
    );
  }
}
