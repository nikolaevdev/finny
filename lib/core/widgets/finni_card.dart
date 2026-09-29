import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../audio/finni_audio.dart';
import 'finni_pressable.dart';

class FinniCard extends StatelessWidget {
  const FinniCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.onTap,
    this.borderColor,
    this.shadow = true,
    this.radius = AppRadius.large,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;
  final Color? borderColor;
  final bool shadow;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    // Shadow is kept outside Material. Material descendants such as ListTile
    // and SwitchListTile need a Material ancestor directly above the painted
    // surface so ink effects render correctly in debug and release modes.
    final card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
        boxShadow: shadow ? AppShadows.card : const <BoxShadow>[],
      ),
      child: Material(
        color: color.withValues(alpha: 0.96),
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? Padding(
                padding: padding,
                child: child,
              )
            : InkWell(
                borderRadius: borderRadius,
                onTap: () {
                  FinniAudio.instance.play(AudioCue.tap);
                  onTap!();
                },
                child: Padding(
                  padding: padding,
                  child: child,
                ),
              ),
      ),
    );

    if (onTap == null) return card;

    return FinniPressable(
      effect: FinniPressEffect.card,
      borderRadius: borderRadius,
      glowColor: borderColor,
      child: card,
    );
  }
}
