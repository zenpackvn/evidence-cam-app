import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// The bottom action bar for a wizard step: a white "Quay lại" (back) and a
/// coral "Tiếp theo" (next), each a 52px pill (F02-S04 btnRow). The next label
/// is overridable so the last step can read "Lưu tem".
class WizardActions extends StatelessWidget {
  const WizardActions({
    required this.onBack,
    required this.onNext,
    this.nextLabel = 'Tiếp theo',
    this.nextEnabled = true,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool nextEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PillButton.secondary(label: 'Quay lại', onTap: onBack),
        ),
        const SizedBox(width: AppSpacing.xxl),
        Expanded(
          child: _PillButton.primary(
            label: nextLabel,
            onTap: nextEnabled ? onNext : null,
          ),
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton.primary({required this.label, required this.onTap})
    : _primary = true;
  const _PillButton.secondary({required this.label, required this.onTap})
    : _primary = false;

  final String label;
  final VoidCallback? onTap;
  final bool _primary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final bg = _primary
        ? colorScheme.primary
        : colorScheme.surfaceContainerLowest;
    final fg = _primary ? colorScheme.onPrimary : colorScheme.onSurface;
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1424211F),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              label,
              style: context.textTheme.titleMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
