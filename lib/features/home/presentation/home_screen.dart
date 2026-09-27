import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_button.dart';
import '../../../core/widgets/finni_card.dart';
import '../../../core/widgets/finni_preview.dart';
import '../../../core/widgets/finni_progress_bar.dart';
import '../../game/application/game_state_provider.dart';
import '../../game/domain/game_state.dart';
import '../../game/domain/pet_progress.dart';
import '../../profile/application/local_profile_provider.dart';
import '../../tasks/data/financial_task_catalog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(localProfileProvider);
    final game = ref.watch(gameStateProvider);

    if (profile == null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_off_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Локальный профиль не найден',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Создай профиль и Финни, чтобы продолжить.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                FinniButton(
                  text: 'К началу',
                  onPressed: () => context.go(AppRoutes.onboarding),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (game == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Игровое состояние не найдено. Перезапусти приложение.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    final appearance = profile.pet.appearance;
    final activeTask = FinancialTaskCatalog.firstIncomplete(
      game.completedTaskIds,
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopHud(
                      balance: game.balance,
                      playerName: profile.playerName,
                      onSettings: () => context.push(AppRoutes.settings),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _GoalCard(
                      title: game.selectedGoal.title,
                      saved: game.savings,
                      goal: game.selectedGoal.cost,
                      goalReady: game.goalReadyToComplete,
                      allGoalsCompleted: game.allGoalsCompleted,
                      onTap: () => context.push(AppRoutes.savings),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PeriodStatusCard(game: game),
                    const SizedBox(height: AppSpacing.xl),
                    Center(
                      child: Column(
                        children: [
                          FinniPreview(
                            size: 190,
                            colorIndex: appearance.colorIndex,
                            earsIndex: appearance.earsIndex,
                            patternIndex: appearance.patternIndex,
                            label: profile.pet.name,
                            mood: game.petMood,
                            developmentStage: game.developmentStage.index,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 320),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                AppRadius.medium,
                              ),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Text(
                              _finniMessage(game),
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: _PetStat(
                            title: 'Забота',
                            icon: Icons.favorite_rounded,
                            color: AppColors.need,
                            value: game.petCare / 100,
                            valueLabel: '${game.petCare}/100',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _PetStat(
                            title: 'Настроение',
                            icon: _moodIcon(game.moodLevel),
                            color: AppColors.want,
                            value: game.petMood / 100,
                            valueLabel: game.moodLevel.title,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _DevelopmentCard(game: game),
                    const SizedBox(height: AppSpacing.xl),
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.55,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _ActionTile(
                          title:
                              game.periodStatus == PeriodStatus.planned ||
                                  game.periodStatus == PeriodStatus.completed
                              ? 'Итог периода'
                              : 'План',
                          subtitle: _planSubtitle(game),
                          icon:
                              game.periodStatus == PeriodStatus.planned ||
                                  game.periodStatus == PeriodStatus.completed
                              ? Icons.bar_chart_rounded
                              : Icons.fact_check_outlined,
                          color: AppColors.purple,
                          onTap: () => context.push(
                            game.periodStatus == PeriodStatus.planned ||
                                    game.periodStatus == PeriodStatus.completed
                                ? AppRoutes.periodSummary
                                : AppRoutes.budget,
                          ),
                        ),
                        _ActionTile(
                          title: 'Магазин',
                          icon: Icons.storefront_rounded,
                          color: AppColors.blue,
                          subtitle: game.budgetConfirmed
                              ? '${game.purchases.length} покупок'
                              : game.periodCompleted
                              ? 'Период завершён'
                              : 'После плана',
                          onTap: () => context.push(AppRoutes.shop),
                        ),
                        _ActionTile(
                          title: 'Задания',
                          subtitle: activeTask == null
                              ? 'Все ${FinancialTaskCatalog.tasks.length} пройдены'
                              : 'Дальше: ${activeTask.title}',
                          icon: Icons.explore_outlined,
                          color: AppColors.need,
                          onTap: () => context.push(AppRoutes.tasks),
                        ),
                        _ActionTile(
                          title: 'Цель',
                          subtitle: game.allGoalsCompleted
                              ? 'Все цели выполнены'
                              : game.goalReadyToComplete
                              ? 'Можно завершить цель'
                              : '${game.savings}/${game.selectedGoal.cost}',
                          icon: Icons.track_changes_rounded,
                          color: AppColors.save,
                          onTap: () => context.push(AppRoutes.savings),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _SecondaryAction(
                            title: 'Прогресс',
                            icon: Icons.bar_chart_rounded,
                            onTap: () => context.push(AppRoutes.progress),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _SecondaryAction(
                            title: 'Для взрослого',
                            icon: Icons.supervisor_account_outlined,
                            onTap: () => context.push(AppRoutes.adultAccess),
                          ),
                        ),
                      ],
                    ),
                    if (profile.demoMode) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.science_outlined,
                              color: AppColors.purple,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Демо-профиль активен. Для демонстрации '
                                'цель уже имеет стартовый прогресс.',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _finniMessage(GameState game) {
    if (game.periodStatus == PeriodStatus.planned &&
        (game.purchases.isNotEmpty || game.budgetActuals.saved > 0)) {
      final reaction = switch (game.moodLevel) {
        PetMoodLevel.quiet => 'Я немного загрустил, но это легко исправить.',
        PetMoodLevel.calm => 'У меня спокойное настроение.',
        PetMoodLevel.happy => 'Я доволен нашими решениями!',
        PetMoodLevel.delighted => 'Я очень рад нашим решениям!',
      };
      return '$reaction Когда закончишь, сравним план с фактом.';
    }

    return switch (game.periodStatus) {
      PeriodStatus.notStarted =>
        'Начнём новый период и решим, как распорядиться монетами?',
      PeriodStatus.planning =>
        'План ещё не готов. Распределим монеты между тремя направлениями.',
      PeriodStatus.planned =>
        'План готов! Когда закончишь с решениями, сравним план с фактом.',
      PeriodStatus.completed =>
        game.allPeriodsCompleted
            ? '${game.moodLevel.title}. Все пять периодов пройдены – оставшиеся монеты можно отправить к цели.'
            : '${game.moodLevel.title}. Период завершён – посмотрим итог и мой рост?',
    };
  }

  IconData _moodIcon(PetMoodLevel mood) => switch (mood) {
    PetMoodLevel.quiet => Icons.sentiment_dissatisfied_rounded,
    PetMoodLevel.calm => Icons.sentiment_neutral_rounded,
    PetMoodLevel.happy => Icons.sentiment_satisfied_alt_rounded,
    PetMoodLevel.delighted => Icons.sentiment_very_satisfied_rounded,
  };

  String _planSubtitle(GameState game) {
    return switch (game.periodStatus) {
      PeriodStatus.notStarted => 'Начать период',
      PeriodStatus.planning => 'Продолжить',
      PeriodStatus.planned => 'Сравнить план и факт',
      PeriodStatus.completed =>
        game.allPeriodsCompleted ? '5 периодов пройдено' : 'Открыть итог',
    };
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud({
    required this.balance,
    required this.playerName,
    required this.onSettings,
  });

  final int balance;
  final String playerName;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FinniCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: AppColors.gold,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('$balance', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'монет',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    playerName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton.filledTonal(
          tooltip: 'Настройки',
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.saved,
    required this.goal,
    required this.goalReady,
    required this.allGoalsCompleted,
    required this.onTap,
  });

  final String title;
  final int saved;
  final int goal;
  final bool goalReady;
  final bool allGoalsCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = allGoalsCompleted
        ? 1.0
        : goal <= 0
        ? 0.0
        : (saved / goal).clamp(0.0, 1.0).toDouble();

    return FinniCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.surfaceSecondary,
                child: Icon(
                  Icons.travel_explore_rounded,
                  color: AppColors.purple,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allGoalsCompleted
                          ? 'Все финансовые цели выполнены'
                          : title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      allGoalsCompleted
                          ? 'В копилке осталось: $saved монет'
                          : goalReady
                          ? 'На цель уже хватает – можно завершить её'
                          : 'Коплю: $saved из $goal',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FinniProgressBar(
            value: progress,
            color: AppColors.need,
            semanticLabel: 'Прогресс финансовой цели',
          ),
        ],
      ),
    );
  }
}

class _PeriodStatusCard extends StatelessWidget {
  const _PeriodStatusCard({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (game.periodStatus) {
      PeriodStatus.notStarted => (
        'Период ${game.currentPeriod} из ${game.totalPeriods} ещё не начат',
        Icons.play_circle_outline_rounded,
        AppColors.purple,
      ),
      PeriodStatus.planning => (
        'Период ${game.currentPeriod}: бюджет составляется',
        Icons.edit_note_rounded,
        AppColors.save,
      ),
      PeriodStatus.planned => (
        'Период ${game.currentPeriod}: план подтверждён',
        Icons.task_alt_rounded,
        AppColors.success,
      ),
      PeriodStatus.completed => (
        game.allPeriodsCompleted
            ? 'Все ${game.totalPeriods} периодов завершены'
            : 'Период ${game.currentPeriod}: завершён',
        Icons.flag_circle_outlined,
        AppColors.purple,
      ),
    };

    return FinniCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.surfaceSecondary,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DevelopmentCard extends StatelessWidget {
  const _DevelopmentCard({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    final progress = game.developmentProgress;
    final stage = progress.stage;

    return FinniCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${stage.index + 1}',
              style: const TextStyle(
                color: AppColors.purple,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Рост: ${stage.title}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  stage.shortReason,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PetStat extends StatelessWidget {
  const _PetStat({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
    required this.valueLabel,
  });

  final String title;
  final IconData icon;
  final Color color;
  final double value;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            valueLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FinniProgressBar(
            value: value,
            color: color,
            height: 8,
            semanticLabel: title,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(title, maxLines: 2, textAlign: TextAlign.center),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    );
  }
}
