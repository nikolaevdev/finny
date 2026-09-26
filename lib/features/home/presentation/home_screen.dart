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
import '../../game/application/game_state_provider.dart';
import '../../game/domain/game_state.dart';
import '../../profile/application/local_profile_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showStageMessage(BuildContext context, String section) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$section пока закрыт.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _GoalCard(
                      title: game.selectedGoal.title,
                      saved: game.savings,
                      goal: game.selectedGoal.cost,
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
                              borderRadius:
                                  BorderRadius.circular(AppRadius.medium),
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
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _PetStat(
                            title: 'Настроение',
                            icon: Icons.sentiment_satisfied_alt_rounded,
                            color: AppColors.want,
                            value: game.petMood / 100,
                          ),
                        ),
                      ],
                    ),
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
                          title: 'План',
                          subtitle: _planSubtitle(game),
                          icon: Icons.fact_check_outlined,
                          color: AppColors.purple,
                          onTap: () => context.push(AppRoutes.budget),
                        ),
                        _ActionTile(
                          title: 'Магазин',
                          icon: Icons.storefront_rounded,
                          color: AppColors.blue,
                          subtitle: game.budgetConfirmed
                              ? '${game.purchases.length} покупок'
                              : 'После плана',
                          onTap: () => context.push(AppRoutes.shop),
                        ),
                        _ActionTile(
                          title: 'Задания',
                          icon: Icons.explore_outlined,
                          color: AppColors.need,
                          onTap: () => _showStageMessage(context, 'Задания'),
                        ),
                        _ActionTile(
                          title: 'Цель',
                          subtitle: '${game.savings}/${game.selectedGoal.cost}',
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
                            onTap: () =>
                                _showStageMessage(context, 'Прогресс'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _SecondaryAction(
                            title: 'Для взрослого',
                            icon: Icons.supervisor_account_outlined,
                            onTap: () => _showStageMessage(
                              context,
                              'Раздел взрослого',
                            ),
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
                          borderRadius: BorderRadius.circular(
                            AppRadius.medium,
                          ),
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
    return switch (game.periodStatus) {
      PeriodStatus.notStarted =>
        'Начнём новый период и решим, как распорядиться монетами?',
      PeriodStatus.planning =>
        'План ещё не готов. Распределим монеты между тремя направлениями.',
      PeriodStatus.planned =>
        'План готов! Теперь можно проверить его в игровых ситуациях.',
    };
  }

  String _planSubtitle(GameState game) {
    return switch (game.periodStatus) {
      PeriodStatus.notStarted => 'Начать период',
      PeriodStatus.planning => 'Продолжить',
      PeriodStatus.planned => 'План готов',
    };
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud({
    required this.balance,
    required this.playerName,
  });

  final int balance;
  final String playerName;

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
                Text(
                  '$balance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
          onPressed: () {},
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
    required this.onTap,
  });

  final String title;
  final int saved;
  final int goal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = goal <= 0
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
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Коплю: $saved из $goal',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.small),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              color: AppColors.need,
              backgroundColor: AppColors.surfaceSecondary,
            ),
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

class _PetStat extends StatelessWidget {
  const _PetStat({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
  });

  final String title;
  final IconData icon;
  final Color color;
  final double value;

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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: value,
              color: color,
              backgroundColor: AppColors.surfaceSecondary,
            ),
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
      label: Text(
        title,
        maxLines: 2,
        textAlign: TextAlign.center,
      ),
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
