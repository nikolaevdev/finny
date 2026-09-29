import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../audio/finni_audio.dart';
import 'finni_pressable.dart';

enum FinniButtonVariant {
  primary,
  secondary,
  quiet,
}

class FinniButton extends StatelessWidget {
  const FinniButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.variant = FinniButtonVariant.primary,
    this.expand = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final FinniButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final handlePressed = onPressed == null
        ? null
        : () {
            FinniAudio.instance.play(AudioCue.tap);
            onPressed!();
          };
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 22),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    final button = switch (variant) {
      FinniButtonVariant.primary => FilledButton(
          onPressed: handlePressed,
          child: content,
        ),
      FinniButtonVariant.secondary => OutlinedButton(
          onPressed: handlePressed,
          child: content,
        ),
      FinniButtonVariant.quiet => TextButton(
          onPressed: handlePressed,
          child: content,
        ),
    };

    final sizedButton = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: expand
          ? SizedBox(
              width: double.infinity,
              child: button,
            )
          : button,
    );

    return FinniPressable(
      enabled: onPressed != null,
      effect: variant == FinniButtonVariant.primary
          ? FinniPressEffect.reward
          : FinniPressEffect.button,
      glowColor: variant == FinniButtonVariant.primary
          ? Theme.of(context).colorScheme.primary
          : null,
      borderRadius: BorderRadius.circular(
        variant == FinniButtonVariant.quiet
            ? AppRadius.small
            : AppRadius.medium,
      ),
      child: sizedButton,
    );
  }
}
