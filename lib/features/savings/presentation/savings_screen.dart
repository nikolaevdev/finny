import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_button.dart';
import '../../../core/widgets/finni_card.dart';
import '../../../core/audio/finni_audio.dart';
import '../../../core/widgets/finni_progress_bar.dart';
import '../../../core/widgets/adventure_banner.dart';
import '../../game/application/game_state_provider.dart';
import '../../game/domain/game_goal.dart';
import '../../game/domain/game_state.dart';

class SavingsScreen extends ConsumerStatefulWidget {
  const SavingsScreen({super.key});

  @override
  ConsumerState<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends ConsumerState<SavingsScreen> {
  static const _step = 10;

  int _depositAmount = _step;
  int _withdrawAmount = _step;
  bool _isWorking = false;

  int _effectiveAmount(int requested, int available) {
    if (available <= 0) return 0;
    return requested.clamp(1, available).toInt();
  }

  void _changeDeposit(int delta, int available) {
    if (available <= 0) return;
    setState(() {
      _depositAmount = (_effectiveAmount(_depositAmount, available) + delta)
          .clamp(1, available)
          .toInt();
    });
  }

  void _changeWithdrawal(int delta, int available) {
    if (available <= 0) return;
    setState(() {
      _withdrawAmount = (_effectiveAmount(_withdrawAmount, available) + delta)
          .clamp(1, available)
          .toInt();
    });
  }

  Future<void> _selectGoal(GameGoal goal) async {
    if (_isWorking) return;
    setState(() => _isWorking = true);

    try {
      await ref.read(gameStateProvider.notifier).selectGoal(goal);
    } catch (_) {
      if (mounted) {
        _showMessage('Не удалось изменить цель. Попробуй ещё раз.');
      }
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _completeGoal(GameState game) async {
    if (_isWorking || !game.goalReadyToComplete) return;

    final completedGoal = game.selectedGoal;
    final savingsAfter = game.savings - completedGoal.cost;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выполнить финансовую цель?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(completedGoal.title),
            const SizedBox(height: AppSpacing.sm),
            Text('Из накоплений будет использовано ${completedGoal.cost} монет.'),
            const SizedBox(height: AppSpacing.sm),
            Text('После выполнения останется: $savingsAfter монет.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Пока копить'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Выполнить цель'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isWorking = true);
    try {
      final result = await ref
          .read(gameStateProvider.notifier)
          .completeSelectedGoal();

      if (!mounted) return;

      switch (result) {
        case GoalCompletionResult.success:
          FinniAudio.instance.play(AudioCue.success);
          final updated = ref.read(gameStateProvider);
          await showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              icon: const Icon(
                Icons.celebration_rounded,
                color: AppColors.success,
                size: 42,
              ),
              title: const Text('Цель выполнена!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    completedGoal.resultText,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(completedGoal.lesson),
                  const SizedBox(height: AppSpacing.md),
                  Text('В накоплениях осталось: ${updated?.savings ?? savingsAfter} монет.'),
                  if (updated != null && !updated.allGoalsCompleted) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text('Следующая цель: ${updated.selectedGoal.title}.'),
                  ],
                  if (updated?.allGoalsCompleted == true) ...[
                    const SizedBox(height: AppSpacing.sm),
                    const Text('Все финансовые цели выполнены!'),
                  ],
                ],
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Продолжить'),
                ),
              ],
            ),
          );
          break;
        case GoalCompletionResult.notReady:
          _showMessage('До этой цели пока не хватает накоплений.');
          break;
        case GoalCompletionResult.alreadyCompleted:
          _showMessage('Эта цель уже выполнена.');
          break;
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Не удалось завершить цель. Попробуй ещё раз.');
      }
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _deposit(GameState game) async {
    if (_isWorking) return;

    final amount = _effectiveAmount(_depositAmount, game.balance);
    if (amount <= 0) return;

    setState(() => _isWorking = true);
    try {
      final result = await ref
          .read(gameStateProvider.notifier)
          .depositToSavings(amount);

      if (!mounted) return;

      switch (result) {
        case SavingsTransferResult.success:
          FinniAudio.instance.play(AudioCue.success);
          final updated = ref.read(gameStateProvider);
          _showMessage(
            updated?.goalReadyToComplete == true
                ? '$amount монет в копилке. На цель уже хватает – теперь её можно выполнить!'
                : '$amount монет добавлено в накопления.',
          );
        case SavingsTransferResult.insufficientFunds:
          _showMessage('На балансе не хватает монет для такого перевода.');
        case SavingsTransferResult.planningInProgress:
          _showMessage('Сначала подтверди план на текущий период.');
        case SavingsTransferResult.periodCompleted:
          _showMessage('Период уже завершён. Перейди к следующему периоду.');
        case SavingsTransferResult.invalidAmount:
        case SavingsTransferResult.insufficientSavings:
          _showMessage('Выбери сумму для перевода.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Не удалось сохранить перевод. Попробуй ещё раз.');
      }
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _requestWithdrawal(GameState game) async {
    if (_isWorking || game.savings <= 0) return;

    final amount = _effectiveAmount(_withdrawAmount, game.savings);
    final savingsAfter = game.savings - amount;
    final balanceAfter = game.balance + amount;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Снять из накоплений?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Сейчас накоплено: ${game.savings} монет.'),
              const SizedBox(height: AppSpacing.sm),
              Text('После снятия останется: $savingsAfter монет.'),
              const SizedBox(height: AppSpacing.sm),
              Text('На балансе станет: $balanceAfter монет.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('Снять $amount'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    await _withdraw(amount);
  }

  Future<void> _withdraw(int amount) async {
    if (_isWorking) return;
    setState(() => _isWorking = true);

    try {
      final result = await ref
          .read(gameStateProvider.notifier)
          .withdrawFromSavings(amount);

      if (!mounted) return;

      switch (result) {
        case SavingsTransferResult.success:
          _showMessage('$amount монет возвращено на баланс.');
        case SavingsTransferResult.insufficientSavings:
          _showMessage('В накоплениях не хватает монет для снятия.');
        case SavingsTransferResult.planningInProgress:
          _showMessage('Сначала подтверди план на текущий период.');
        case SavingsTransferResult.periodCompleted:
          _showMessage('Период уже завершён. Перейди к следующему периоду.');
        case SavingsTransferResult.invalidAmount:
        case SavingsTransferResult.insufficientFunds:
          _showMessage('Выбери сумму для снятия.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Не удалось сохранить снятие. Попробуй ещё раз.');
      }
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameStateProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Накопления'),
      ),
      body: SafeArea(
        top: false,
        child: game == null
            ? const _MissingGameState()
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AdventureBanner(title: 'Маршрут к мечте', icon: Icons.auto_awesome_rounded, color: AppColors.save, imageAsset: 'assets/images/goals/dream_cottage_story.webp', height: 150),
                    const SizedBox(height: AppSpacing.md),
                    _GoalSummary(game: game),
                    if (game.goalReadyToComplete) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _GoalCompletionCard(
                        goal: game.selectedGoal,
                        savingsAfter: game.savings - game.selectedGoal.cost,
                        enabled: !_isWorking,
                        onComplete: () => _completeGoal(game),
                      ),
                    ],
                    if (game.allGoalsCompleted) ...[
                      const SizedBox(height: AppSpacing.lg),
                      const FinniCard(
                        color: AppColors.surfaceSecondary,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.emoji_events_rounded, color: AppColors.success),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'Все три финансовые цели выполнены. Можно продолжать копить и управлять оставшимися монетами.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Выбери цель',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    for (final goal in GameGoal.values) ...[
                      _GoalOption(
                        goal: goal,
                        selected: goal == game.selectedGoal,
                        completed: game.isGoalCompleted(goal),
                        enabled: !_isWorking,
                        onTap: () => _selectGoal(goal),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    if (game.allPeriodsCompleted) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.save.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.savings_outlined, color: AppColors.save),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Все 5 периодов завершены. Оставшиеся монеты можно свободно перевести в накопления или вернуть на баланс – история завершённых периодов при этом не изменится.',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    _DepositCard(
                      game: game,
                      amount: _effectiveAmount(
                        _depositAmount,
                        game.balance,
                      ),
                      enabled: !_isWorking &&
                          game.balance > 0 &&
                          game.canManageSavings,
                      onDecrease: () => _changeDeposit(-_step, game.balance),
                      onIncrease: () => _changeDeposit(_step, game.balance),
                      onAll: () => setState(() {
                        _depositAmount = game.balance;
                      }),
                      onDeposit: () => _deposit(game),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _WithdrawalCard(
                      game: game,
                      amount: _effectiveAmount(
                        _withdrawAmount,
                        game.savings,
                      ),
                      enabled: !_isWorking &&
                          game.savings > 0 &&
                          game.canManageSavings,
                      onDecrease: () =>
                          _changeWithdrawal(-_step, game.savings),
                      onIncrease: () =>
                          _changeWithdrawal(_step, game.savings),
                      onAll: () => setState(() {
                        _withdrawAmount = game.savings;
                      }),
                      onWithdraw: () => _requestWithdrawal(game),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _GoalSummary extends StatelessWidget {
  const _GoalSummary({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.surfaceSecondary,
                child: Icon(
                  Icons.track_changes_rounded,
                  color: AppColors.save,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.selectedGoal.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Стоимость: ${game.selectedGoal.cost} монет',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          FinniProgressBar(
            value: game.goalProgress,
            color: AppColors.save,
            height: 12,
            semanticLabel: 'Прогресс накопления',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _GoalValue(
                  label: game.selectedGoalCompleted ? 'В копилке' : 'Накоплено',
                  value: '${game.savings}',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _GoalValue(
                  label: game.selectedGoalCompleted ? 'Выполнено целей' : 'Осталось',
                  value: game.selectedGoalCompleted
                      ? '${game.completedGoalIds.length}/${GameGoal.values.length}'
                      : '${game.remainingToGoal}',
                ),
              ),
            ],
          ),
          if (game.goalReadyToComplete || game.selectedGoalCompleted) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Row(
                children: [
                  const Icon(Icons.celebration_rounded, color: AppColors.success),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      game.selectedGoalCompleted
                          ? 'Цель выполнена!'
                          : 'На цель уже хватает!',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GoalCompletionCard extends StatelessWidget {
  const _GoalCompletionCard({
    required this.goal,
    required this.savingsAfter,
    required this.enabled,
    required this.onComplete,
  });

  final GameGoal goal;
  final int savingsAfter;
  final bool enabled;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      color: AppColors.success.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_circle_rounded, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'На цель уже хватает!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Можно выполнить «${goal.title}». После этого из накоплений останется $savingsAfter монет.',
          ),
          const SizedBox(height: AppSpacing.md),
          FinniButton(
            text: 'Выполнить цель',
            icon: Icons.celebration_rounded,
            onPressed: enabled ? onComplete : null,
          ),
        ],
      ),
    );
  }
}

class _GoalValue extends StatelessWidget {
  const _GoalValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  const _GoalOption({
    required this.goal,
    required this.selected,
    required this.completed,
    required this.enabled,
    required this.onTap,
  });

  final GameGoal goal;
  final bool selected;
  final bool completed;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      color: selected
          ? AppColors.save.withValues(alpha: 0.10)
          : AppColors.surface,
      onTap: enabled && !selected && !completed ? onTap : null,
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle_rounded
                : selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
            color: completed || selected ? AppColors.save : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              goal.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (completed) ...[
            const Text(
              'Выполнено',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            '${goal.cost}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            Icons.monetization_on_rounded,
            size: 18,
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }
}

class _DepositCard extends StatelessWidget {
  const _DepositCard({
    required this.game,
    required this.amount,
    required this.enabled,
    required this.onDecrease,
    required this.onIncrease,
    required this.onAll,
    required this.onDeposit,
  });

  final GameState game;
  final int amount;
  final bool enabled;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onAll;
  final VoidCallback onDeposit;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Пополнить копилку',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'На балансе: ${game.balance} монет',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          if (game.periodStatus == PeriodStatus.planning) ...[
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Сначала подтверди план на текущий период, затем можно пополнять накопления.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _AmountPicker(
            amount: amount,
            available: game.balance,
            onDecrease: onDecrease,
            onIncrease: onIncrease,
            onAll: onAll,
          ),
          const SizedBox(height: AppSpacing.lg),
          FinniButton(
            text: amount > 0 ? 'Перевести $amount монет' : 'Нет монет для перевода',
            icon: Icons.savings_outlined,
            onPressed: enabled ? onDeposit : null,
          ),
          if (game.periodStatus == PeriodStatus.planned) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'По плану на накопления: ${game.budgetPlan.save} · '
              'фактически: ${game.budgetActuals.saved}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _WithdrawalCard extends StatelessWidget {
  const _WithdrawalCard({
    required this.game,
    required this.amount,
    required this.enabled,
    required this.onDecrease,
    required this.onIncrease,
    required this.onAll,
    required this.onWithdraw,
  });

  final GameState game;
  final int amount;
  final bool enabled;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onAll;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Снять из накоплений',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'В копилке: ${game.savings} монет',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          if (game.periodStatus == PeriodStatus.planning) ...[
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Сначала подтверди план на текущий период, затем можно снимать накопления.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _AmountPicker(
            amount: amount,
            available: game.savings,
            onDecrease: onDecrease,
            onIncrease: onIncrease,
            onAll: onAll,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: enabled ? onWithdraw : null,
            icon: const Icon(Icons.outbox_outlined),
            label: Text(
              amount > 0 ? 'Снять $amount монет' : 'В копилке пока пусто',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Перед снятием приложение покажет, сколько останется в накоплениях.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AmountPicker extends StatelessWidget {
  const _AmountPicker({
    required this.amount,
    required this.available,
    required this.onDecrease,
    required this.onIncrease,
    required this.onAll,
  });

  final int amount;
  final int available;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Уменьшить',
          onPressed: available > 0 && amount > 1 ? onDecrease : null,
          icon: const Icon(Icons.remove_rounded),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '$amount',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Text(
                'монет',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Увеличить',
          onPressed: available > 0 && amount < available ? onIncrease : null,
          icon: const Icon(Icons.add_rounded),
        ),
        const SizedBox(width: AppSpacing.sm),
        TextButton(
          onPressed: available > 0 && amount != available ? onAll : null,
          child: const Text('Всё'),
        ),
      ],
    );
  }
}

class _MissingGameState extends StatelessWidget {
  const _MissingGameState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          'Не удалось загрузить игровое состояние.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
