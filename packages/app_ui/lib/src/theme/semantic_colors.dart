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
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
  });

  /// Tokens tuned for light themes.
  ///
  /// These map onto the closed palette rather than introducing hues of their
  /// own (design-dna-app.md §1):
  ///  - **success** is `--primary`. There is deliberately no second green —
  ///    a success state is the primary fill plus a check icon; adding another
  ///    green next to the brand green only muddies both.
  ///  - **warning** is `--warning`, which itself reuses `--chart-4`. It is the
  ///    single sanctioned extension to the shadcn token set.
  ///  - **info** is `--secondary` (grey). `--chart-5` blue is for charts only.
  static const light = SemanticColors(
    success: Color(0xFF16522C),
    onSuccess: Color(0xFFFCFCFC),
    warning: Color(0xFFB6770B),
    onWarning: Color(0xFFFFFFFF),
    info: Color(0xFFF3F3F3),
    onInfo: Color(0xFF222222),
  );

  /// Tokens tuned for dark themes (design-dna-app.md §1, dark column).
  static const dark = SemanticColors(
    success: Color(0xFF53BE70),
    onSuccess: Color(0xFF0F0F0F),
    warning: Color(0xFFD99A1F),
    onWarning: Color(0xFF0F0F0F),
    info: Color(0xFF262626),
    onInfo: Color(0xFFF2F2F2),
  );

  /// Indicates a successful or positive state.
  final Color success;

  /// Content color drawn on top of [success].
  final Color onSuccess;

  /// Indicates a cautionary state needing attention.
  final Color warning;

  /// Content color drawn on top of [warning].
  final Color onWarning;

  /// Indicates a neutral, informational state.
  final Color info;

  /// Content color drawn on top of [info].
  final Color onInfo;

  @override
  SemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
  }) {
    return SemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
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
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
    );
  }
}
