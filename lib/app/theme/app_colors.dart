import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand.
  static const purple = Color(0xFF7455E8);
  static const purpleDark = Color(0xFF5540B8);

  // Financial categories. These colors stay stable across the app.
  static const need = Color(0xFF36BFA0);
  static const want = Color(0xFF7858E8);
  static const save = Color(0xFFF1A33D);

  // Additional accents.
  static const blue = Color(0xFF4796EC);
  static const gold = Color(0xFFF5B93F);
  static const success = Color(0xFF36B886);

  // Surfaces.
  static const background = Color(0xFFF5F1E8);
  static const surface = Color(0xFFFFFDFC);
  static const surfaceSecondary = Color(0xFFF4F1F7);

  // Text.
  static const textPrimary = Color(0xFF29224D);
  static const textSecondary = Color(0xFF777184);

  // Other.
  static const divider = Color(0xFFE7E1EB);
  static const disabled = Color(0xFFB9B5C4);
}
