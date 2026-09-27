import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_card.dart';
import '../../../core/widgets/finni_progress_bar.dart';
import '../../game/application/game_state_provider.dart';
import '../../profile/application/local_profile_provider.dart';
import '../data/financial_task_catalog.dart';
import '../domain/financial_task.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameStateProvider);
    final profile = ref.watch(localProfileProvider);
    final completed = FinancialTaskCatalog.tasks
        .where((task) => game?.hasCompletedTask(task.id) == true)
        .map((task) => task.id)
        .toSet();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Финансовые задания'),
      ),
      body: SafeArea(
        top: false,
        child: game == null
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'Не удалось открыть задания. Вернись на главный экран и попробуй ещё раз.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                children: [
                  _ProgressCard(
                    completed: completed.length,
                    total: FinancialTaskCatalog.tasks.length,
                    demoMode: profile?.demoMode == true,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  for (final topic in FinancialTaskTopic.values) ...[
                    _TopicHeader(topic: topic),
                    const SizedBox(height: AppSpacing.md),
                    for (final task in FinancialTaskCatalog.byTopic(topic)) ...[
                      _TaskCard(
                        task: task,
                        completed: completed.contains(task.id),
                        rewardReceived: game.hasReceivedTaskReward(task.id),
                        onTap: () => context.push(AppRoutes.task(task.id)),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.demoMode,
  });

  final int completed;
  final int total;
  final bool demoMode;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;

    return FinniCard(
      color: AppColors.purple.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Пройдено $completed из $total',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          FinniProgressBar(
            value: progress,
            semanticLabel: 'Прогресс финансовых заданий',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            demoMode
                ? 'В демо-профиле все задания доступны сразу.'
                : 'Все задания доступны. Можно проходить их в любом порядке.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TopicHeader extends StatelessWidget {
  const _TopicHeader({required this.topic});

  final FinancialTaskTopic topic;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(_topicIcon(topic), color: _topicColor(topic)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            topic.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.completed,
    required this.rewardReceived,
    required this.onTap,
  });

  final FinancialTask task;
  final bool completed;
  final bool rewardReceived;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _topicColor(task.topic).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(_topicIcon(task.topic), color: _topicColor(task.topic)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _kindLabel(task.kind),
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  rewardReceived
                      ? 'Награда получена: ${task.rewardCoins} монет'
                      : completed
                      ? 'Награда доступна при повторном прохождении'
                      : 'Награда: ${task.rewardCoins} монет',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (completed) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text('Пройдено'),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

String _kindLabel(FinancialTaskKind kind) => switch (kind) {
  FinancialTaskKind.allocation => 'Распредели бюджет',
  FinancialTaskKind.savingsAmount => 'Выбери сумму накопления',
  FinancialTaskKind.action => 'Прими финансовое решение',
};

Color _topicColor(FinancialTaskTopic topic) => switch (topic) {
  FinancialTaskTopic.budgetPlanning => AppColors.purple,
  FinancialTaskTopic.savings => AppColors.save,
  FinancialTaskTopic.payments => AppColors.blue,
};

IconData _topicIcon(FinancialTaskTopic topic) => switch (topic) {
  FinancialTaskTopic.budgetPlanning => Icons.fact_check_outlined,
  FinancialTaskTopic.savings => Icons.savings_outlined,
  FinancialTaskTopic.payments => Icons.shopping_bag_outlined,
};
