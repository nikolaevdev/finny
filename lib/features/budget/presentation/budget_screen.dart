import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_button.dart';
import '../../../core/widgets/finni_card.dart';
import '../../game/application/game_state_provider.dart';
import '../../game/domain/budget_plan.dart';
import '../../game/domain/game_state.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  bool _isWorking = false;

  Future<void> _startPeriod() async {
    if (_isWorking) return;
    setState(() => _isWorking = true);

    try {
      await ref.read(gameStateProvider.notifier).startCurrentPeriod();
    } catch (_) {
      if (!mounted) return;
      _showMessage('Не удалось сохранить начало периода. Попробуй ещё раз.');
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _changeBudget(BudgetCategory category, int delta) async {
    try {
      final changed = await ref
          .read(gameStateProvider.notifier)
          .changeBudget(category: category, delta: delta);

      if (!changed && delta > 0 && mounted) {
        _showMessage('Все доступные монеты уже распределены.');
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('Не удалось сохранить изменения. Попробуй ещё раз.');
    }
  }

  Future<void> _confirmBudget() async {
    if (_isWorking) return;
    setState(() => _isWorking = true);

    try {
      final confirmed = await ref
          .read(gameStateProvider.notifier)
          .confirmBudget();

      if (!confirmed && mounted) {
        _showMessage('Сначала распредели хотя бы часть бюджета.');
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('Не удалось сохранить план. Попробуй ещё раз.');
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
        title: const Text('План на период'),
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
                child: switch (game.periodStatus) {
                  PeriodStatus.notStarted => _PeriodStartContent(
                    game: game,
                    isWorking: _isWorking,
                    onStart: _startPeriod,
                  ),
                  PeriodStatus.planning => _BudgetPlanningContent(
                    game: game,
                    isWorking: _isWorking,
                    onChange: _changeBudget,
                    onConfirm: _confirmBudget,
                  ),
                  PeriodStatus.planned => _BudgetConfirmedContent(
                    game: game,
                    onBackHome: () => context.pop(),
                  ),
                  PeriodStatus.completed => _BudgetCompletedContent(
                    game: game,
                    onOpenSummary: () => context.push(AppRoutes.periodSummary),
                  ),
                },
              ),
      ),
    );
  }
}

class _PeriodStartContent extends StatelessWidget {
  const _PeriodStartContent({
    required this.game,
    required this.isWorking,
    required this.onStart,
  });

  final GameState game;
  final bool isWorking;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodBadge(game: game),
        const SizedBox(height: AppSpacing.xl),
        const Icon(
          Icons.account_balance_wallet_outlined,
          size: 72,
          color: AppColors.purple,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Начинается новый период',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Сначала Финни получает игровые монеты. Затем ты решишь, '
          'сколько оставить на нужное, желания и накопления.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        const FinniCard(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.surfaceSecondary,
                child: Icon(
                  Icons.monetization_on_rounded,
                  color: AppColors.gold,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      GameState.defaultPeriodIncomeSource,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      '+120 монет',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Это только игровая валюта. В приложении нет реальных денег, '
          'платежей или покупок за реальные средства.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        FinniButton(
          text: isWorking ? 'Начинаем…' : 'Получить 120 монет и начать',
          icon: isWorking ? null : Icons.arrow_forward_rounded,
          onPressed: isWorking ? null : onStart,
        ),
      ],
    );
  }
}

class _BudgetPlanningContent extends StatelessWidget {
  const _BudgetPlanningContent({
    required this.game,
    required this.isWorking,
    required this.onChange,
    required this.onConfirm,
  });

  final GameState game;
  final bool isWorking;
  final Future<void> Function(BudgetCategory category, int delta) onChange;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final plan = game.budgetPlan;
    final remaining = plan.remainingFrom(game.planningBudget);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodBadge(game: game),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _AmountCard(
                label: 'Всего монет',
                value: game.planningBudget,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _AmountCard(
                label: 'Свободно',
                value: remaining,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        FinniCard(
          color: AppColors.surfaceSecondary,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.purple,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Распредели монеты так, как считаешь правильным. '
                  'Необязательно распределять всё – часть можно оставить свободной.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CategoryAllocator(
          title: 'Нужно',
          description: 'То, без чего Финни трудно обойтись.',
          icon: Icons.shopping_basket_outlined,
          color: AppColors.need,
          value: plan.need,
          onMinus: () => onChange(BudgetCategory.need, -10),
          onPlus: () => onChange(BudgetCategory.need, 10),
        ),
        const SizedBox(height: AppSpacing.md),
        _CategoryAllocator(
          title: 'Хочу',
          description: 'То, что приятно иметь, но можно отложить.',
          icon: Icons.sports_esports_outlined,
          color: AppColors.want,
          value: plan.want,
          onMinus: () => onChange(BudgetCategory.want, -10),
          onPlus: () => onChange(BudgetCategory.want, 10),
        ),
        const SizedBox(height: AppSpacing.md),
        _CategoryAllocator(
          title: 'Коплю',
          description: 'Часть плана, которую хочется направить к цели.',
          icon: Icons.savings_outlined,
          color: AppColors.save,
          value: plan.save,
          onMinus: () => onChange(BudgetCategory.save, -10),
          onPlus: () => onChange(BudgetCategory.save, 10),
        ),
        const SizedBox(height: AppSpacing.lg),
        _PlanSummary(plan: plan, available: game.planningBudget),
        const SizedBox(height: AppSpacing.xl),
        FinniButton(
          text: isWorking ? 'Сохраняем…' : 'Подтвердить план',
          icon: isWorking ? null : Icons.check_rounded,
          onPressed: isWorking || plan.allocated == 0 ? null : onConfirm,
        ),
      ],
    );
  }
}

class _BudgetConfirmedContent extends StatelessWidget {
  const _BudgetConfirmedContent({required this.game, required this.onBackHome});

  final GameState game;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodBadge(game: game),
        const SizedBox(height: AppSpacing.xl),
        const Icon(Icons.task_alt_rounded, size: 72, color: AppColors.success),
        const SizedBox(height: AppSpacing.md),
        Text(
          'План готов',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Он сохранён на устройстве. Позже мы сравним план с тем, '
          'как монеты были потрачены на самом деле.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        _PlanSummary(plan: game.budgetPlan, available: game.planningBudget),
        const SizedBox(height: AppSpacing.lg),
        if (game.periodIncomeSource != null)
          FinniCard(
            color: AppColors.surfaceSecondary,
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.purple,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    '${game.periodIncomeSource}: +${game.periodIncome} монет',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.xxl),
        FinniButton(
          text: 'Вернуться домой',
          icon: Icons.home_outlined,
          onPressed: onBackHome,
        ),
      ],
    );
  }
}

class _BudgetCompletedContent extends StatelessWidget {
  const _BudgetCompletedContent({
    required this.game,
    required this.onOpenSummary,
  });

  final GameState game;
  final VoidCallback onOpenSummary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodBadge(game: game),
        const SizedBox(height: AppSpacing.xl),
        const Icon(
          Icons.flag_circle_outlined,
          size: 72,
          color: AppColors.purple,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Период завершён',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'План этого периода уже зафиксирован. Открой итог, чтобы сравнить его с фактическими решениями.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        FinniButton(
          text: 'Открыть итог периода',
          icon: Icons.bar_chart_rounded,
          onPressed: onOpenSummary,
        ),
      ],
    );
  }
}

class _PeriodBadge extends StatelessWidget {
  const _PeriodBadge({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.purple.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          'Период ${game.currentPeriod} из ${game.totalPeriods}',
          style: const TextStyle(
            color: AppColors.purpleDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const Text(
            'монет',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CategoryAllocator extends StatelessWidget {
  const _CategoryAllocator({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Уменьшить на 10',
                onPressed: value == 0 ? null : onMinus,
                icon: const Icon(Icons.remove_rounded),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$value',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const Text(
                      'монет',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                tooltip: 'Добавить 10',
                style: IconButton.styleFrom(backgroundColor: color),
                onPressed: onPlus,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanSummary extends StatelessWidget {
  const _PlanSummary({required this.plan, required this.available});

  final BudgetPlan plan;
  final int available;

  @override
  Widget build(BuildContext context) {
    final free = plan.remainingFrom(available);

    return FinniCard(
      color: AppColors.surfaceSecondary,
      child: Column(
        children: [
          _SummaryRow(label: 'Нужно', value: plan.need, color: AppColors.need),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(label: 'Хочу', value: plan.want, color: AppColors.want),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(label: 'Коплю', value: plan.save, color: AppColors.save),
          const Divider(height: AppSpacing.xl),
          _SummaryRow(
            label: 'Останется свободно',
            value: free,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MissingGameState extends StatelessWidget {
  const _MissingGameState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Text(
          'Игровое состояние не найдено. Вернись на главный экран.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
