import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand.
  static const purple = Color(0xFF7047F4);
  static const purpleDark = Color(0xFF4D32B8);
  static const purpleSoft = Color(0xFFEAE3FF);

  // Financial categories. These colors stay stable across the app.
  static const need = Color(0xFF28C9A5);
  static const needSoft = Color(0xFFDDF8F1);
  static const want = Color(0xFF7B4FF3);
  static const wantSoft = Color(0xFFECE5FF);
  static const save = Color(0xFFF6A12E);
  static const saveSoft = Color(0xFFFFE9C6);

  // Additional accents.
  static const blue = Color(0xFF3699F2);
  static const blueSoft = Color(0xFFDDEEFF);
  static const gold = Color(0xFFFFBD35);
  static const success = Color(0xFF2DBE88);
  static const successSoft = Color(0xFFE1F5EC);
  static const warning = Color(0xFFEA8A27);
  static const warningSoft = Color(0xFFFFEEDC);
  static const error = Color(0xFFE25A66);
  static const errorSoft = Color(0xFFFFE7E8);

  // Surfaces.
  static const background = Color(0xFFF5F1E8);
  static const surface = Color(0xFFFFFDFC);
  static const surfaceSecondary = Color(0xFFF4F1F7);
  static const surfaceMuted = Color(0xFFEDE9F0);

  // Text.
  static const textPrimary = Color(0xFF241D45);
  static const textSecondary = Color(0xFF4F4964);
  static const textOnAccent = Colors.white;

  // Borders and states.
  static const divider = Color(0xFFE7E1EB);
  static const outlineStrong = Color(0xFFCFC8D8);
  static const disabled = Color(0xFFB9B5C4);
  static const disabledSurface = Color(0xFFE5E1E8);
}
