import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_contracts/shared_contracts.dart';

/// The remaining-quota threshold below which the low-quota nudge is shown.
///
/// Mirrors SM-030 BR-02: warn when a Free user has under 20% of a monthly
/// allowance left, i.e. fewer than 6 stamps (of 30) or fewer than 2 letters
/// (of 10) remaining.
const int kLowStampThreshold = 6;
const int kLowLetterThreshold = 2;

/// Copy for [QuotaNudgeBanner], supplied by the caller so this widget stays
/// free of any localization dependency (callers pass already-localized text).
///
/// The count-bearing strings are functions of the remaining number so the host
/// can pluralize/format them per its locale — e.g. `letterRemaining(1)` →
/// "Còn 1 thư trong tháng này" (SM-030 AC-01).
@immutable
class QuotaNudgeLabels {
  const QuotaNudgeLabels({
    required this.stampRemaining,
    required this.letterRemaining,
    required this.offlineMessage,
    this.lastSyncedLabel,
    this.upgradeCta,
  });

  /// e.g. "Còn 5 tem trong tháng này".
  final String Function(int remaining) stampRemaining;

  /// e.g. "Còn 1 thư trong tháng này".
  final String Function(int remaining) letterRemaining;

  /// Shown while [QuotaNudgeBanner.isOffline] — SM-030 BR-07 / AC-07 copy:
  /// "Không có kết nối. Vui lòng thử lại khi có mạng."
  final String offlineMessage;

  /// Optional "Đồng bộ lần cuối …" caption shown offline (SM-030 BR-06).
  final String? lastSyncedLabel;

  /// Optional upgrade-to-Premium action label (SM-030 BR-03 nudge). When null,
  /// no CTA is rendered.
  final String? upgradeCta;
}

/// A compact warning banner that nudges a Free user when their monthly stamp or
/// letter quota is nearly exhausted (SM-030).
///
/// Behaviour:
/// - Renders nothing for unlimited/Premium quota (AC-05) — returns a zero-size
///   box so it can be dropped unconditionally into any layout.
/// - Renders nothing while there is still headroom on both resources; it only
///   appears once a resource crosses under 20% of its allowance (BR-02).
/// - While offline it still shows the last-synced remaining counts (BR-06 /
///   AC-06) plus the "no connection" note (BR-07 / AC-07); it never blanks out.
///
/// The widget is data-in, callback-out: it takes the already-read
/// [QuotaRemaining] and the offline flag as parameters and surfaces the upgrade
/// tap via [onUpgrade]. Wiring a `QuotaReader` to feed it is the host's job.
class QuotaNudgeBanner extends StatelessWidget {
  const QuotaNudgeBanner({
    required this.quota,
    required this.labels,
    this.isOffline = false,
    this.onUpgrade,
    super.key,
  });

  /// The remaining monthly quota, as last read (from the server or cache).
  final QuotaRemaining quota;

  /// Localized copy for the banner.
  final QuotaNudgeLabels labels;

  /// Whether the device is currently offline. When true the banner still shows
  /// the cached counts and appends the offline note (SM-030 BR-06/BR-07).
  final bool isOffline;

  /// Invoked when the user taps the upgrade CTA. Ignored when
  /// [QuotaNudgeLabels.upgradeCta] is null.
  final VoidCallback? onUpgrade;

  /// Whether the stamp allowance has crossed under the low-quota threshold.
  bool get _stampLow =>
      !quota.isUnlimited && quota.stamps < kLowStampThreshold;

  /// Whether the letter allowance has crossed under the low-quota threshold.
  bool get _letterLow =>
      !quota.isUnlimited && quota.letters < kLowLetterThreshold;

  bool get _shouldShow => _stampLow || _letterLow;

  @override
  Widget build(BuildContext context) {
    // Premium/unlimited users never see a quota nudge (AC-05); and while both
    // resources have headroom there is nothing to warn about.
    if (quota.isUnlimited || !_shouldShow) {
      return const SizedBox.shrink();
    }

    final semantic = context.semanticColors;
    final textTheme = context.textTheme;

    final lines = <String>[
      if (_stampLow) labels.stampRemaining(quota.stamps),
      if (_letterLow) labels.letterRemaining(quota.letters),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: semantic.warningContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            FontAwesomeIcons.triangleExclamation,
            size: AppIconSize.md,
            color: semantic.warning,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final line in lines)
                  Text(
                    line,
                    style: textTheme.bodyMedium?.copyWith(
                      color: semantic.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (isOffline) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    labels.offlineMessage,
                    style: textTheme.bodySmall?.copyWith(
                      color: semantic.warning,
                    ),
                  ),
                  if (labels.lastSyncedLabel != null)
                    Text(
                      labels.lastSyncedLabel!,
                      style: textTheme.labelSmall?.copyWith(
                        color: semantic.warning.withValues(alpha: 0.8),
                      ),
                    ),
                ],
                if (labels.upgradeCta != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: onUpgrade,
                    child: Text(
                      labels.upgradeCta!,
                      style: textTheme.labelLarge?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
