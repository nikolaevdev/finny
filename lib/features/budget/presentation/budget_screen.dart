import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_button.dart';
import '../../../core/widgets/finni_character.dart';
import '../../../core/widgets/finni_pressable.dart';
import '../../../core/audio/finni_audio.dart';
import '../../game/application/game_state_provider.dart';
import '../../game/domain/budget_plan.dart';
import '../../game/domain/game_state.dart';
import '../../profile/application/local_profile_provider.dart';
import '../../profile/domain/player_profile.dart';

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
      final changed = await ref.read(gameStateProvider.notifier).changeBudget(
            category: category,
            delta: delta,
          );

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
      final confirmed =
          await ref.read(gameStateProvider.notifier).confirmBudget();

      if (confirmed && mounted) {
        FinniAudio.instance.play(AudioCue.success);
      }

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
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameStateProvider);
    final profile = ref.watch(localProfileProvider);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _BudgetBackground()),
          SafeArea(
            child: Column(
              children: [
                _BudgetHeader(onBack: _goBack),
                Expanded(
                  child: game == null
                      ? const _MissingGameState()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.sm,
                            AppSpacing.lg,
                            AppSpacing.xxl,
                          ),
                          child: switch (game.periodStatus) {
                            PeriodStatus.notStarted => _PeriodStartContent(
                                game: game,
                                petAsset: _petArt(profile, game),
                                isWorking: _isWorking,
                                onStart: _startPeriod,
                              ),
                            PeriodStatus.planning => _BudgetPlanningContent(
                                game: game,
                                petAsset: _petArt(profile, game),
                                isWorking: _isWorking,
                                onChange: _changeBudget,
                                onConfirm: _confirmBudget,
                              ),
                            PeriodStatus.planned => _BudgetConfirmedContent(
                                game: game,
                                petAsset: _petArt(profile, game),
                                onBackHome: _goBack,
                              ),
                            PeriodStatus.completed => _BudgetCompletedContent(
                                game: game,
                                petAsset: _petArt(profile, game),
                                onOpenSummary: () =>
                                    context.push(AppRoutes.periodSummary),
                              ),
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _petArt(PlayerProfile? profile, GameState game) {
    final appearance = profile?.pet.appearance;
    return FinniCharacter(
      size: 190,
      colorIndex: appearance?.colorIndex ?? 0,
      earsIndex: appearance?.earsIndex ?? 0,
      patternIndex: appearance?.patternIndex ?? 0,
      developmentStage: game.developmentStage.index,
      mood: game.petMood,
      animate: true,
    );
  }
}

class _BudgetBackground extends StatelessWidget {
  const _BudgetBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/home/explorer_room_story.webp',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          filterQuality: FilterQuality.low,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.textPrimary.withValues(alpha: 0.16),
                AppColors.background.withValues(alpha: 0.22),
                AppColors.background.withValues(alpha: 0.42),
                AppColors.background.withValues(alpha: 0.70),
              ],
              stops: const [0, 0.24, 0.62, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetHeader extends StatelessWidget {
  const _BudgetHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          _BackButton(onTap: onBack),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 62),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF4DEB2).withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD6B67B)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.14),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                'План на период',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FinniPressable(
      effect: FinniPressEffect.icon,
      borderRadius: BorderRadius.circular(22),
      glowColor: AppColors.purple,
      child: Material(
        color: AppColors.purpleDark.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textOnAccent,
            size: 30,
          ),
        ),
      ),
      ),
    );
  }
}

class _PeriodStartContent extends StatelessWidget {
  const _PeriodStartContent({
    required this.game,
    required this.petAsset,
    required this.isWorking,
    required this.onStart,
  });

  final GameState game;
  final Widget petAsset;
  final bool isWorking;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodBadge(game: game),
        const SizedBox(height: AppSpacing.lg),
        _FinniCoach(
          petAsset: petAsset,
          message: 'Получим монеты и составим план на период.',
        ),
        const SizedBox(height: AppSpacing.lg),
        _GamePanel(
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.saveSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: AppColors.gold,
                  size: 42,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      GameState.defaultPeriodIncomeSource,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      '+120 монет',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
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
        Text(
          'Это игровая валюта – реальных платежей в приложении нет.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.xl),
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
    required this.petAsset,
    required this.isWorking,
    required this.onChange,
    required this.onConfirm,
  });

  final GameState game;
  final Widget petAsset;
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
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _AmountCard(
                label: 'Всего монет',
                value: game.planningBudget,
                icon: Icons.stars_rounded,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _AmountCard(
                label: 'Осталось',
                value: remaining,
                icon: Icons.toll_rounded,
                color: AppColors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _FinniCoach(
          petAsset: petAsset,
          message: remaining == 0
              ? 'Все монеты распределены. Проверь план ещё раз – и можно подтверждать.'
              : 'На «Нужно» обычно требуется часть бюджета, но окончательное решение за тобой.',
          compact: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        _BackpackAllocator(
          need: plan.need,
          want: plan.want,
          save: plan.save,
          onNeedMinus: () => onChange(BudgetCategory.need, -10),
          onNeedPlus: () => onChange(BudgetCategory.need, 10),
          onWantMinus: () => onChange(BudgetCategory.want, -10),
          onWantPlus: () => onChange(BudgetCategory.want, 10),
          onSaveMinus: () => onChange(BudgetCategory.save, -10),
          onSavePlus: () => onChange(BudgetCategory.save, 10),
        ),
        const SizedBox(height: AppSpacing.lg),
        _PlanSummary(plan: plan, available: game.planningBudget),
        const SizedBox(height: AppSpacing.xl),
        FinniButton(
          text: isWorking ? 'Сохраняем…' : 'Подтвердить план',
          icon: isWorking ? null : Icons.chevron_right_rounded,
          onPressed: isWorking || plan.allocated == 0 ? null : onConfirm,
        ),
      ],
    );
  }
}

class _BudgetConfirmedContent extends StatelessWidget {
  const _BudgetConfirmedContent({
    required this.game,
    required this.petAsset,
    required this.onBackHome,
  });

  final GameState game;
  final Widget petAsset;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodBadge(game: game),
        const SizedBox(height: AppSpacing.lg),
        _FinniCoach(
          petAsset: petAsset,
          message:
              'План готов! Теперь можно делать покупки и откладывать монеты к цели.',
        ),
        const SizedBox(height: AppSpacing.lg),
        _PlanSummary(
          plan: game.budgetPlan,
          available: game.planningBudget,
        ),
        if (game.periodIncomeSource != null) ...[
          const SizedBox(height: AppSpacing.md),
          _GamePanel(
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
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
    required this.petAsset,
    required this.onOpenSummary,
  });

  final GameState game;
  final Widget petAsset;
  final VoidCallback onOpenSummary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodBadge(game: game),
        const SizedBox(height: AppSpacing.lg),
        _FinniCoach(
          petAsset: petAsset,
          message:
              'Этот период уже завершён. Давай откроем итог и сравним план с фактом.',
        ),
        const SizedBox(height: AppSpacing.lg),
        _PlanSummary(
          plan: game.budgetPlan,
          available: game.planningBudget,
        ),
        const SizedBox(height: AppSpacing.xl),
        FinniButton(
          text: 'Открыть итог периода',
          icon: Icons.bar_chart_rounded,
          onPressed: onOpenSummary,
        ),
      ],
    );
  }
}

class _FinniCoach extends StatelessWidget {
  const _FinniCoach({
    required this.petAsset,
    required this.message,
    this.compact = false,
  });

  final Widget petAsset;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final imageHeight = compact ? 130.0 : 190.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 410;
        if (narrow) {
          return Column(
            children: [
              _SpeechBubble(text: message),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: imageHeight,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: petAsset,
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: math.min(190.0, constraints.maxWidth * 0.36),
              child: SizedBox(
                height: imageHeight,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: petAsset,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _SpeechBubble(text: message)),
          ],
        );
      },
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _BackpackAllocator extends StatelessWidget {
  const _BackpackAllocator({
    required this.need,
    required this.want,
    required this.save,
    required this.onNeedMinus,
    required this.onNeedPlus,
    required this.onWantMinus,
    required this.onWantPlus,
    required this.onSaveMinus,
    required this.onSavePlus,
  });

  final int need;
  final int want;
  final int save;
  final VoidCallback onNeedMinus;
  final VoidCallback onNeedPlus;
  final VoidCallback onWantMinus;
  final VoidCallback onWantPlus;
  final VoidCallback onSaveMinus;
  final VoidCallback onSavePlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF253352), Color(0xFF19253F)],
        ),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: const Color(0xFFB8864D), width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFB8864D),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _BudgetPocket(
                  title: 'Нужно',
                  icon: Icons.home_rounded,
                  value: need,
                  color: AppColors.need,
                  onMinus: onNeedMinus,
                  onPlus: onNeedPlus,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _BudgetPocket(
                  title: 'Хочу',
                  icon: Icons.sports_esports_rounded,
                  value: want,
                  color: AppColors.want,
                  onMinus: onWantMinus,
                  onPlus: onWantPlus,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _BudgetPocket(
                  title: 'Коплю',
                  icon: Icons.savings_rounded,
                  value: save,
                  color: AppColors.save,
                  onMinus: onSaveMinus,
                  onPlus: onSavePlus,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BagDetail(icon: Icons.explore_rounded),
              _BagDetail(icon: Icons.map_outlined),
              _BagDetail(icon: Icons.landscape_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetPocket extends StatelessWidget {
  const _BudgetPocket({
    required this.title,
    required this.icon,
    required this.value,
    required this.color,
    required this.onMinus,
    required this.onPlus,
  });

  final String title;
  final IconData icon;
  final int value;
  final Color color;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textOnAccent,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.stars_rounded,
                color: Color(0xFFFFD263),
                size: 20,
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  '$value',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textOnAccent,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PocketButton(
                tooltip: 'Уменьшить $title на 10',
                icon: Icons.remove_rounded,
                onPressed: value == 0 ? null : onMinus,
                fill: const Color(0xFF5D5A79),
              ),
              const SizedBox(width: 2),
              _PocketButton(
                tooltip: 'Добавить 10 в $title',
                icon: Icons.add_rounded,
                onPressed: onPlus,
                fill: color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PocketButton extends StatelessWidget {
  const _PocketButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.fill,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: onPressed == null
            ? AppColors.disabled.withValues(alpha: 0.42)
            : fill,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              icon,
              color: AppColors.textOnAccent,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

class _BagDetail extends StatelessWidget {
  const _BagDetail({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFB8864D).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: const Color(0xFFFFE2A9), size: 18),
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
          color: AppColors.purpleDark.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        ),
        child: Text(
          'Период ${game.currentPeriod} из ${game.totalPeriods}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textOnAccent,
                fontWeight: FontWeight.w800,
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
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _GamePanel(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanSummary extends StatelessWidget {
  const _PlanSummary({
    required this.plan,
    required this.available,
  });

  final BudgetPlan plan;
  final int available;

  @override
  Widget build(BuildContext context) {
    final free = plan.remainingFrom(available);

    return _GamePanel(
      child: Column(
        children: [
          Text(
            'Твой план',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(label: 'Нужно', value: plan.need, color: AppColors.need),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(label: 'Хочу', value: plan.want, color: AppColors.want),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(label: 'Коплю', value: plan.save, color: AppColors.save),
          const Divider(height: AppSpacing.xl),
          _SummaryRow(
            label: 'Свободно',
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
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const Icon(Icons.stars_rounded, color: AppColors.gold, size: 18),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}

class _GamePanel extends StatelessWidget {
  const _GamePanel({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.09),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
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
