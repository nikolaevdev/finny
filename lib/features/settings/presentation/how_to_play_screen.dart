import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_card.dart';
import '../../../core/widgets/adventure_banner.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Как играть'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: const [
          AdventureBanner(
            title: 'Карта путешествия',
            icon: Icons.map_rounded,
            imageAsset: 'assets/images/navigation/task_map_banner.png',
          ),
          SizedBox(height: AppSpacing.md),
          _GuideStep(
            number: 1,
            title: 'Получи монеты',
            text: 'В начале игрового периода Финни получает понятный игровой доход.',
            icon: Icons.monetization_on_rounded,
          ),
          SizedBox(height: AppSpacing.md),
          _GuideStep(
            number: 2,
            title: 'Составь план',
            text: 'Распредели монеты между нужными расходами, желаниями и накоплениями.',
            icon: Icons.fact_check_outlined,
          ),
          SizedBox(height: AppSpacing.md),
          _GuideStep(
            number: 3,
            title: 'Принимай решения',
            text: 'Покупай нужное, выбирай желания и регулярно откладывай на финансовую цель.',
            icon: Icons.route_rounded,
          ),
          SizedBox(height: AppSpacing.md),
          _GuideStep(
            number: 4,
            title: 'Сравни план с фактом',
            text: 'В конце периода посмотри, что получилось, и используй выводы в следующем периоде.',
            icon: Icons.bar_chart_rounded,
          ),
          SizedBox(height: AppSpacing.lg),
          FinniCard(
            color: AppColors.surfaceSecondary,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.pets_rounded, color: AppColors.purple),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Ошибку всегда можно исправить следующим решением. Финни не наказывает за неудачный выбор.',
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

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.number,
    required this.title,
    required this.text,
    required this.icon,
  });

  final int number;
  final String title;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceSecondary,
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.purple,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.purple, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
