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
  const ChooseUsernameScreen({super.key});

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
    // ponytail: reserve username via AuthBloc; here just demo submitting.
    setState(() {
      _error = null;
      _submitting = true;
    });
  }

  void _pickSuggestion(String value) {
    _controller.text = value;
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      bottomAsset: 'user-envelope.png',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthBrandHeader().animateSlideDown(),
          const SizedBox(height: AppSpacing.xxl),
          AuthHeading(
            title: l10n.smUsernameTitle,
            subtitle: l10n.smUsernameSubtitle,
          ).animateSlideDown(delay: 50.ms),
          const SizedBox(height: AppSpacing.xxxl),
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
          const SizedBox(height: AppSpacing.xl),
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
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final suggestion in suggestions)
              ActionChip(
                label: Text(suggestion),
                onPressed: onPick == null ? null : () => onPick!(suggestion),
                backgroundColor: colorScheme.surfaceContainerLowest,
                side: BorderSide(color: colorScheme.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                labelStyle: context.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
