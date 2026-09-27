import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

class FinniProgressBar extends StatelessWidget {
  const FinniProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.purple,
    this.backgroundColor = AppColors.surfaceSecondary,
    this.height = 10,
    this.semanticLabel,
  });

  final double value;
  final Color color;
  final Color backgroundColor;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final normalizedValue = value.clamp(0.0, 1.0).toDouble();

    return Semantics(
      label: semanticLabel,
      value: '${(normalizedValue * 100).round()}%',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: LinearProgressIndicator(
          minHeight: height,
          value: normalizedValue,
          color: color,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}
