import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class FinniPreview extends StatelessWidget {
  const FinniPreview({
    super.key,
    this.size = 170,
    this.label = 'Финни',
    this.colorIndex = 0,
    this.earsIndex = 0,
    this.patternIndex = 0,
  });

  final double size;
  final String label;
  final int colorIndex;
  final int earsIndex;
  final int patternIndex;

  Color get _color => switch (colorIndex) {
        1 => AppColors.save,
        2 => AppColors.purple,
        _ => AppColors.need,
      };

  IconData get _earsIcon => switch (earsIndex) {
        1 => Icons.circle_outlined,
        2 => Icons.height_rounded,
        _ => Icons.change_history_rounded,
      };

  IconData get _patternIcon => switch (patternIndex) {
        1 => Icons.waves_rounded,
        2 => Icons.auto_awesome_rounded,
        _ => Icons.star_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Виртуальный питомец $label, вариант окраса ${colorIndex + 1}, '
          'ушей ${earsIndex + 1}, узора ${patternIndex + 1}',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _color.withValues(alpha: 0.22),
              AppColors.purple.withValues(alpha: 0.14),
            ],
          ),
          border: Border.all(
            color: _color.withValues(alpha: 0.35),
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.12,
              left: size * 0.17,
              child: _VariantBadge(
                icon: _earsIcon,
                color: _color,
                size: size * 0.17,
              ),
            ),
            Positioned(
              top: size * 0.12,
              right: size * 0.17,
              child: _VariantBadge(
                icon: _patternIcon,
                color: _color,
                size: size * 0.17,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets_rounded,
                  size: size * 0.38,
                  color: _color,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantBadge extends StatelessWidget {
  const _VariantBadge({
    required this.icon,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.88),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: size * 0.62,
        color: color,
      ),
    );
  }
}
