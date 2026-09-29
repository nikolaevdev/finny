import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/finni_motion_theme.dart';

enum FinniPressEffect {
  button,
  card,
  icon,
  reward,
}

/// A lightweight game-like motion layer that does not own the tap callback.
///
/// It listens to pointer state while the wrapped Material/InkWell/Button keeps
/// its normal gesture handling, semantics, focus, splash and accessibility.
class FinniPressable extends StatefulWidget {
  const FinniPressable({
    super.key,
    required this.child,
    this.enabled = true,
    this.effect = FinniPressEffect.button,
    this.glowColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  final Widget child;
  final bool enabled;
  final FinniPressEffect effect;
  final Color? glowColor;
  final BorderRadius borderRadius;

  @override
  State<FinniPressable> createState() => _FinniPressableState();
}

class _FinniPressableState extends State<FinniPressable> {
  bool _pressed = false;
  bool _hovered = false;

  bool _motionEnabled(BuildContext context) {
    final appMotion =
        Theme.of(context).extension<FinniMotionTheme>()?.enabled ?? true;
    final media = MediaQuery.maybeOf(context);
    return widget.enabled && appMotion && !(media?.disableAnimations ?? false);
  }

  double get _pressedScale => switch (widget.effect) {
        FinniPressEffect.button => 0.965,
        FinniPressEffect.card => 0.978,
        FinniPressEffect.icon => 0.90,
        FinniPressEffect.reward => 0.955,
      };

  double get _hoverScale => switch (widget.effect) {
        FinniPressEffect.button => 1.012,
        FinniPressEffect.card => 1.008,
        FinniPressEffect.icon => 1.045,
        FinniPressEffect.reward => 1.018,
      };

  double get _pressedDy => switch (widget.effect) {
        FinniPressEffect.button => 2.0,
        FinniPressEffect.card => 1.5,
        FinniPressEffect.icon => 1.0,
        FinniPressEffect.reward => 2.5,
      };

  @override
  Widget build(BuildContext context) {
    final animate = _motionEnabled(context);
    final pressed = animate && _pressed;
    final hovered = animate && _hovered && !_pressed;
    final scale = pressed
        ? _pressedScale
        : hovered
            ? _hoverScale
            : 1.0;
    final dy = pressed
        ? _pressedDy
        : hovered
            ? -1.0
            : 0.0;

    final glowColor = widget.glowColor ?? AppColors.purple;
    final showGlow = hovered || (pressed && widget.effect == FinniPressEffect.reward);

    return MouseRegion(
      onEnter: widget.enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: widget.enabled
          ? (_) => setState(() {
                _hovered = false;
                _pressed = false;
              })
          : null,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
        onPointerUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
        onPointerCancel:
            widget.enabled ? (_) => setState(() => _pressed = false) : null,
        child: AnimatedContainer(
          duration: Duration(milliseconds: pressed ? 65 : 190),
          // BoxDecoration.lerp scales a disappearing BoxShadow by 1 - t.
          // An overshooting curve can make t > 1 and produce a negative blur.
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: showGlow
                ? [
                    BoxShadow(
                      color: glowColor.withValues(alpha: hovered ? 0.20 : 0.14),
                      blurRadius: hovered ? 18 : 12,
                      spreadRadius: hovered ? 1.0 : 0.0,
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: AnimatedScale(
            scale: scale,
            duration: Duration(milliseconds: pressed ? 65 : 210),
            curve: pressed ? Curves.easeOutCubic : Curves.easeOutBack,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: dy),
              duration: Duration(milliseconds: pressed ? 65 : 190),
              curve: pressed ? Curves.easeOutCubic : Curves.easeOutBack,
              builder: (context, value, child) =>
                  Transform.translate(offset: Offset(0, value), child: child),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
