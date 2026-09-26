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
import '../../game/domain/pet_progress.dart';
import '../../profile/application/local_profile_provider.dart';
import '../../tasks/data/financial_task_catalog.dart';
import '../../tasks/domain/financial_task.dart';

class AdultScreen extends ConsumerStatefulWidget {
  const AdultScreen({super.key});

  @override
  ConsumerState<AdultScreen> createState() => _AdultScreenState();
}

class _AdultScreenState extends ConsumerState<AdultScreen> {
  bool _isResetting = false;

  Future<void> _resetDemoProfile() async {
    final profile = ref.read(localProfileProvider);
    if (profile == null || !profile.demoMode || _isResetting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Сбросить демо-прогресс?'),
        content: const Text(
          'Игровой прогресс тестового профиля вернётся к исходному состоянию. Внешность Финни и имя профиля сохранятся.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isResetting = true);
    try {
      await ref
          .read(gameStateProvider.notifier)
          .resetForProfile(demoMode: true);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Демо-прогресс сброшен. Сценарий можно пройти заново.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Не удалось сбросить демо-прогресс.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(localProfileProvider);
    final game = ref.watch(gameStateProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'На главную',
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Для взрослого'),
      ),
      body: profile == null || game == null
          ? const Center(child: Text('Данные профиля не найдены.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                const _PurposeCard(),
                const SizedBox(height: AppSpacing.lg),
                _OverallProgressCard(game: game),
                const SizedBox(height: AppSpacing.lg),
                _TopicProgressCard(game: game),
                const SizedBox(height: AppSpacing.lg),
                _LearningStateCard(game: game),
                if (profile.demoMode) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _DemoCard(
                    game: game,
                    isResetting: _isResetting,
                    onReset: _resetDemoProfile,
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.lg),
                  const FinniCard(
                    color: AppColors.surfaceSecondary,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.purple),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Этот профиль создан в обычном режиме. Быстрый сброс экспертного сценария доступен только у демо-профиля.',
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

class _PurposeCard extends StatelessWidget {
  const _PurposeCard();

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.surfaceSecondary,
                child: Icon(Icons.family_restroom_rounded, color: AppColors.purple),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Зачем нужен Финни',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Приложение помогает ребёнку тренировать базовые финансовые навыки через игровые решения: планировать бюджет, отличать нужные расходы от желаний, копить на цель и осознанно совершать покупки.',
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Здесь нет оценок ребёнка. Раздел показывает только пройденные темы и общий прогресс.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _OverallProgressCard extends StatelessWidget {
  const _OverallProgressCard({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    final completedTasks = game.completedTaskIds.length
        .clamp(0, FinancialTaskCatalog.tasks.length)
        .toInt();
    final taskProgress = FinancialTaskCatalog.tasks.isEmpty
        ? 0.0
        : completedTasks / FinancialTaskCatalog.tasks.length;
    final periodProgress = game.totalPeriods <= 0
        ? 0.0
        : (game.periodHistory.length / game.totalPeriods)
            .clamp(0.0, 1.0)
            .toDouble();

    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Общий прогресс', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          _ProgressLine(
            label: 'Финансовые задания',
            value: taskProgress,
            valueLabel: '$completedTasks/${FinancialTaskCatalog.tasks.length}',
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProgressLine(
            label: 'Игровые периоды',
            value: periodProgress,
            valueLabel: '${game.periodHistory.length}/${game.totalPeriods}',
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _ValueTile(
                  title: 'Накоплено',
                  value: '${game.savings}',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ValueTile(
                  title: 'Стадия Финни',
                  value: game.developmentStage.title,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopicProgressCard extends StatelessWidget {
  const _TopicProgressCard({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Пройденные темы', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          for (final topic in FinancialTaskTopic.values) ...[
            _TopicRow(topic: topic, game: game),
            if (topic != FinancialTaskTopic.values.last)
              const Divider(height: AppSpacing.xl),
          ],
        ],
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic, required this.game});

  final FinancialTaskTopic topic;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final tasks = FinancialTaskCatalog.byTopic(topic);
    final completed = tasks
        .where((task) => game.completedTaskIds.contains(task.id))
        .length;

    return Row(
      children: [
        const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(topic.title)),
        Text(
          '$completed/${tasks.length}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _LearningStateCard extends StatelessWidget {
  const _LearningStateCard({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    final goalPercent = game.selectedGoal.cost <= 0
        ? 0
        : ((game.savings / game.selectedGoal.cost) * 100).clamp(0, 100).round();

    return FinniCard(
      color: AppColors.surfaceSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Сейчас в игре', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Text('Цель: ${game.selectedGoal.title}'),
          const SizedBox(height: AppSpacing.xs),
          Text(
            game.allGoalsCompleted
                ? 'Финансовые цели: выполнены все ${game.completedGoalIds.length}'
                : 'Прогресс текущей цели: $goalPercent%',
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Настроение Финни: ${game.moodLevel.title}'),
          const SizedBox(height: AppSpacing.xs),
          Text('Завершено периодов: ${game.periodHistory.length}'),
        ],
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({
    required this.game,
    required this.isResetting,
    required this.onReset,
  });

  final GameState game;
  final bool isResetting;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, color: AppColors.purple),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Демонстрационный режим',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Все обязательные этапы можно проходить подряд без ожидания календарного времени. Сброс возвращает только игровой прогресс тестового профиля к исходному состоянию.',
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Text(
              game.periodHistory.isEmpty
                  ? 'Демо-сценарий готов к прохождению.'
                  : 'Сейчас завершено периодов: ${game.periodHistory.length}.',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FinniButton(
            text: isResetting ? 'Сбрасываем…' : 'Сбросить демо-прогресс',
            icon: Icons.restart_alt_rounded,
            onPressed: isResetting ? null : onReset,
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
    required this.valueLabel,
  });

  final String label;
  final double value;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(valueLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.small),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 9,
            backgroundColor: AppColors.surfaceSecondary,
            color: AppColors.purple,
          ),
        ),
      ],
    );
  }
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
