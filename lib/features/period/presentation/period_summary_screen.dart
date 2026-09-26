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
import '../../game/domain/game_state.dart';
import '../../game/domain/period_summary.dart';
import '../../game/domain/pet_progress.dart';

class PeriodSummaryScreen extends ConsumerStatefulWidget {
  const PeriodSummaryScreen({super.key});

  @override
  ConsumerState<PeriodSummaryScreen> createState() =>
      _PeriodSummaryScreenState();
}

class _PeriodSummaryScreenState extends ConsumerState<PeriodSummaryScreen> {
  bool _isWorking = false;

  Future<void> _completePeriod() async {
    if (_isWorking) return;

    final game = ref.read(gameStateProvider);
    if (game == null || game.periodStatus != PeriodStatus.planned) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Завершить период?'),
        content: const Text(
          'После завершения покупки и переводы этого периода будут закрыты. '
          'Ты увидишь сравнение плана с тем, что получилось на самом деле.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Ещё не сейчас'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Завершить'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isWorking = true);
    try {
      final completed =
          await ref.read(gameStateProvider.notifier).completeCurrentPeriod();
      if (!completed && mounted) {
        _showMessage('Не удалось завершить период. Проверь, что план подтверждён.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Не удалось сохранить итог периода. Попробуй ещё раз.');
      }
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _advance() async {
    if (_isWorking) return;
    setState(() => _isWorking = true);

    try {
      final advanced =
          await ref.read(gameStateProvider.notifier).advanceToNextPeriod();
      if (!mounted) return;

      if (advanced) {
        context.go(AppRoutes.home);
      } else {
        _showMessage('Следующий период пока недоступен.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Не удалось перейти к следующему периоду.');
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
        title: const Text('Итог периода'),
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
                child: game.periodStatus == PeriodStatus.completed
                    ? _CompletedPeriod(
                        game: game,
                        isWorking: _isWorking,
                        onAdvance: _advance,
                      )
                    : _CurrentPeriodPreview(
                        game: game,
                        isWorking: _isWorking,
                        onComplete: _completePeriod,
                      ),
              ),
      ),
    );
  }
}

class _CurrentPeriodPreview extends StatelessWidget {
  const _CurrentPeriodPreview({
    required this.game,
    required this.isWorking,
    required this.onComplete,
  });

  final GameState game;
  final bool isWorking;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    if (game.periodStatus != PeriodStatus.planned) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 64,
            color: AppColors.purple,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Итог появится после плана',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Сначала начни период и подтверди распределение бюджета.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FinniButton(
            text: 'Перейти к плану',
            icon: Icons.fact_check_outlined,
            onPressed: () => context.go(AppRoutes.budget),
          ),
        ],
      );
    }

    final preview = game.buildCurrentPeriodSummary();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodBadge(period: game.currentPeriod, total: game.totalPeriods),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Посмотрим, что получилось',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Пока период не завершён, можно ещё совершать покупки или пополнять накопления.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        _PlanFactTable(summary: preview),
        const SizedBox(height: AppSpacing.lg),
        _BalanceCard(summary: preview),
        const SizedBox(height: AppSpacing.xl),
        FinniButton(
          text: isWorking ? 'Сохраняем итог…' : 'Завершить период',
          icon: isWorking ? null : Icons.flag_outlined,
          onPressed: isWorking ? null : onComplete,
        ),
      ],
    );
  }
}

class _CompletedPeriod extends StatelessWidget {
  const _CompletedPeriod({
    required this.game,
    required this.isWorking,
    required this.onAdvance,
  });

  final GameState game;
  final bool isWorking;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final summary = game.lastPeriodSummary;
    if (summary == null) {
      return const Center(child: Text('Итог периода не найден.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodBadge(period: summary.period, total: game.totalPeriods),
        const SizedBox(height: AppSpacing.lg),
        const Icon(
          Icons.celebration_outlined,
          size: 72,
          color: AppColors.purple,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          game.allPeriodsCompleted
              ? 'Все игровые периоды пройдены'
              : 'Период ${summary.period} завершён',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _summaryMessage(summary),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        _PlanFactTable(summary: summary),
        const SizedBox(height: AppSpacing.lg),
        _FeedbackCard(summary: summary),
        const SizedBox(height: AppSpacing.lg),
        _BalanceCard(summary: summary),
        const SizedBox(height: AppSpacing.lg),
        _PetStateCard(game: game),
        const SizedBox(height: AppSpacing.xxl),
        if (!game.allPeriodsCompleted)
          FinniButton(
            text: isWorking
                ? 'Переходим…'
                : 'Перейти к периоду ${game.currentPeriod + 1}',
            icon: isWorking ? null : Icons.arrow_forward_rounded,
            onPressed: isWorking ? null : onAdvance,
          )
        else
          FinniButton(
            text: 'Вернуться домой',
            icon: Icons.home_outlined,
            onPressed: () => context.go(AppRoutes.home),
          ),
      ],
    );
  }

  String _summaryMessage(PeriodSummary summary) {
    if (summary.matchedDirections == 3) {
      return 'План и фактические решения хорошо совпали. Посмотри, что помогло сохранить этот результат.';
    }
    if (summary.matchedDirections >= 1) {
      return 'Часть плана удалось выполнить. Ниже видно, что получилось и что можно изменить в следующем периоде.';
    }
    return 'Этот период получился иначе, чем планировалось. Это безопасный способ увидеть последствия и попробовать другой план дальше.';
  }
}

class _PlanFactTable extends StatelessWidget {
  const _PlanFactTable({required this.summary});

  final PeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('План и факт', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              Expanded(flex: 2, child: Text('Направление')),
              Expanded(child: Text('План', textAlign: TextAlign.center)),
              Expanded(child: Text('Факт', textAlign: TextAlign.center)),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          _ComparisonRow(
            title: 'Нужно',
            plan: summary.plan.need,
            actual: summary.actuals.needSpent,
            color: AppColors.need,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ComparisonRow(
            title: 'Хочу',
            plan: summary.plan.want,
            actual: summary.actuals.wantSpent,
            color: AppColors.want,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ComparisonRow(
            title: 'Коплю',
            plan: summary.plan.save,
            actual: summary.actuals.saved,
            color: AppColors.save,
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.title,
    required this.plan,
    required this.actual,
    required this.color,
  });

  final String title;
  final int plan;
  final int actual;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Expanded(child: Text('$plan', textAlign: TextAlign.center)),
        Expanded(
          child: Text(
            '$actual',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.summary});

  final PeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    final messages = <String>[
      summary.stayedWithinNeedPlan
          ? 'На нужное ушло не больше запланированного.'
          : 'На нужное ушло больше плана. В следующем периоде можно заложить сюда больше монет.',
      summary.stayedWithinWantPlan
          ? 'Расходы на желания остались в пределах плана.'
          : 'На желания ушло больше плана. Можно отложить часть необязательных покупок.',
      summary.reachedSavingsPlan
          ? 'План по накоплениям выполнен.'
          : 'В накопления попало меньше плана. В следующем периоде можно сначала отложить часть монет к цели.',
    ];

    return FinniCard(
      color: AppColors.surfaceSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Что можно заметить', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          for (final message in messages) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.arrow_right_rounded, color: AppColors.purple),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(message)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary});

  final PeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      child: Row(
        children: [
          Expanded(
            child: _Metric(
              label: 'Баланс в начале',
              value: '${summary.startBalance}',
              icon: Icons.play_circle_outline_rounded,
            ),
          ),
          Container(width: 1, height: 54, color: AppColors.divider),
          Expanded(
            child: _Metric(
              label: 'Осталось',
              value: '${summary.endBalance}',
              icon: Icons.account_balance_wallet_outlined,
            ),
          ),
          Container(width: 1, height: 54, color: AppColors.divider),
          Expanded(
            child: _Metric(
              label: 'В копилке',
              value: '${summary.savingsAfter}',
              icon: Icons.savings_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _PetStateCard extends StatelessWidget {
  const _PetStateCard({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    final summary = game.lastPeriodSummary!;
    final progress = game.developmentProgress;
    final previousHistory = game.periodHistory.length <= 1
        ? const <PeriodSummary>[]
        : game.periodHistory.sublist(0, game.periodHistory.length - 1);
    final previousStage =
        PetDevelopmentProgress.fromHistory(previousHistory).stage;
    final grewThisPeriod = previousStage != progress.stage;

    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Финни после периода',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          _ProgressLine(
            label: 'Забота',
            value: summary.petCareAfter,
            color: AppColors.need,
          ),
          const SizedBox(height: AppSpacing.md),
          _ProgressLine(
            label: 'Настроение',
            value: summary.petMoodAfter,
            color: AppColors.want,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${game.moodLevel.title}. ${game.periodMoodReason}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grewThisPeriod
                      ? 'Финни подрос! Стадия ${progress.stage.index + 1} из 3'
                      : 'Рост: ${progress.stage.title} · стадия ${progress.stage.index + 1} из 3',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(progress.stage.shortReason),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Покупок за период: ${summary.purchaseCount}. Рост зависит не от одной покупки, а от решений за несколько периодов.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
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
        SizedBox(width: 95, child: Text(label)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: value / 100,
              color: color,
              backgroundColor: AppColors.surfaceSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(width: 36, child: Text('$value')),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.purple),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _PeriodBadge extends StatelessWidget {
  const _PeriodBadge({required this.period, required this.total});

  final int period;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.purple.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        child: Text(
          'Период $period из $total',
          style: const TextStyle(
            color: AppColors.purpleDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MissingGameState extends StatelessWidget {
  const _MissingGameState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Игровое состояние не найдено.'));
  }
}
