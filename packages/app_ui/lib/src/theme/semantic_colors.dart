import 'package:flutter/material.dart';

/// Semantic status colors that aren't part of Material's [ColorScheme].
///
/// Material 3 covers brand and error roles, but leaves success / warning / info
/// up to the app. Register this extension on [ThemeData] so those roles are
/// theme-aware (and animate across light/dark) instead of being hardcoded at
/// call sites. Access via `Theme.of(context).extension<SemanticColors>()` or
/// the `context.semanticColors` getter.
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.info,
    required this.onInfo,
  });

  /// Tokens mirroring the .pen design variables (`text-success`,
  /// `state-success`, `state-warning`, `text-link`).
  static const light = SemanticColors(
    success: Color(0xFF2F7A55),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFE7F4EA),
    warning: Color(0xFF8A6D3B),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFFF3D5),
    info: Color(0xFF3399F3),
    onInfo: Color(0xFFFFFFFF),
  );

  /// Tokens tuned for dark themes.
  static const dark = SemanticColors(
    success: Color(0xFF7ED9A9),
    onSuccess: Color(0xFF0F2A1C),
    successContainer: Color(0xFF2C3B31),
    warning: Color(0xFFD9BC8A),
    onWarning: Color(0xFF2E2410),
    warningContainer: Color(0xFF3F382A),
    info: Color(0xFF7AB8FF),
    onInfo: Color(0xFF0A2A4A),
  );

  /// Indicates a successful or positive state.
  final Color success;

  /// Content color drawn on top of [success].
  final Color onSuccess;

  /// Tinted background for success pills/banners; pair with [success] text.
  final Color successContainer;

  /// Indicates a cautionary state needing attention.
  final Color warning;

  /// Content color drawn on top of [warning].
  final Color onWarning;

  /// Tinted background for warning banners; pair with [warning] text.
  final Color warningContainer;

  /// Indicates a neutral, informational state.
  final Color info;

  /// Content color drawn on top of [info].
  final Color onInfo;

  @override
  SemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? info,
    Color? onInfo,
  }) {
    return SemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
    );
  }
}
