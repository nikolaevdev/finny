import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';
import 'finni_motion_theme.dart';

abstract final class AppTheme {
  static ThemeData light({
    bool soundEnabled = true,
    bool animationsEnabled = true,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      brightness: Brightness.light,
      surface: AppColors.surface,
    ).copyWith(
      primary: AppColors.purple,
      onPrimary: AppColors.textOnAccent,
      primaryContainer: AppColors.purpleSoft,
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.blue,
      onSecondary: AppColors.textOnAccent,
      secondaryContainer: AppColors.blueSoft,
      onSecondaryContainer: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.textOnAccent,
      errorContainer: AppColors.errorSoft,
      onErrorContainer: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      outline: AppColors.outlineStrong,
      outlineVariant: AppColors.divider,
    );

    final filledButtonStyle = FilledButton.styleFrom(
      backgroundColor: AppColors.purple,
      foregroundColor: AppColors.textOnAccent,
      disabledBackgroundColor: AppColors.disabledSurface,
      disabledForegroundColor: AppColors.textSecondary,
      minimumSize: const Size(48, 56),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      elevation: 3,
      shadowColor: AppColors.purpleDark.withValues(alpha: 0.30),
      textStyle: AppTypography.textTheme.labelLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
    ).copyWith(
      enableFeedback: soundEnabled,
      elevation: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return 0;
        if (states.contains(WidgetState.pressed)) return 0.5;
        if (states.contains(WidgetState.hovered)) return 5;
        return 3;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.white.withValues(alpha: 0.16);
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.white.withValues(alpha: 0.08);
        }
        return null;
      }),
    );

    final outlinedButtonStyle = OutlinedButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      disabledForegroundColor: AppColors.disabled,
      minimumSize: const Size(48, 56),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: AppTypography.textTheme.labelLarge,
      side: const BorderSide(color: AppColors.outlineStrong),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
    ).copyWith(
      enableFeedback: soundEnabled,
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return AppColors.purpleSoft.withValues(alpha: 0.72);
        }
        if (states.contains(WidgetState.hovered)) {
          return AppColors.purpleSoft.withValues(alpha: 0.36);
        }
        return null;
      }),
    );

    final textButtonStyle = TextButton.styleFrom(
      foregroundColor: AppColors.purpleDark,
      disabledForegroundColor: AppColors.disabled,
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: AppTypography.textTheme.labelLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
    ).copyWith(
      enableFeedback: soundEnabled,
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return AppColors.purpleSoft.withValues(alpha: 0.66);
        }
        if (states.contains(WidgetState.hovered)) {
          return AppColors.purpleSoft.withValues(alpha: 0.30);
        }
        return null;
      }),
    );

    return ThemeData(
      useMaterial3: true,
      splashFactory: InkSparkle.splashFactory,
      extensions: [FinniMotionTheme(enabled: animationsEnabled)],
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: colorScheme,
      dividerColor: AppColors.divider,
      textTheme: AppTypography.textTheme,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
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
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background.withValues(alpha: 0.94),
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        titleTextStyle: TextStyle(
          fontSize: 20,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: filledButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonStyle),
      textButtonTheme: TextButtonThemeData(style: textButtonStyle),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.disabled,
          minimumSize: const Size.square(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ).copyWith(
          enableFeedback: soundEnabled,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.purple.withValues(alpha: 0.16);
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.purple.withValues(alpha: 0.08);
            }
            return null;
          }),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.disabledSurface),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.purpleSoft,
        disabledColor: AppColors.disabledSurface,
        labelStyle: AppTypography.textTheme.labelMedium!,
        secondaryLabelStyle: AppTypography.textTheme.labelMedium!.copyWith(
          color: AppColors.purpleDark,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        showCheckmark: false,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.purple,
        linearTrackColor: AppColors.surfaceSecondary,
        linearMinHeight: 10,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        actionTextColor: AppColors.gold,
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textOnAccent,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        titleTextStyle: AppTypography.textTheme.titleLarge,
        contentTextStyle: AppTypography.textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.large),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.purpleDark,
        textColor: AppColors.textPrimary,
        titleTextStyle: AppTypography.textTheme.bodyLarge,
        subtitleTextStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        textStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.textOnAccent,
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
