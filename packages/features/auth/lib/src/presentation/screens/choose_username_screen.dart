import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localization/localization.dart';

import '../widgets/widgets.dart';

/// StampMail username-selection screen, shown after first authentication.
///
/// UI-only: the "already taken" error and suggestion chips are demo state. The
/// continue path will later reserve the username via `AuthBloc` /
/// `UsernameDataSource` (Firestore transaction — see the data-layer plan,
/// BR-04).
class ChooseUsernameScreen extends StatefulWidget {
  const ChooseUsernameScreen({this.onDone, super.key});

  /// Called with the accepted username (flow continues to avatar upload).
  final ValueChanged<String>? onDone;

  @override
  State<ChooseUsernameScreen> createState() => _ChooseUsernameScreenState();
}

class _ChooseUsernameScreenState extends State<ChooseUsernameScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _submitting = false;

  // ponytail: demo suggestions; real ones come from the backend.
  static const _suggestions = [
    'sunny.daily',
    'sunny.love',
    'hello.sunny',
    'sunny.corner',
    'day.by.sunny',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String value) {
    final v = value.trim();
    if (v.length < 3) return context.l10n.smUsernameTooShort;
    if (v.length > 30) return context.l10n.smUsernameTooLong;
    return null;
  }

  void _submit() {
    final error = _validate(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    // ponytail: reserved via the username API when it lands; accepted locally.
    setState(() {
      _error = null;
      _submitting = true;
    });
    widget.onDone?.call(_controller.text.trim());
  }

  void _pickSuggestion(String value) {
    _controller.text = value;
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      topGap: 40,
      topLeftAsset: 'verify-top-left-letter.png',
      topLeftWidth: 90,
      topRightAsset: 'user-top-right-leaves.png',
      topRightWidth: 86,
      bottomAsset: 'user-envelope.png',
      bottomWidth: 205,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthBrandHeader().animateSlideDown(),
          // .pen F01-S09 flow gaps: header→title 16, title→field 16.
          const SizedBox(height: AppSpacing.lg),
          AuthHeading(
            title: l10n.smUsernameTitle,
            subtitle: l10n.smUsernameSubtitle,
          ).animateSlideDown(delay: 50.ms),
          const SizedBox(height: AppSpacing.lg),
          AuthTextField(
            controller: _controller,
            label: l10n.smUsernameLabel,
            hint: l10n.smUsernameHint,
            icon: FontAwesomeIcons.at,
            enabled: !_submitting,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ).animateSlideLeft(delay: 100.ms),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text(
                _error!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _Suggestions(
            label: l10n.smUsernameSuggestions,
            suggestions: _suggestions,
            onPick: _submitting ? null : _pickSuggestion,
          ).animateSlideLeft(delay: 150.ms),
          const SizedBox(height: AppSpacing.xxxl),
          AuthPrimaryButton(
            label: l10n.smUsernameContinue,
            onPressed: _submit,
            isLoading: _submitting,
          ).animateSlideUp(delay: 250.ms),
        ],
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({
    required this.label,
    required this.suggestions,
    required this.onPick,
  });

  final String label;
  final List<String> suggestions;
  final ValueChanged<String>? onPick;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    // .pen suggestBlock: 12px between the label and the chip rows.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // .pen chipRow: two 148×48 pill chips per row, 14px apart; a lone
        // chip keeps its half-width (left-aligned) via the trailing spacer.
        for (var i = 0; i < suggestions.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _SuggestionChip(suggestions[i], onPick)),
              const SizedBox(width: 14),
              if (i + 1 < suggestions.length)
                Expanded(child: _SuggestionChip(suggestions[i + 1], onPick))
              else
                const Spacer(),
            ],
          ),
        ],
      ],
    );
  }
}

/// One suggestion pill — the .pen `Content/Chip`: h48, radius-pill,
/// surface-elevated fill with the border-default hairline, label 15/w500.
class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip(this.value, this.onPick);

  final String value;
  final ValueChanged<String>? onPick;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SizedBox(
      height: 48,
      child: Material(
        color: context.brand.surfaceElevated,
        shape: StadiumBorder(
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPick == null ? null : () => onPick!(value),
          child: Center(
            child: Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
