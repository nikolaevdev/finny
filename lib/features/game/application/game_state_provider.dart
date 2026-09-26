import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shop/domain/shop_item.dart';
import '../domain/budget_actuals.dart';
import '../domain/budget_plan.dart';
import '../domain/game_goal.dart';
import '../domain/game_state.dart';
import '../domain/game_state_repository.dart';

final gameStateRepositoryProvider = Provider<GameStateRepository>((ref) {
  throw StateError('gameStateRepositoryProvider must be overridden at startup');
});

final initialGameStateProvider = Provider<GameState?>((ref) => null);

enum PurchaseResult {
  success,
  periodNotReady,
  insufficientFunds,
  alreadyPurchased,
}

enum SavingsTransferResult {
  success,
  invalidAmount,
  insufficientFunds,
  insufficientSavings,
  planningInProgress,
  periodCompleted,
}

class GameStateNotifier extends Notifier<GameState?> {
  @override
  GameState? build() => ref.watch(initialGameStateProvider);

  Future<void> createForProfile({required bool demoMode}) async {
    final initial = GameState.initial(demoMode: demoMode);
    await ref.read(gameStateRepositoryProvider).save(initial);
    state = initial;
  }

  Future<void> startCurrentPeriod() async {
    final current = state;
    if (current == null) {
      throw StateError('Игровое состояние не создано');
    }
    if (current.periodStatus != PeriodStatus.notStarted) return;

    final newBalance = current.balance + GameState.defaultPeriodIncome;
    final next = current.copyWith(
      balance: newBalance,
      periodStatus: PeriodStatus.planning,
      periodIncome: GameState.defaultPeriodIncome,
      periodIncomeSource: GameState.defaultPeriodIncomeSource,
      periodStartBalance: newBalance,
      budgetPlan: const BudgetPlan(),
      budgetActuals: const BudgetActuals(),
      purchases: const [],
    );

    await _save(next);
  }

  Future<bool> changeBudget({
    required BudgetCategory category,
    required int delta,
  }) async {
    final current = state;
    if (current == null || current.periodStatus != PeriodStatus.planning) {
      return false;
    }

    final nextPlan = current.budgetPlan.change(
      category: category,
      delta: delta,
      available: current.planningBudget,
    );

    if (identical(nextPlan, current.budgetPlan)) return false;

    await _save(current.copyWith(budgetPlan: nextPlan));
    return true;
  }

  Future<bool> confirmBudget() async {
    final current = state;
    if (current == null || current.periodStatus != PeriodStatus.planning) {
      return false;
    }
    if (current.budgetPlan.allocated <= 0) return false;
    if (current.budgetPlan.allocated > current.planningBudget) return false;

    await _save(
      current.copyWith(periodStatus: PeriodStatus.planned),
    );
    return true;
  }

  Future<PurchaseResult> purchase(ShopItem item) async {
    final current = state;
    if (current == null || !current.budgetConfirmed) {
      return PurchaseResult.periodNotReady;
    }
    if (!item.repeatable && current.ownsItem(item.id)) {
      return PurchaseResult.alreadyPurchased;
    }
    if (current.balance < item.price) {
      return PurchaseResult.insufficientFunds;
    }

    final next = current.purchase(item);
    if (identical(next, current)) {
      return PurchaseResult.insufficientFunds;
    }

    await _save(next);
    return PurchaseResult.success;
  }

  Future<bool> selectGoal(GameGoal goal) async {
    final current = state;
    if (current == null) return false;

    final next = current.selectGoal(goal);
    if (identical(next, current)) return false;

    await _save(next);
    return true;
  }

  Future<SavingsTransferResult> depositToSavings(int amount) async {
    final current = state;
    if (current == null || amount <= 0) {
      return SavingsTransferResult.invalidAmount;
    }
    if (current.periodStatus == PeriodStatus.planning) {
      return SavingsTransferResult.planningInProgress;
    }
    if (current.periodStatus == PeriodStatus.completed &&
        !current.allPeriodsCompleted) {
      return SavingsTransferResult.periodCompleted;
    }
    if (amount > current.balance) {
      return SavingsTransferResult.insufficientFunds;
    }

    final next = current.depositToSavings(amount);
    if (identical(next, current)) {
      return SavingsTransferResult.invalidAmount;
    }

    await _save(next);
    return SavingsTransferResult.success;
  }

  Future<SavingsTransferResult> withdrawFromSavings(int amount) async {
    final current = state;
    if (current == null || amount <= 0) {
      return SavingsTransferResult.invalidAmount;
    }
    if (current.periodStatus == PeriodStatus.planning) {
      return SavingsTransferResult.planningInProgress;
    }
    if (current.periodStatus == PeriodStatus.completed &&
        !current.allPeriodsCompleted) {
      return SavingsTransferResult.periodCompleted;
    }
    if (amount > current.savings) {
      return SavingsTransferResult.insufficientSavings;
    }

    final next = current.withdrawFromSavings(amount);
    if (identical(next, current)) {
      return SavingsTransferResult.invalidAmount;
    }

    await _save(next);
    return SavingsTransferResult.success;
  }

  Future<bool> completeCurrentPeriod() async {
    final current = state;
    if (current == null || current.periodStatus != PeriodStatus.planned) {
      return false;
    }

    final next = current.completeCurrentPeriod();
    if (identical(next, current)) return false;

    await _save(next);
    return true;
  }

  Future<bool> advanceToNextPeriod() async {
    final current = state;
    if (current == null || current.periodStatus != PeriodStatus.completed) {
      return false;
    }
    if (current.currentPeriod >= current.totalPeriods) return false;

    final next = current.advanceToNextPeriod();
    if (identical(next, current)) return false;

    await _save(next);
    return true;
  }

  Future<bool> completeTask(String taskId) async {
    final current = state;
    if (current == null || taskId.isEmpty) return false;

    final next = current.completeTask(taskId);
    if (identical(next, current)) return false;

    await _save(next);
    return true;
  }

  Future<void> resetForProfile({required bool demoMode}) async {
    await createForProfile(demoMode: demoMode);
  }

  Future<void> _save(GameState next) async {
    await ref.read(gameStateRepositoryProvider).save(next);
    state = next;
  }
}

final gameStateProvider = NotifierProvider<GameStateNotifier, GameState?>(
  GameStateNotifier.new,
);
