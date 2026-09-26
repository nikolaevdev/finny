import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/budget_plan.dart';
import '../domain/game_state.dart';
import '../domain/game_state_repository.dart';

final gameStateRepositoryProvider = Provider<GameStateRepository>((ref) {
  throw StateError('gameStateRepositoryProvider must be overridden at startup');
});

final initialGameStateProvider = Provider<GameState?>((ref) => null);

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
