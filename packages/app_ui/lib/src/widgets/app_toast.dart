import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../app_ui.dart';

/// The semantic flavor of a toast, which selects its color + default icon.
enum AppToastVariant { neutral, success, warning, error, info }

/// A single, theme-consistent entry point for transient snackbar messages.
///
/// Replaces scattered `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))`
/// calls (each with its own ad-hoc styling) with a small facade that applies
/// the semantic colors, an optional leading icon, and a consistent duration.
/// The snackbar shape/elevation still come from the central `snackBarTheme`.
///
/// ```dart
/// AppToast.success(context, l10n.bookmarkSaved);
/// AppToast.error(context, l10n.genericError, actionLabel: l10n.retry,
///     onAction: controller.retry);
/// ```
class AppToast {
  const AppToast._();

  /// Shows [message] with the styling for [variant]. Any in-flight snackbar is
  /// dismissed first so messages don't queue up behind each other.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context,
    String message, {
    AppToastVariant variant = AppToastVariant.neutral,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    FaIconData? icon,
  }) {
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    final colors = _colorsFor(context, variant);
    final resolvedIcon = icon ?? _defaultIcon(variant);

    return messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (resolvedIcon != null) ...[
              FaIcon(resolvedIcon, size: AppIconSize.sm, color: colors.onColor),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.onColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.background,
        duration: duration,
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(
                label: actionLabel,
                textColor: colors.onColor,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// A positive/confirmation toast.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) => show(
    context,
    message,
    variant: AppToastVariant.success,
    duration: duration,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  /// A cautionary toast.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) => show(
    context,
    message,
    variant: AppToastVariant.warning,
    duration: duration,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  /// An error/failure toast.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
    String? actionLabel,
    VoidCallback? onAction,
  }) => show(
    context,
    message,
    variant: AppToastVariant.error,
    duration: duration,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  /// An informational toast.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) => show(
    context,
    message,
    variant: AppToastVariant.info,
    duration: duration,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static _ToastColors _colorsFor(BuildContext context, AppToastVariant v) {
    final semantic = context.semanticColors;
    return switch (v) {
      AppToastVariant.neutral => const _ToastColors(null, null),
      AppToastVariant.success => _ToastColors(
        semantic.success,
        semantic.onSuccess,
      ),
      AppToastVariant.warning => _ToastColors(
        semantic.warning,
        semantic.onWarning,
      ),
      AppToastVariant.info => _ToastColors(semantic.info, semantic.onInfo),
      AppToastVariant.error => _ToastColors(
        context.colorScheme.error,
        context.colorScheme.onError,
      ),
    };
  }

  static FaIconData? _defaultIcon(AppToastVariant v) => switch (v) {
    AppToastVariant.neutral => null,
    AppToastVariant.success => FontAwesomeIcons.circleCheck,
    AppToastVariant.warning => FontAwesomeIcons.triangleExclamation,
    AppToastVariant.error => FontAwesomeIcons.circleExclamation,
    AppToastVariant.info => FontAwesomeIcons.circleInfo,
  };
}

/// Resolved background / foreground pair for a toast. A `null` background falls
/// back to the theme's default snackbar color; a `null` foreground lets the
/// default content color apply.
class _ToastColors {
  const _ToastColors(this.background, this.onColor);

  final Color? background;
  final Color? onColor;
}
