import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

class FinniCard extends StatelessWidget {
  const FinniCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.large);

    // Shadow is kept outside Material. This is important because Material
    // descendants such as ListTile/SwitchListTile need a Material ancestor
    // directly above the painted background in order to render ink effects
    // correctly in debug and release modes.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: color,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? Padding(
                padding: padding,
                child: child,
              )
            : InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: Padding(
                  padding: padding,
                  child: child,
                ),
              ),
      ),
    );
  }
}
