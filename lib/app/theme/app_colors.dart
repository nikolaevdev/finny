import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand.
  static const purple = Color(0xFF7455E8);
  static const purpleDark = Color(0xFF5540B8);
  static const purpleSoft = Color(0xFFEDE8FF);

  // Financial categories. These colors stay stable across the app.
  static const need = Color(0xFF36BFA0);
  static const needSoft = Color(0xFFE2F6F1);
  static const want = Color(0xFF7858E8);
  static const wantSoft = Color(0xFFEDE8FF);
  static const save = Color(0xFFF1A33D);
  static const saveSoft = Color(0xFFFFF0D7);

  // Additional accents.
  static const blue = Color(0xFF4796EC);
  static const blueSoft = Color(0xFFE5F1FF);
  static const gold = Color(0xFFF5B93F);
  static const success = Color(0xFF36B886);
  static const successSoft = Color(0xFFE1F5EC);
  static const warning = Color(0xFFE18B2E);
  static const warningSoft = Color(0xFFFFEEDC);
  static const error = Color(0xFFD85C63);
  static const errorSoft = Color(0xFFFFE7E8);

  // Surfaces.
  static const background = Color(0xFFF5F1E8);
  static const surface = Color(0xFFFFFDFC);
  static const surfaceSecondary = Color(0xFFF4F1F7);
  static const surfaceMuted = Color(0xFFEDE9F0);

  // Text.
  static const textPrimary = Color(0xFF29224D);
  static const textSecondary = Color(0xFF777184);
  static const textOnAccent = Colors.white;

  // Borders and states.
  static const divider = Color(0xFFE7E1EB);
  static const outlineStrong = Color(0xFFCFC8D8);
  static const disabled = Color(0xFFB9B5C4);
  static const disabledSurface = Color(0xFFE5E1E8);
}
