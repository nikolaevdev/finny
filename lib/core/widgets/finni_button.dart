import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

enum FinniButtonVariant { primary, secondary, quiet }

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
        onPressed: onPressed,
        child: content,
      ),
      FinniButtonVariant.secondary => OutlinedButton(
        onPressed: onPressed,
        child: content,
      ),
      FinniButtonVariant.quiet => TextButton(
        onPressed: onPressed,
        child: content,
      ),
    };

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}
