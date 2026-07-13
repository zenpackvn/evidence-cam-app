import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// SM-016 success (F03-S12) — "Gửi thư — Success": confirms the link was created
/// and offers to send another or finish. The link URL is shown so the sender can
/// copy it if the DM didn't open.
class SendSuccessScreen extends StatelessWidget {
  const SendSuccessScreen({
    required this.linkUrl,
    required this.onDone,
    this.onCopy,
    super.key,
  });

  final String linkUrl;
  final VoidCallback onDone;
  final VoidCallback? onCopy;

  static const _ground = Color(0xFFFBF5EC);

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Scaffold(
      backgroundColor: _ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Icon(Icons.send_rounded, size: 64, color: scheme.primary),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Đã tạo link gửi thư!',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Gửi link này cho người nhận. Link mở được một lần\ntrong 7 ngày.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.47,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _LinkChip(url: linkUrl, onCopy: onCopy),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: onDone,
                  child: const Text('Xong'),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({required this.url, this.onCopy});

  final String url;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          IconButton(
            onPressed: onCopy,
            icon: Icon(Icons.copy, size: 18, color: scheme.primary),
          ),
        ],
      ),
    );
  }
}
