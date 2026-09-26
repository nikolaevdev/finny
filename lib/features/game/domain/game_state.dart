import 'package:flutter/foundation.dart';

import '../../shop/domain/purchase_record.dart';
import '../../shop/domain/shop_item.dart';
import 'budget_actuals.dart';
import 'budget_plan.dart';
import 'game_goal.dart';
import 'period_summary.dart';

enum PeriodStatus { notStarted, planning, planned, completed }

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
    this.budgetActuals = const BudgetActuals(),
    this.purchases = const [],
    this.ownedItemIds = const [],
    this.petCare = 60,
    this.petMood = 60,
    this.completedTaskIds = const [],
    this.periodHistory = const [],
  });

  static const schemaVersion = 4;
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
  final BudgetActuals budgetActuals;
  final List<PurchaseRecord> purchases;
  final List<String> ownedItemIds;
  final int petCare;
  final int petMood;
  final List<String> completedTaskIds;
  final List<PeriodSummary> periodHistory;

  bool get periodStarted => periodStatus != PeriodStatus.notStarted;
  bool get budgetConfirmed => periodStatus == PeriodStatus.planned;
  bool get periodCompleted => periodStatus == PeriodStatus.completed;
  bool get allPeriodsCompleted =>
      currentPeriod >= totalPeriods && periodStatus == PeriodStatus.completed;

  PeriodSummary? get lastPeriodSummary =>
      periodHistory.isEmpty ? null : periodHistory.last;

  int get planningBudget => periodStartBalance ?? balance;

  double get goalProgress {
    if (selectedGoal.cost <= 0) return 0;
    return (savings / selectedGoal.cost).clamp(0.0, 1.0).toDouble();
  }

  int get remainingToGoal =>
      (selectedGoal.cost - savings).clamp(0, selectedGoal.cost).toInt();

  bool get goalReached => remainingToGoal == 0;

  bool ownsItem(String itemId) => ownedItemIds.contains(itemId);

  bool hasCompletedTask(String taskId) => completedTaskIds.contains(taskId);

  GameState completeTask(String taskId) {
    if (taskId.isEmpty || completedTaskIds.contains(taskId)) return this;
    return copyWith(completedTaskIds: [...completedTaskIds, taskId]);
  }

  bool canPurchase(ShopItem item) {
    if (!budgetConfirmed) return false;
    if (balance < item.price) return false;
    if (!item.repeatable && ownsItem(item.id)) return false;
    return true;
  }

  GameState purchase(ShopItem item) {
    if (!canPurchase(item)) return this;

    final record = PurchaseRecord(
      itemId: item.id,
      title: item.title,
      price: item.price,
      category: item.category,
    );

    return copyWith(
      balance: balance - item.price,
      budgetActuals: budgetActuals.addPurchase(item),
      purchases: [...purchases, record],
      ownedItemIds: item.repeatable || ownedItemIds.contains(item.id)
          ? ownedItemIds
          : [...ownedItemIds, item.id],
      petCare: (petCare + item.careDelta).clamp(0, 100).toInt(),
      petMood: (petMood + item.moodDelta).clamp(0, 100).toInt(),
    );
  }

  GameState selectGoal(GameGoal goal) {
    if (goal == selectedGoal) return this;
    return copyWith(selectedGoal: goal);
  }

  GameState depositToSavings(int amount) {
    if (amount <= 0 || amount > balance) return this;
    if (periodStatus == PeriodStatus.planning || periodCompleted) return this;

    return copyWith(
      balance: balance - amount,
      savings: savings + amount,
      budgetActuals: periodStatus == PeriodStatus.planned
          ? budgetActuals.addSavings(amount)
          : budgetActuals,
    );
  }

  GameState withdrawFromSavings(int amount) {
    if (amount <= 0 || amount > savings) return this;
    if (periodStatus == PeriodStatus.planning || periodCompleted) return this;

    return copyWith(
      balance: balance + amount,
      savings: savings - amount,
      budgetActuals: periodStatus == PeriodStatus.planned
          ? budgetActuals.removeSavings(amount)
          : budgetActuals,
    );
  }

  PeriodSummary buildCurrentPeriodSummary() {
    return PeriodSummary(
      period: currentPeriod,
      startBalance: periodStartBalance ?? balance,
      endBalance: balance,
      savingsAfter: savings,
      plan: budgetPlan,
      actuals: budgetActuals,
      purchaseCount: purchases.length,
      petCareAfter: petCare,
      petMoodAfter: petMood,
    );
  }

  GameState completeCurrentPeriod() {
    if (periodStatus != PeriodStatus.planned) return this;

    final summary = buildCurrentPeriodSummary();
    final withoutSamePeriod = periodHistory
        .where((item) => item.period != currentPeriod)
        .toList(growable: false);

    return copyWith(
      periodStatus: PeriodStatus.completed,
      periodHistory: [...withoutSamePeriod, summary],
    );
  }

  GameState advanceToNextPeriod() {
    if (periodStatus != PeriodStatus.completed || currentPeriod >= totalPeriods) {
      return this;
    }

    return GameState(
      balance: balance,
      savings: savings,
      selectedGoal: selectedGoal,
      currentPeriod: currentPeriod + 1,
      totalPeriods: totalPeriods,
      periodStatus: PeriodStatus.notStarted,
      purchases: const [],
      ownedItemIds: ownedItemIds,
      petCare: petCare,
      petMood: petMood,
      completedTaskIds: completedTaskIds,
      periodHistory: periodHistory,
    );
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
    BudgetActuals? budgetActuals,
    List<PurchaseRecord>? purchases,
    List<String>? ownedItemIds,
    int? petCare,
    int? petMood,
    List<String>? completedTaskIds,
    List<PeriodSummary>? periodHistory,
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
      budgetActuals: budgetActuals ?? this.budgetActuals,
      purchases: purchases ?? this.purchases,
      ownedItemIds: ownedItemIds ?? this.ownedItemIds,
      petCare: petCare ?? this.petCare,
      petMood: petMood ?? this.petMood,
      completedTaskIds: completedTaskIds ?? this.completedTaskIds,
      periodHistory: periodHistory ?? this.periodHistory,
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
        'budgetActuals': budgetActuals.toJson(),
        'purchases': purchases.map((purchase) => purchase.toJson()).toList(),
        'ownedItemIds': ownedItemIds,
        'petCare': petCare,
        'petMood': petMood,
        'completedTaskIds': completedTaskIds,
        'periodHistory': periodHistory.map((summary) => summary.toJson()).toList(),
      };

  factory GameState.fromJson(Map<String, Object?> json) {
    final versionValue = json['schemaVersion'];
    final version = versionValue is num ? versionValue.toInt() : 1;
    if (version < 1 || version > schemaVersion) {
      throw const FormatException('Unsupported game state version');
    }

    int safeNonNegative(Object? value, {int fallback = 0}) {
      final number = value is num ? value.toInt() : fallback;
      return number < 0 ? fallback : number;
    }

    int safePercent(Object? value, {int fallback = 60}) {
      final number = value is num ? value.toInt() : fallback;
      return number.clamp(0, 100).toInt();
    }

    final rawStatus = json['periodStatus'];
    final status = PeriodStatus.values.where((value) => value.name == rawStatus);

    final rawPlan = json['budgetPlan'];
    final plan = rawPlan is Map
        ? BudgetPlan.fromJson(Map<String, Object?>.from(rawPlan))
        : const BudgetPlan();

    final rawActuals = json['budgetActuals'];
    final actuals = rawActuals is Map
        ? BudgetActuals.fromJson(Map<String, Object?>.from(rawActuals))
        : const BudgetActuals();

    final purchases = <PurchaseRecord>[];
    final rawPurchases = json['purchases'];
    if (rawPurchases is List) {
      for (final rawPurchase in rawPurchases) {
        if (rawPurchase is Map) {
          purchases.add(
            PurchaseRecord.fromJson(Map<String, Object?>.from(rawPurchase)),
          );
        }
      }
    }

    final ownedItemIds = <String>[];
    final rawOwnedItemIds = json['ownedItemIds'];
    if (rawOwnedItemIds is List) {
      for (final value in rawOwnedItemIds) {
        if (value is String && value.isNotEmpty) ownedItemIds.add(value);
      }
    }

    final completedTaskIds = <String>[];
    final rawCompletedTaskIds = json['completedTaskIds'];
    if (rawCompletedTaskIds is List) {
      for (final value in rawCompletedTaskIds) {
        if (value is String &&
            value.isNotEmpty &&
            !completedTaskIds.contains(value)) {
          completedTaskIds.add(value);
        }
      }
    }

    final periodHistory = <PeriodSummary>[];
    final rawPeriodHistory = json['periodHistory'];
    if (rawPeriodHistory is List) {
      for (final value in rawPeriodHistory) {
        if (value is Map) {
          periodHistory.add(
            PeriodSummary.fromJson(Map<String, Object?>.from(value)),
          );
        }
      }
    }

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
      periodStatus: status.isEmpty ? PeriodStatus.notStarted : status.first,
      periodIncome: safeNonNegative(json['periodIncome']),
      periodIncomeSource: json['periodIncomeSource'] is String
          ? json['periodIncomeSource'] as String
          : null,
      periodStartBalance: startBalance is num && startBalance >= 0
          ? startBalance.toInt()
          : null,
      budgetPlan: plan,
      budgetActuals: actuals,
      purchases: purchases,
      ownedItemIds: ownedItemIds,
      petCare: safePercent(json['petCare']),
      petMood: safePercent(json['petMood']),
      completedTaskIds: completedTaskIds,
      periodHistory: periodHistory,
    );
  }
}
