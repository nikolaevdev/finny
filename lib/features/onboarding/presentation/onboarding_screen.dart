import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_button.dart';
import '../../../core/widgets/finni_card.dart';
import '../../../core/widgets/finni_character.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSpacing.xl * 2,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(),
                      Text(
                        'Привет! Это Финни',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Помогай Финни решать, что нужно, чего хочется '
                        'и на что стоит копить.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FinniCharacter(
                        size: constraints.maxHeight < 620 ? 195 : 250,
                        semanticLabel: 'Финни, бирюзовый малыш',
                        animate: true,
                        tapReaction: true,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const _DecisionCards(),
                      const Spacer(),
                      const SizedBox(height: AppSpacing.xl),
                      FinniButton(
                        text: 'Начать',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => context.push(AppRoutes.profile),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DecisionCards extends StatelessWidget {
  const _DecisionCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _DecisionCard(
            title: 'Нужно',
            icon: Icons.home_work_rounded,
            color: AppColors.need,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _DecisionCard(
            title: 'Хочу',
            icon: Icons.favorite_rounded,
            color: AppColors.want,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _DecisionCard(
            title: 'Коплю',
            icon: Icons.savings_rounded,
            color: AppColors.save,
          ),
        ),
      ],
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
