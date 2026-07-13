import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Shared chrome for the settings sub-screens (F07-S04/S08/S12/S13): the warm
/// `#FBF1E9` ground with a centered Baloo-22 title between a circular back
/// button and an optional trailing action.
class ProfileSubScaffold extends StatelessWidget {
  const ProfileSubScaffold({
    required this.title,
    required this.child,
    this.onBack,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final Widget? trailing;

  static const ground = Color(0xFFFBF1E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Row(
                children: [
                  _CircleBack(
                    onTap: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: context.textTheme.displayMedium?.copyWith(
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 44, child: Center(child: trailing)),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _CircleBack extends StatelessWidget {
  const _CircleBack({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.brand.surfaceElevated,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back,
            size: 20,
            color: context.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
