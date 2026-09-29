import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_button.dart';
import '../../../core/audio/finni_audio.dart';
import '../../../core/widgets/finni_character.dart';
import '../../../core/widgets/finni_progress_bar.dart';
import '../../../core/widgets/finni_pressable.dart';
import '../../game/application/game_state_provider.dart';
import '../../game/domain/game_state.dart';
import '../../game/domain/pet_progress.dart';
import '../../profile/application/local_profile_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _backgroundAsset = 'assets/images/home/explorer_room_story.webp';

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
    final art = _HomeFinniArt(
      developmentStage: game.developmentStage.index,
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _backgroundAsset,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.low,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.10),
                    Colors.transparent,
                    AppColors.textPrimary.withValues(alpha: 0.05),
                    AppColors.textPrimary.withValues(alpha: 0.23),
                  ],
                  stops: const [0, 0.26, 0.64, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 760;
                  final tiny = constraints.maxWidth < 370;
                  final extraCompact = constraints.maxHeight < 700;
                  final gap = constraints.maxHeight < 600 ? 5.0 : 8.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ResourceBar(
                        balance: game.balance,
                        savings: game.savings,
                        compact: compact,
                        onBalanceTap: () => context.push(AppRoutes.tasks),
                        onSavingsTap: () => context.push(AppRoutes.savings),
                        onSettings: () => context.push(AppRoutes.settings),
                      ),
                      SizedBox(height: gap),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: math.min(constraints.maxWidth * 0.88, 360.0),
                          ),
                          child: _GoalCard(
                            title: game.selectedGoal.title,
                            saved: game.savings,
                            goal: game.selectedGoal.cost,
                            goalReady: game.goalReadyToComplete,
                            allGoalsCompleted: game.allGoalsCompleted,
                            compact: compact,
                            onTap: () => context.push(AppRoutes.savings),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _HeroScene(
                          game: game,
                          petName: profile.pet.name,
                          stageLabel: art.stageLabel,
                          colorIndex: appearance.colorIndex,
                          earsIndex: appearance.earsIndex,
                          patternIndex: appearance.patternIndex,
                          developmentStage: game.developmentStage.index,
                          message: _finniMessage(game),
                          compact: compact,
                          extraCompact: extraCompact,
                        ),
                      ),
                      SizedBox(height: gap),
                      Row(
                        children: [
                          Expanded(
                            child: _PetStatCard(
                              title: 'Забота',
                              value: game.petCare / 100,
                              valueLabel: '${game.petCare}/100',
                              icon: Icons.favorite_rounded,
                              color: AppColors.need,
                              compact: compact,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _PetStatCard(
                              title: 'Настроение',
                              value: game.petMood / 100,
                              valueLabel: game.moodLevel.title,
                              icon: _moodIcon(game.moodLevel),
                              imageAsset: FinniCharacter.moodAsset(
                                  game.petMood, appearance.colorIndex),
                              color: AppColors.want,
                              compact: compact,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: gap),
                      SizedBox(
                        height: compact ? 88 : 118,
                        child: Row(
                          children: [
                            Expanded(
                              child: _ActionTile(
                                title: game.periodStatus == PeriodStatus.planned ||
                                        game.periodStatus == PeriodStatus.completed
                                    ? 'Итоги'
                                    : 'План',
                                icon: game.periodStatus == PeriodStatus.planned ||
                                        game.periodStatus == PeriodStatus.completed
                                    ? Icons.bar_chart_rounded
                                    : Icons.fact_check_outlined,
                                color: AppColors.purple,
                                iconAsset: 'assets/images/navigation/plan.png',
                                compact: compact,
                                tiny: tiny,
                                onTap: () => context.push(
                                  game.periodStatus == PeriodStatus.planned ||
                                          game.periodStatus == PeriodStatus.completed
                                      ? AppRoutes.periodSummary
                                      : AppRoutes.budget,
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: _ActionTile(
                                title: 'Магазин',
                                icon: Icons.storefront_rounded,
                                color: AppColors.blue,
                                iconAsset: 'assets/images/navigation/shop.png',
                                compact: compact,
                                tiny: tiny,
                                onTap: () => context.push(AppRoutes.shop),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: _ActionTile(
                                title: 'Задания',
                                icon: Icons.explore_outlined,
                                color: AppColors.need,
                                iconAsset: 'assets/images/navigation/tasks.png',
                                compact: compact,
                                tiny: tiny,
                                onTap: () => context.push(AppRoutes.tasks),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: _ActionTile(
                                title: 'Цель',
                                icon: Icons.flag_circle_outlined,
                                color: AppColors.save,
                                iconAsset: 'assets/images/navigation/goal.png',
                                compact: compact,
                                tiny: tiny,
                                onTap: () => context.push(AppRoutes.savings),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gap),
                      Row(
                        children: [
                          Expanded(
                            child: _SecondaryAction(
                              title: 'Прогресс',
                              icon: Icons.bar_chart_rounded,
                              compact: compact,
                              onTap: () => context.push(AppRoutes.progress),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SecondaryAction(
                              title: 'Для взрослого',
                              icon: Icons.family_restroom_rounded,
                              compact: compact,
                              onTap: () => context.push(AppRoutes.adultAccess),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _moodIcon(PetMoodLevel mood) => switch (mood) {
        PetMoodLevel.quiet => Icons.sentiment_dissatisfied_rounded,
        PetMoodLevel.calm => Icons.sentiment_neutral_rounded,
        PetMoodLevel.happy => Icons.sentiment_satisfied_alt_rounded,
        PetMoodLevel.delighted => Icons.sentiment_very_satisfied_rounded,
      };

  String _finniMessage(GameState game) {
    if (game.periodStatus == PeriodStatus.planned &&
        (game.purchases.isNotEmpty || game.budgetActuals.saved > 0)) {
      return switch (game.moodLevel) {
        PetMoodLevel.quiet => 'Немного грустно. Давай посмотрим, что можно сделать дальше.',
        PetMoodLevel.calm => 'План идёт спокойно. Потом сравним его с тем, что получилось.',
        PetMoodLevel.happy => 'Мне нравится, как идёт период. Потом сравним план и факт!',
        PetMoodLevel.delighted => 'Отлично идём! Потом посмотрим, насколько план совпал с фактом.',
      };
    }

    return switch (game.periodStatus) {
      PeriodStatus.notStarted =>
        'Начнём с плана? Вместе решим, что важнее.',
      PeriodStatus.planning =>
        'Разделим монеты на нужное, желания и мечту.',
      PeriodStatus.planned =>
        'План готов. Выберем покупку или пополним копилку?',
      PeriodStatus.completed => game.allPeriodsCompleted
          ? 'Все пять периодов пройдены! Посмотрим результат.'
          : 'Период завершён! Посмотрим итоги.',
    };
  }
}

class _ResourceBar extends StatelessWidget {
  const _ResourceBar({
    required this.balance,
    required this.savings,
    required this.compact,
    required this.onBalanceTap,
    required this.onSavingsTap,
    required this.onSettings,
  });

  final int balance;
  final int savings;
  final bool compact;
  final VoidCallback onBalanceTap;
  final VoidCallback onSavingsTap;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 44.0 : 52.0;
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: _ResourcePill(
              value: balance,
              icon: Icons.stars_rounded,
              iconColor: AppColors.gold,
              compact: compact,
              onTap: onBalanceTap,
              semanticLabel: 'Монеты: $balance. Открыть задания',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ResourcePill(
              value: savings,
              icon: Icons.savings_rounded,
              iconColor: AppColors.need,
              compact: compact,
              onTap: onSavingsTap,
              semanticLabel: 'Накоплено: $savings. Открыть цель',
            ),
          ),
          const SizedBox(width: 8),
          FinniPressable(
            effect: FinniPressEffect.icon,
            borderRadius: BorderRadius.circular(18),
            glowColor: AppColors.purple,
            child: Material(
              color: AppColors.purpleDark.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: onSettings,
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: height,
                  height: height,
                  child: const Icon(
                    Icons.settings_rounded,
                    color: AppColors.textOnAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourcePill extends StatelessWidget {
  const _ResourcePill({
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.compact,
    required this.onTap,
    required this.semanticLabel,
  });

  final int value;
  final IconData icon;
  final Color iconColor;
  final bool compact;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: FinniPressable(
        effect: FinniPressEffect.button,
        borderRadius: BorderRadius.circular(18),
        glowColor: iconColor,
        child: Material(
          color: AppColors.purple.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
          onTap: () {
            FinniAudio.instance.play(AudioCue.tap);
            onTap();
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 10,
              vertical: compact ? 7 : 9,
            ),
            child: Row(
        children: [
          Container(
            width: compact ? 30 : 34,
            height: compact ? 30 : 34,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: compact ? 18 : 20),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              '$value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (compact
                      ? Theme.of(context).textTheme.titleMedium
                      : Theme.of(context).textTheme.titleLarge)
                  ?.copyWith(
                    color: AppColors.textOnAccent,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textOnAccent, size: 18),
        ],
      ),
          ),
        ),
      ),
      ),
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
    required this.compact,
    required this.onTap,
  });

  final String title;
  final int saved;
  final int goal;
  final bool goalReady;
  final bool allGoalsCompleted;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = allGoalsCompleted
        ? 1.0
        : goal <= 0
            ? 0.0
            : (saved / goal).clamp(0.0, 1.0).toDouble();

    return FinniPressable(
      effect: FinniPressEffect.card,
      borderRadius: BorderRadius.circular(24),
      glowColor: AppColors.save,
      child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          FinniAudio.instance.play(AudioCue.tap);
          onTap();
        },
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          height: compact ? 84 : 94,
          padding: EdgeInsets.all(compact ? 9 : 11),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface.withValues(alpha: 0.98),
                AppColors.saveSoft.withValues(alpha: 0.92),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: compact ? 44 : 52,
                height: compact ? 44 : 52,
                decoration: BoxDecoration(
                  color: AppColors.saveSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.home_work_rounded,
                  color: AppColors.save,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            allGoalsCompleted ? 'Все цели выполнены' : title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    FinniProgressBar(
                      value: progress,
                      color: AppColors.need,
                      backgroundColor: AppColors.surfaceMuted,
                      height: compact ? 8 : 10,
                      semanticLabel: 'Прогресс цели',
                    ),
                    const SizedBox(height: 2),
                    Text(
                      allGoalsCompleted
                          ? 'В копилке $saved'
                          : goalReady
                              ? 'Цель уже достижима'
                              : '$saved / $goal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _HeroScene extends StatelessWidget {
  const _HeroScene({
    required this.game,
    required this.petName,
    required this.stageLabel,
    required this.colorIndex,
    required this.earsIndex,
    required this.patternIndex,
    required this.developmentStage,
    required this.message,
    required this.compact,
    required this.extraCompact,
  });

  final GameState game;
  final String petName;
  final String stageLabel;
  final int colorIndex;
  final int earsIndex;
  final int patternIndex;
  final int developmentStage;
  final String message;
  final bool compact;
  final bool extraCompact;

  bool _wasPurchased(String itemId) {
    return game.purchases.any((purchase) => purchase.itemId == itemId);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final heroHeight = math.min(
          constraints.maxHeight * (extraCompact ? 0.81 : 0.84),
          compact ? 252.0 : 350.0,
        );
        final heroWidth = math.min(
          constraints.maxWidth * 0.68,
          compact ? 268.0 : 330.0,
        );
        final bubbleWidth = math.min(
          constraints.maxWidth * 0.50,
          compact ? 184.0 : 220.0,
        );
        final decorScale = math.min(
          1.0,
          math.min(constraints.maxWidth / 380, constraints.maxHeight / 320),
        ).clamp(0.62, 1.0).toDouble();

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            if (game.ownsItem('sleep_place'))
              Positioned(
                left: 0,
                bottom: 0,
                width: 118 * decorScale,
                child: const _RoomDecorAsset(
                  asset: 'assets/images/shop/items/sleep_place.png',
                ),
              ),
            if (game.ownsItem('plant'))
              Positioned(
                right: 0,
                bottom: 65 * decorScale,
                width: 78 * decorScale,
                child: const _RoomDecorAsset(
                  asset: 'assets/images/shop/items/plant.png',
                ),
              ),
            if (game.ownsItem('star_lamp'))
              Positioned(
                left: 4 * decorScale,
                top: constraints.maxHeight * 0.14,
                width: 68 * decorScale,
                child: const _RoomDecorAsset(
                  asset: 'assets/images/shop/items/star_lamp.png',
                ),
              ),
            if (game.ownsItem('explorer_journal'))
              Positioned(
                right: 61 * decorScale,
                bottom: 2 * decorScale,
                width: 56 * decorScale,
                child: const _RoomDecorAsset(
                  asset: 'assets/images/shop/items/explorer_journal.png',
                ),
              ),
            if (_wasPurchased('ball'))
              Positioned(
                right: 1 * decorScale,
                bottom: 0,
                width: 58 * decorScale,
                child: const _RoomDecorAsset(
                  asset: 'assets/images/shop/items/ball.png',
                ),
              ),
            Positioned(
              left: constraints.maxWidth * 0.14,
              bottom: constraints.maxHeight * 0.01,
              child: SizedBox(
                width: heroWidth,
                height: heroHeight,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: FinniCharacter(
                    size: 310,
                    displaySizeHint: math.min(heroWidth, heroHeight),
                    colorIndex: colorIndex,
                    earsIndex: earsIndex,
                    patternIndex: patternIndex,
                    developmentStage: developmentStage,
                    mood: game.petMood,
                    semanticLabel: '$petName, $stageLabel',
                    animate: true,
                    tapReaction: true,
                  ),
                ),
              ),
            ),
            Positioned(
              right: constraints.maxWidth * 0.03,
              top: compact ? 16 : 18,
              width: bubbleWidth,
              child: _SpeechBubble(
                text: message,
                compact: compact,
                moodAsset: FinniCharacter.moodAsset(game.petMood, colorIndex),
                moodLabel: game.moodLevel.title,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Semantics(label: '$petName, $stageLabel'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RoomDecorAsset extends StatelessWidget {
  const _RoomDecorAsset({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) => Image.asset(
            asset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            cacheWidth: (constraints.maxWidth *
                    MediaQuery.devicePixelRatioOf(context))
                .ceil()
                .clamp(160, 512)
                .toInt(),
          ),
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({
    required this.text,
    required this.compact,
    required this.moodAsset,
    required this.moodLabel,
  });

  final String text;
  final bool compact;
  final String moodAsset;
  final String moodLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: compact ? 9 : 11,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.80)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: 'Настроение: $moodLabel',
                child: ClipOval(
                  child: Image.asset(
                    moodAsset,
                    width: compact ? 24 : 28,
                    height: compact ? 24 : 28,
                    fit: BoxFit.cover,
                    cacheWidth: (64 * MediaQuery.devicePixelRatioOf(context))
                        .ceil().clamp(96, 256).toInt(),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                maxLines: compact ? 3 : 4,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: (compact
                        ? Theme.of(context).textTheme.bodySmall
                        : Theme.of(context).textTheme.bodyMedium)
                    ?.copyWith(fontWeight: FontWeight.w700, height: 1.18),
              ),
            ],
          ),
        ),
        Positioned(
          left: 24,
          bottom: -8,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 18,
              height: 18,
              color: AppColors.surface.withValues(alpha: 0.95),
            ),
          ),
        ),
      ],
    );
  }
}

class _PetStatCard extends StatelessWidget {
  const _PetStatCard({
    required this.title,
    required this.value,
    required this.valueLabel,
    required this.icon,
    required this.color,
    required this.compact,
    this.imageAsset,
  });

  final String title;
  final double value;
  final String valueLabel;
  final IconData icon;
  final Color color;
  final bool compact;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $valueLabel',
      child: Container(
        height: compact ? 70 : 80,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 11,
          vertical: compact ? 7 : 9,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              Color.lerp(AppColors.surface, color, 0.12)!,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: compact ? 34 : 40,
              height: compact ? 34 : 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: imageAsset == null
                  ? Icon(icon, color: color, size: compact ? 19 : 22)
                  : ClipOval(
                      child: Image.asset(
                        imageAsset!,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        cacheWidth: (40 * MediaQuery.devicePixelRatioOf(context))
                            .ceil()
                            .clamp(96, 192)
                            .toInt(),
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Text(
                    valueLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: compact ? 12 : 13,
                        ),
                  ),
                  const SizedBox(height: 3),
                  FinniProgressBar(
                    value: value,
                    color: color,
                    backgroundColor: AppColors.surfaceMuted,
                    height: compact ? 6 : 8,
                    semanticLabel: title,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.iconAsset,
    required this.compact,
    required this.tiny,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String iconAsset;
  final bool compact;
  final bool tiny;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.textOnAccent;
    final radius = BorderRadius.circular(compact ? 22 : 28);

    return FinniPressable(
      effect: FinniPressEffect.reward,
      borderRadius: radius,
      glowColor: color,
      child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          FinniAudio.instance.play(AudioCue.tap);
          onTap();
        },
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(Colors.white, color, 0.58)!,
                color,
                Color.lerp(color, AppColors.textPrimary, 0.13)!,
              ],
              stops: const [0, 0.55, 1],
            ),
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.82),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.24),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  height: compact ? 20 : 26,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(compact ? 22 : 28),
                      topRight: Radius.circular(compact ? 22 : 28),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.22),
                        Colors.white.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tiny ? 5 : 7,
                  compact ? 6 : 10,
                  tiny ? 5 : 7,
                  compact ? 6 : 9,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: RepaintBoundary(
                          child: Image.asset(
                            iconAsset,
                            width: compact ? 38 : 60,
                            height: compact ? 38 : 60,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.medium,
                            cacheWidth: ((compact ? 38 : 60) *
                                    MediaQuery.devicePixelRatioOf(context))
                                .ceil()
                                .clamp(128, 256)
                                .toInt(),
                            errorBuilder: (context, error, stackTrace) => Icon(
                              icon,
                              color: foreground,
                              size: compact ? 30 : 44,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 1 : 5),
                    SizedBox(
                      height: compact ? 18 : 22,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: foreground,
                                      fontWeight: FontWeight.w900,
                                      fontSize: compact ? 10.9 : 14.4,
                                      height: 1.0,
                                      shadows: const [
                                        Shadow(
                                          color: Color(0x33000000),
                                          blurRadius: 6,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 1),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: foreground.withValues(alpha: 0.98),
                                size: compact ? 16 : 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.title,
    required this.icon,
    required this.compact,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FinniPressable(
      effect: FinniPressEffect.button,
      borderRadius: BorderRadius.circular(22),
      glowColor: AppColors.purple,
      child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          FinniAudio.instance.play(AudioCue.tap);
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: compact ? 44 : 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.80)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.purple, size: compact ? 19 : 21),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 19,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _HomeFinniArt {
  const _HomeFinniArt({
    required this.developmentStage,
  });

  final int developmentStage;

  int get _safeStage => developmentStage.clamp(0, 2).toInt();

  String get stageLabel => switch (_safeStage) {
        1 => 'Подрос',
        2 => 'Уверенный',
        _ => 'Малыш',
      };
}
