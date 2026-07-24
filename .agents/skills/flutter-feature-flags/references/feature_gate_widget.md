# Feature Gate Widget & Dev Menu

## Conditional Feature Widget — `feature_gate.dart`

A utility widget that shows/hides children based on a flag.

```dart
import 'package:flutter/widgets.dart';
import '../di/service_locator.dart';
import 'feature_flag.dart';
import 'feature_flag_service.dart';

/// Shows [child] only when [flag] is enabled. Shows [fallback] otherwise.
///
/// Usage:
/// ```dart
/// FeatureGate(
///   flag: FeatureFlag.newOnboarding,
///   child: NewOnboardingFlow(),
///   fallback: ClassicOnboardingFlow(),
/// )
/// ```
class FeatureGate extends StatelessWidget {
  const FeatureGate({
    super.key,
    required this.flag,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  final FeatureFlag flag;
  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final flags = getIt<FeatureFlagService>();
    return flags.isEnabled(flag) ? child : fallback;
  }
}
```

## Dev Menu Integration

A debug screen to override flags during development.

```dart
import 'package:flutter/material.dart';
import '../../core/feature_flags/feature_flag.dart';
import '../../core/feature_flags/feature_flag_service.dart';
import '../../core/feature_flags/local_feature_flag_service.dart';

/// Debug screen to toggle feature flags at runtime.
/// Only accessible in dev builds.
class FeatureFlagDevMenu extends StatefulWidget {
  const FeatureFlagDevMenu({super.key, required this.service});

  final FeatureFlagService service;

  @override
  State<FeatureFlagDevMenu> createState() => _FeatureFlagDevMenuState();
}

class _FeatureFlagDevMenuState extends State<FeatureFlagDevMenu> {
  @override
  void initState() {
    super.initState();
    widget.service.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.service.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Flags'),
        actions: [
          if (widget.service is LocalFeatureFlagService)
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: 'Reset all',
              onPressed: () {
                (widget.service as LocalFeatureFlagService).clearAll();
              },
            ),
        ],
      ),
      body: ListView(
        children: FeatureFlag.values.map((flag) {
          final isBool = flag.defaultValue is bool;
          return ListTile(
            title: Text(flag.key),
            subtitle: Text(flag.description),
            trailing: isBool
                ? Switch(
                    value: widget.service.isEnabled(flag),
                    onChanged: widget.service is LocalFeatureFlagService
                        ? (value) {
                            (widget.service as LocalFeatureFlagService)
                                .setFlag(flag, value);
                          }
                        : null,
                  )
                : Text(
                    widget.service.getString(flag),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
          );
        }).toList(),
      ),
    );
  }
}
```

## Notes

- `FeatureGate` is best for simple show/hide decisions where the flag value does not affect other business logic.
- For complex flag-driven logic (A/B variants, combined conditions), resolve flags in the cubit and render from state instead.
- The dev menu uses `LocalFeatureFlagService` directly — safe to cast because dev always registers the local impl.
