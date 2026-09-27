import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_card.dart';
import '../../../core/widgets/finni_progress_bar.dart';
import '../../game/application/game_state_provider.dart';
import '../../game/domain/game_goal.dart';
import '../../game/domain/game_state.dart';
import '../../game/domain/period_summary.dart';
import '../../tasks/data/financial_task_catalog.dart';
import '../../tasks/domain/financial_task.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameStateProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Мой прогресс'),
      ),
      body: game == null
          ? const Center(child: Text('Игровое состояние не найдено.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                _OverviewCard(game: game),
                const SizedBox(height: AppSpacing.lg),
                _GoalProgressCard(game: game),
                const SizedBox(height: AppSpacing.lg),
                _LearningProgressCard(game: game),
                const SizedBox(height: AppSpacing.lg),
                _LastPeriodCard(game: game),
                if (game.periodHistory.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _PeriodHistoryCard(history: game.periodHistory),
                ],
                const SizedBox(height: AppSpacing.lg),
                FinniCard(
                  onTap: () => context.push(AppRoutes.glossary),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.surfaceSecondary,
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.purple,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Словарик',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text('Коротко объясняем главные финансовые слова.'),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    final completedPeriods = game.periodHistory.length;
    return FinniCard(
      color: AppColors.surfaceSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Что уже получилось',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  icon: Icons.check_circle_outline_rounded,
                  value: '${game.completedTaskIds.length}/6',
                  label: 'заданий',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Metric(
                  icon: Icons.calendar_month_outlined,
                  value: '$completedPeriods/${game.totalPeriods}',
                  label: 'периодов',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Metric(
                  icon: Icons.trending_up_rounded,
                  value: '${game.developmentStage.index + 1}/3',
                  label: 'стадия',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.purple),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  const _GoalProgressCard({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.track_changes_rounded, color: AppColors.save),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Текущая цель',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            game.allGoalsCompleted
                ? 'Все финансовые цели выполнены'
                : game.selectedGoal.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          FinniProgressBar(
            value: game.allGoalsCompleted ? 1 : game.goalProgress,
            color: AppColors.save,
            height: 12,
            semanticLabel: 'Прогресс финансовой цели',
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            game.allGoalsCompleted
                ? 'Выполнено ${game.completedGoalIds.length} из ${GameGoal.values.length} целей. В копилке осталось ${game.savings} монет.'
                : game.goalReadyToComplete
                ? 'На цель уже хватает: ${game.savings} монет. Заверши её в разделе «Накопления».'
                : 'Накоплено ${game.savings} из ${game.selectedGoal.cost}. Осталось ${game.remainingToGoal} монет.',
          ),
          if (!game.allGoalsCompleted && game.completedGoalIds.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Выполнено целей: ${game.completedGoalIds.length}/${GameGoal.values.length}.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _LearningProgressCard extends StatelessWidget {
  const _LearningProgressCard({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Пройденные темы',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final topic in FinancialTaskTopic.values) ...[
            _TopicProgress(topic: topic, game: game),
            if (topic != FinancialTaskTopic.values.last)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _TopicProgress extends StatelessWidget {
  const _TopicProgress({required this.topic, required this.game});

  final FinancialTaskTopic topic;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final tasks = FinancialTaskCatalog.byTopic(topic);
    final completed = tasks
        .where((task) => game.hasCompletedTask(task.id))
        .length;
    final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(topic.title)),
            Text('$completed/${tasks.length}'),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        FinniProgressBar(
          value: progress,
          height: 8,
          color: completed == tasks.length
              ? AppColors.success
              : AppColors.purple,
          semanticLabel: topic.title,
        ),
      ],
    );
  }
}

class _LastPeriodCard extends StatelessWidget {
  const _LastPeriodCard({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    final summary = game.lastPeriodSummary;
    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Последний период',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          if (summary == null)
            const Text(
              'Заверши первый игровой период – здесь появится его итог.',
            )
          else ...[
            Text(
              'Период ${summary.period}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            _PlanFactRow(
              label: 'Нужно',
              plan: summary.plan.need,
              fact: summary.actuals.needSpent,
            ),
            _PlanFactRow(
              label: 'Хочу',
              plan: summary.plan.want,
              fact: summary.actuals.wantSpent,
            ),
            _PlanFactRow(
              label: 'Коплю',
              plan: summary.plan.save,
              fact: summary.actuals.saved,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Совпало направлений: ${summary.matchedDirections} из 3. В накоплениях после периода: ${summary.savingsAfter}.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanFactRow extends StatelessWidget {
  const _PlanFactRow({
    required this.label,
    required this.plan,
    required this.fact,
  });

  final String label;
  final int plan;
  final int fact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('План $plan  •  Факт $fact'),
        ],
      ),
    );
  }
}

class _PeriodHistoryCard extends StatelessWidget {
  const _PeriodHistoryCard({required this.history});

  final List<PeriodSummary> history;

  @override
  Widget build(BuildContext context) {
    final items = history.reversed.toList(growable: false);
    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'История периодов',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final summary in items)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: AppSpacing.md),
              title: Text('Период ${summary.period}'),
              subtitle: Text(
                '${summary.purchaseCount} покупок • ${summary.matchedDirections}/3 направлений по плану',
              ),
              children: [
                _PlanFactRow(
                  label: 'Нужно',
                  plan: summary.plan.need,
                  fact: summary.actuals.needSpent,
                ),
                _PlanFactRow(
                  label: 'Хочу',
                  plan: summary.plan.want,
                  fact: summary.actuals.wantSpent,
                ),
                _PlanFactRow(
                  label: 'Коплю',
                  plan: summary.plan.save,
                  fact: summary.actuals.saved,
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Осталось ${summary.endBalance} монет • В копилке ${summary.savingsAfter}',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
