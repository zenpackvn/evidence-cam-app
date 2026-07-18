import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/profile_sub_scaffold.dart';

/// F07-S13 — delete account confirmation: an explainer card that deletion is
/// immediate and permanent, an "I understand" checkbox, and the destructive
/// confirm / cancel buttons.
///
/// Wording matches the backend: [onConfirm] runs `AuthRepository.deleteAccount`,
/// which deletes the Firebase account outright — there is no pending-delete
/// grace period, so the copy must not promise one.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({
    required this.onConfirm,
    this.onCancel,
    super.key,
  });

  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  static const _deleteRed = Color(0xFFE8442E);

  bool _acknowledged = false;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return ProfileSubScaffold(
      title: 'Xoá tài khoản',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE9E4),
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: Column(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8D3CC),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 30,
                      color: scheme.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Tài khoản sẽ bị xoá vĩnh viễn',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontSize: 19,
                      color: scheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF3EF),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: const Column(
                      children: [
                        _WarnRow(
                          icon: Icons.bolt_outlined,
                          text:
                              'Sau khi xác nhận, tài khoản của bạn sẽ bị xoá ',
                          emphasis: 'ngay lập tức.',
                        ),
                        _WarnDivider(),
                        _WarnRow(
                          icon: Icons.delete_forever_outlined,
                          text: 'Tem, thư và toàn bộ dữ liệu liên quan sẽ bị ',
                          emphasis: 'xoá vĩnh viễn.',
                        ),
                        _WarnDivider(),
                        _WarnRow(
                          icon: Icons.block,
                          text: 'Thao tác này ',
                          emphasis: 'không thể hoàn tác.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // "I understand" acknowledgement row.
            InkWell(
              onTap: () => setState(() => _acknowledged = !_acknowledged),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.brand.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _acknowledged
                            ? scheme.error
                            : context.brand.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: _acknowledged
                            ? null
                            : Border.all(color: scheme.outlineVariant),
                      ),
                      child: _acknowledged
                          ? Icon(Icons.check, size: 17, color: scheme.onError)
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Tôi hiểu rằng thao tác này không thể hoàn tác.',
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _acknowledged ? widget.onConfirm : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _deleteRed,
                  disabledBackgroundColor: _deleteRed.withValues(alpha: 0.4),
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  textStyle: context.textTheme.titleMedium,
                ),
                child: const Text('Xác nhận xoá'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed:
                    widget.onCancel ?? () => Navigator.of(context).maybePop(),
                style: FilledButton.styleFrom(
                  backgroundColor: context.brand.surfaceElevated,
                  foregroundColor: scheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  textStyle: context.textTheme.titleMedium,
                ),
                child: const Text('Huỷ'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: context.brand.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: context.brand.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDF1DC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFFB07C2A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bạn có thể đăng nhập lại trong thời gian chờ để huỷ '
                      'yêu cầu xoá.',
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _WarnDivider extends StatelessWidget {
  const _WarnDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, color: Color(0xFFF3DCD4)),
    );
  }
}

class _WarnRow extends StatelessWidget {
  const _WarnRow({required this.icon, required this.text, this.emphasis});

  final IconData icon;
  final String text;

  /// Trailing red-bold fragment ("7 ngày.", "xoá vĩnh viễn.").
  final String? emphasis;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFFFBDDD8),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: scheme.error),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: context.textTheme.bodyMedium,
              children: [
                TextSpan(text: text),
                if (emphasis != null)
                  TextSpan(
                    text: emphasis,
                    style: TextStyle(
                      color: scheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
