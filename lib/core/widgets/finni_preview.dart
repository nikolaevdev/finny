import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'finni_character.dart';

/// The same composed character used on the home scene and in the creator.
class FinniPreview extends StatelessWidget {
  const FinniPreview({
    super.key,
    this.size = 220,
    this.label = 'Финни',
    this.colorIndex = 0,
    this.earsIndex = 0,
    this.patternIndex = 0,
    this.mood = 60,
    this.developmentStage = 0,
    this.animate = false,
  });

  final double size;
  final String label;
  final int colorIndex;
  final int earsIndex;
  final int patternIndex;
  final int mood;
  final int developmentStage;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final color = colorIndex.clamp(0, 2).toInt();
    final stage = developmentStage.clamp(0, 2).toInt();
    final ears = earsIndex.clamp(0, 2).toInt();
    final pattern = patternIndex.clamp(0, 2).toInt();
    final accent = [AppColors.need, AppColors.save, AppColors.purple][color];
    final stageLabel = ['Малыш', 'Подрос', 'Уверенный'][stage];
    final earsLabel = ['заострённые', 'округлые', 'висячие'][ears];
    final patternLabel = ['природный', 'пятна', 'полосы'][pattern];

    return Semantics(
      label: '$label, $stageLabel, $earsLabel уши, узор $patternLabel, настроение $mood из 100',
      child: SizedBox(
        width: size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              padding: EdgeInsets.all(size * .025),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(colors: [
                  AppColors.surface,
                  accent.withValues(alpha: .16),
                ]),
                border: Border.all(color: accent.withValues(alpha: .45)),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FittedBox(
                    fit: BoxFit.contain,
                    child: FinniCharacter(
                      size: 250,
                      colorIndex: color,
                      earsIndex: ears,
                      patternIndex: pattern,
                      developmentStage: stage,
                      mood: mood,
                      animate: animate,
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Semantics(
                      label: 'Выражение Финни, настроение $mood из 100',
                      child: ClipOval(
                        child: Image.asset(
                          FinniCharacter.moodAsset(mood, color),
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          cacheWidth: 108,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              '$stageLabel · $earsLabel · $patternLabel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
