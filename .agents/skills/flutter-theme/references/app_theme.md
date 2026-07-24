# AppTheme

Assembles `ThemeData` from the tokens above. This is the only file that builds `ThemeData`.

## Key helper — `_t()`

```dart
// Wraps an AppTypography style for use in theme properties (not textTheme).
// Sets inherit: false so it matches Material's resolved style format and
// avoids TextStyleTween lerp warnings during widget state transitions.
// textBaseline must be explicit when inherit: false — Flutter's InputDecorator
// calls labelStyle.textBaseline! and crashes if it is null.
TextStyle _t(TextStyle base, Color color) => base.copyWith(
      inherit: false,
      color: color,
      textBaseline: TextBaseline.alphabetic,
    );
```

Why `_t()` is required for all non-textTheme styles:
1. **`TextStyleTween.lerp` warning** — when `AnimatedDefaultTextStyle` transitions lerp styles with mismatched `inherit` values (e.g. buttons on hover/press).
2. **`Null check operator` in `_InputDecoratorState.build`** — Flutter calls `labelStyle.textBaseline!`; with `inherit: false` nothing is inherited so it must be set explicitly.
3. **Invisible text on dark backgrounds** — `foregroundColor` does NOT override `titleTextStyle.color`.

## `lib/src/app/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

TextStyle _t(TextStyle base, Color color) => base.copyWith(
      inherit: false,
      color: color,
      textBaseline: TextBaseline.alphabetic,
    );

abstract final class AppTheme {
  // ── Light ──
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.lightScheme,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: AppTypography.textTheme.apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        dividerColor: AppColors.divider,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: _t(AppTypography.headlineSmall, AppColors.textPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.disabled,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            textStyle: _t(AppTypography.labelLarge, AppColors.textOnPrimary),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            side: const BorderSide(color: AppColors.primary),
            textStyle: _t(AppTypography.labelLarge, AppColors.primary),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: _t(AppTypography.labelLarge, AppColors.primary),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: _t(AppTypography.bodyMedium, AppColors.textSecondary),
          hintStyle: _t(AppTypography.bodyMedium, AppColors.textSecondary),
          errorStyle: _t(AppTypography.bodySmall, AppColors.error),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: _t(AppTypography.labelSmall, AppColors.primary),
          unselectedLabelStyle: _t(AppTypography.labelSmall, AppColors.textSecondary),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.background,
          selectedColor: AppColors.primary.withValues(alpha: 0.12),
          labelStyle: _t(AppTypography.labelLarge, AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          side: const BorderSide(color: AppColors.divider),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textPrimary,
          contentTextStyle: _t(AppTypography.bodyMedium, AppColors.textOnPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          titleTextStyle: _t(AppTypography.headlineMedium, AppColors.textPrimary),
          contentTextStyle: _t(AppTypography.bodyMedium, AppColors.textPrimary),
        ),
      );

  // ── Dark ──
  // IMPORTANT: define the same component themes as light — omitting a theme
  // causes Flutter to lerp between your inherit:false style and Material's
  // inherit:true default, which triggers TextStyleTween lerp warnings.
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.darkScheme,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        textTheme: AppTypography.textTheme.apply(
          bodyColor: AppColors.textPrimaryDark,
          displayColor: AppColors.textPrimaryDark,
        ),
        dividerColor: AppColors.divider,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: _t(AppTypography.headlineSmall, AppColors.textPrimaryDark),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceDark,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.disabled,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            textStyle: _t(AppTypography.labelLarge, AppColors.textOnPrimary),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            side: const BorderSide(color: AppColors.primary),
            textStyle: _t(AppTypography.labelLarge, AppColors.primary),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: _t(AppTypography.labelLarge, AppColors.primary),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceDark,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: _t(AppTypography.bodyMedium, AppColors.textSecondaryDark),
          hintStyle: _t(AppTypography.bodyMedium, AppColors.textSecondaryDark),
          errorStyle: _t(AppTypography.bodySmall, AppColors.error),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondaryDark,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: _t(AppTypography.labelSmall, AppColors.primary),
          unselectedLabelStyle: _t(AppTypography.labelSmall, AppColors.textSecondaryDark),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.backgroundDark,
          selectedColor: AppColors.primary.withValues(alpha: 0.12),
          labelStyle: _t(AppTypography.labelLarge, AppColors.textPrimaryDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          side: const BorderSide(color: AppColors.divider),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textPrimaryDark,
          contentTextStyle: _t(AppTypography.bodyMedium, AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          titleTextStyle: _t(AppTypography.headlineMedium, AppColors.textPrimaryDark),
          contentTextStyle: _t(AppTypography.bodyMedium, AppColors.textPrimaryDark),
        ),
      );
}
```
