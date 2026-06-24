import 'package:flutter/material.dart';

/// One onboarding page's content. Immutable; the screen owns the list.
@immutable
class OnboardingStepData {
  const OnboardingStepData({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

/// Renders a single onboarding page: a large icon, title, and description,
/// centered with comfortable reading width.
class OnboardingStep extends StatelessWidget {
  const OnboardingStep({required this.data, super.key});

  final OnboardingStepData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, size: 96, color: theme.colorScheme.primary),
          const SizedBox(height: 40),
          Text(
            data.title,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(
              data.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
