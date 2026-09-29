import 'package:flutter/material.dart';

@immutable
class FinniMotionTheme extends ThemeExtension<FinniMotionTheme> {
  const FinniMotionTheme({required this.enabled});

  final bool enabled;

  @override
  FinniMotionTheme copyWith({bool? enabled}) {
    return FinniMotionTheme(enabled: enabled ?? this.enabled);
  }

  @override
  FinniMotionTheme lerp(ThemeExtension<FinniMotionTheme>? other, double t) {
    if (other is! FinniMotionTheme) return this;
    return t < 0.5 ? this : other;
  }
}
