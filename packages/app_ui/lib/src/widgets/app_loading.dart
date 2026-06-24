import 'package:flutter/material.dart';

import '../../app_ui.dart';

/// Centered circular progress indicator with consistent sizing.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.size = 32, this.label});

  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            // Announce progress to screen readers; an unlabelled spinner is
            // silent to assistive tech.
            child: CircularProgressIndicator(
              strokeWidth: 3,
              semanticsLabel: label ?? 'Loading',
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(label!, style: context.textTheme.bodyMedium),
          ],
        ],
      ),
    ).animateFadeIn(duration: AppDurations.fast);
  }
}
