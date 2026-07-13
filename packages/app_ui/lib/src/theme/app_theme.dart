import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_elevation.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'brand_colors.dart';
import 'semantic_colors.dart';
import 'stampmail_colors.dart';

/// Shared component theming applied to both [AppTheme.light] and
/// [AppTheme.dark].
///
/// Centralizing this as one [FlexSubThemesData] keeps the two brightness
/// variants visually consistent and lets every Material widget (cards,
/// inputs, buttons, dialogs, navigation, ...) pick up polished defaults from
/// the design tokens (`AppRadius`, `AppElevation`) instead of each feature
/// styling them inline.
const _componentThemes = FlexSubThemesData(
  // Cards: rounded and gently lifted, matching the "lifted" look used
  // elsewhere (e.g. `AppScaffold`'s loading overlay, `AppElevation.cardShadow`).
  cardRadius: AppRadius.lg,
  cardElevation: AppElevation.sm,

  // Inputs: filled, borderless until focused — converging with the look
  // hand-built in `AppTextField` so both paths look the same.
  inputDecoratorRadius: AppRadius.lg,
  inputDecoratorIsFilled: true,
  inputDecoratorBorderType: FlexInputBorderType.outline,
  inputDecoratorUnfocusedBorderIsColored: false,
  inputDecoratorFocusedBorderWidth: 1.5,

  // Buttons / FAB / chips: the .pen components use radius-16 for the primary
  // CTA (Button/Primary, h52) and radius-12 for the outlined secondary
  // (Button/Secondary, h44); `AppButton._style()` mirrors the same scale.
  filledButtonRadius: AppRadius.lg,
  elevatedButtonRadius: AppRadius.lg,
  elevatedButtonElevation: AppElevation.md - 1,
  outlinedButtonRadius: AppRadius.md,
  textButtonRadius: AppRadius.md,
  fabRadius: AppRadius.lg,
  chipRadius: AppRadius.sm,

  // Dialogs / bottom sheets: rounded, with a drag handle on sheets.
  dialogRadius: AppRadius.xl,
  bottomSheetRadius: AppRadius.xl,

  // Navigation, snackbars, list tiles, dividers: rounded indicator, floating
  // snackbar with matching radius, and a subtle hairline divider.
  navigationBarIndicatorRadius: AppRadius.lg,
  snackBarRadius: AppRadius.sm,
  snackBarElevation: AppElevation.md,
  useM2StyleDividerInM3: false,

  // AppBar: flat, doesn't pick up extra elevation/tint when content scrolls
  // beneath it.
  appBarScrolledUnderElevation: AppElevation.none,
);

/// The app's centralized theme.
///
/// Built on `flex_color_scheme` so light and dark variants share a single
/// seed [FlexScheme] and component theming (see [_componentThemes]),
/// guaranteeing that visual polish propagates to every feature automatically.
class AppTheme {
  const AppTheme._();

  /// The light theme variant.
  ///
  /// The [scheme] parameter is retained for `ThemeBloc` API compatibility but
  /// no longer selects the palette: StampMail ships a hand-authored coral/cream
  /// [ColorScheme] (see `StampMailColors`) rather than a seeded `FlexScheme`.
  static ThemeData light({FlexScheme scheme = FlexScheme.blue}) {
    return FlexThemeData.light(
      colorScheme: StampMailColors.light,
      textTheme: _textTheme(StampMailColors.light),
      useMaterial3: true,
      subThemesData: _componentThemes,
      appBarElevation: AppElevation.none,
      appBarStyle: FlexAppBarStyle.surface,
    ).copyWith(
      extensions: const [SemanticColors.light, BrandColors.light],
      bottomSheetTheme: const BottomSheetThemeData(showDragHandle: true),
      inputDecorationTheme: _inputDecorationTheme(
        StampMailColors.light,
        BrandColors.light,
      ),
    );
  }

  /// The dark theme variant.
  static ThemeData dark({FlexScheme scheme = FlexScheme.blue}) {
    return FlexThemeData.dark(
      colorScheme: StampMailColors.dark,
      textTheme: _textTheme(StampMailColors.dark),
      useMaterial3: true,
      subThemesData: _componentThemes,
      appBarElevation: AppElevation.none,
      appBarStyle: FlexAppBarStyle.surface,
    ).copyWith(
      extensions: const [SemanticColors.dark, BrandColors.dark],
      bottomSheetTheme: const BottomSheetThemeData(showDragHandle: true),
      inputDecorationTheme: _inputDecorationTheme(
        StampMailColors.dark,
        BrandColors.dark,
      ),
    );
  }

  /// Text-field chrome matching the .pen `Input/*` components exactly:
  /// `surface-elevated` fill, hairline `border-subtle`, radius-16, 56px tall
  /// (17px text + 16px vertical padding), coral 1.5 focus and error borders.
  static InputDecorationTheme _inputDecorationTheme(
    ColorScheme scheme,
    BrandColors brand,
  ) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecorationTheme(
      filled: true,
      fillColor: brand.surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      hintStyle: TextStyle(color: scheme.outline),
      prefixIconColor: scheme.onSurfaceVariant,
      suffixIconColor: scheme.onSurfaceVariant,
      border: border(brand.borderSubtle),
      enabledBorder: border(brand.borderSubtle),
      focusedBorder: border(scheme.primary, width: 1.5),
      errorBorder: border(scheme.error, width: 1.5),
      focusedErrorBorder: border(scheme.error, width: 1.5),
      disabledBorder: border(brand.borderSubtle),
    );
  }

  /// StampMail typography: Baloo 2 (rounded) for large display/headline text,
  /// Be Vietnam Pro for titles, body, and labels — the latter reads cleanly
  /// with Vietnamese diacritics. Sizes follow the design's type scale.
  static TextTheme _textTheme(ColorScheme scheme) {
    final display = GoogleFonts.baloo2(color: scheme.onSurface);
    final body = GoogleFonts.beVietnamPro(color: scheme.onSurface);
    return TextTheme(
      displayLarge: display.copyWith(
        fontSize: 34,
        height: 41 / 34,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: display.copyWith(
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: display.copyWith(
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: display.copyWith(
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: display.copyWith(
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: display.copyWith(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: body.copyWith(
        fontSize: 20,
        height: 25 / 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: body.copyWith(
        fontSize: 17,
        height: 22 / 17,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: body.copyWith(
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: body.copyWith(fontSize: 17, height: 24 / 17),
      bodyMedium: body.copyWith(fontSize: 15, height: 22 / 15),
      bodySmall: body.copyWith(
        fontSize: 13,
        height: 18 / 13,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: body.copyWith(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: body.copyWith(
        fontSize: 13,
        height: 16 / 13,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: body.copyWith(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

extension BuildContextTheme on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  SemanticColors get semanticColors =>
      theme.extension<SemanticColors>() ?? SemanticColors.light;

  /// StampMail brand tokens (soft surfaces + accent hues) for the active theme.
  BrandColors get brand =>
      theme.extension<BrandColors>() ?? BrandColors.light;
  Brightness get brightness => theme.brightness;
  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;
}
