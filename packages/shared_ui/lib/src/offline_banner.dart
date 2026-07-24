import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A compact "you are offline" notice shown above already-loaded content.
///
/// Behaviour:
/// - Renders nothing while online — a zero-size box, so it can be dropped
///   unconditionally into any layout.
/// - Sits *in* the layout flow rather than floating over it, so it never
///   obscures the content it annotates.
///
/// Data-in only: the host passes the already-localized [label] (this package
/// carries no localization dependency) and the [isOffline] flag it reads from
/// its own bloc/cubit.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    required this.isOffline,
    required this.label,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    super.key,
  });

  /// Whether the device is currently offline. When false nothing is rendered.
  final bool isOffline;

  /// The already-localized notice, e.g. "You're offline".
  final String label;

  /// Inner padding of the banner surface.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    final semantic = context.semanticColors;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: semantic.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.linkSlash,
              size: AppIconSize.sm,
              color: semantic.warning,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: semantic.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
