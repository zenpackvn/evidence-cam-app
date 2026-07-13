import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/profile_sub_scaffold.dart';

/// F07-S12 — notification preferences: the permission status card, per-topic
/// toggle groups, and the deep-link info banners.
///
// ponytail: toggles are local state until notification preferences persist
// (A11 device tokens + a prefs endpoint).
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({this.permissionGranted = true, super.key});

  final bool permissionGranted;

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _values = <String, bool>{
    'new-letter': true,
    'letter-read': true,
    'quota': true,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final semantic = context.semanticColors;
    return ProfileSubScaffold(
      title: 'Thông báo',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Permission status card.
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.brand.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDF1E0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active_outlined,
                      size: 22,
                      color: context.brand.orange,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Giữ kết nối với thư mới và các cập nhật quan trọng.',
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  if (widget.permissionGranted)
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: semantic.successContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check, size: 14, color: semantic.success),
                          const SizedBox(width: 5),
                          Text(
                            'Đã cấp quyền',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: semantic.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () {},
                      child: const Text('Mở Cài đặt hệ thống'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _ToggleGroup(
              title: 'Thư',
              rows: [
                const _ToggleRowSpec(
                  id: 'new-letter',
                  icon: Icons.mail_outline,
                  iconColor: Color(0xFF8B6BD8),
                  iconBackground: Color(0xFFEFEAFB),
                  label: 'Bạn có thư mới',
                ),
                _ToggleRowSpec(
                  id: 'letter-read',
                  icon: Icons.mark_email_read_outlined,
                  iconColor: semantic.success,
                  iconBackground: semantic.successContainer,
                  label: 'Thư của bạn được đọc',
                ),
                _ToggleRowSpec(
                  id: 'quota',
                  icon: Icons.hourglass_bottom,
                  iconColor: context.brand.orange,
                  iconBackground: const Color(0xFFFDF1E0),
                  label: 'Hạn mức Free sắp cạn',
                ),
              ],
              values: _values,
              onChanged: (id, {required value}) =>
                  setState(() => _values[id] = value),
            ),
            const SizedBox(height: 10),
            // Deep-link info banner.
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F0FB),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Color(0xFF3B78C2),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nhấn vào thông báo sẽ mở đúng màn hình liên quan '
                      'trong app.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: const Color(0xFFE9C79B)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_outlined,
                    size: 18,
                    color: Color(0xFFB07C2A),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nếu chưa cấp quyền, hiển thị nút "Mở Cài đặt hệ thống".',
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

class _ToggleRowSpec {
  const _ToggleRowSpec({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
  });

  final String id;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
}

class _ToggleGroup extends StatelessWidget {
  const _ToggleGroup({
    required this.title,
    required this.rows,
    required this.values,
    required this.onChanged,
  });

  final String title;
  final List<_ToggleRowSpec> rows;
  final Map<String, bool> values;
  final void Function(String id, {required bool value}) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.brand.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xs,
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.brand.borderSubtle),
            ),
            child: Column(
              children: [
                for (final (i, row) in rows.indexed) ...[
                  if (i > 0)
                    Divider(height: 1, color: context.brand.borderSubtle),
                  SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: row.iconBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(row.icon, size: 19, color: row.iconColor),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            row.label,
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Switch(
                          value: values[row.id] ?? false,
                          onChanged: (v) => onChanged(row.id, value: v),
                        ),
                      ],
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
