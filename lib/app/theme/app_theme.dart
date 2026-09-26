import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';

abstract final class AppTheme {
  static ThemeData light({
    bool soundEnabled = true,
    bool animationsEnabled = true,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      brightness: Brightness.light,
    );

    final feedbackStyle = ButtonStyle(enableFeedback: soundEnabled);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme.copyWith(
        primary: AppColors.purple,
        secondary: AppColors.blue,
        surface: AppColors.surface,
      ),
      dividerColor: AppColors.divider,
      pageTransitionsTheme: animationsEnabled
          ? const PageTransitionsTheme()
          : const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: _NoPageTransitionsBuilder(),
                TargetPlatform.fuchsia: _NoPageTransitionsBuilder(),
                TargetPlatform.iOS: _NoPageTransitionsBuilder(),
                TargetPlatform.linux: _NoPageTransitionsBuilder(),
                TargetPlatform.macOS: _NoPageTransitionsBuilder(),
                TargetPlatform.windows: _NoPageTransitionsBuilder(),
              },
            ),
      filledButtonTheme: FilledButtonThemeData(style: feedbackStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: feedbackStyle),
      textButtonTheme: TextButtonThemeData(style: feedbackStyle),
      iconButtonTheme: IconButtonThemeData(style: feedbackStyle),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          height: 1.15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          height: 1.4,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          height: 1.4,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(
            color: AppColors.purple,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _NoPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
