import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/services/letter_share.dart';
import '../bloc/composer_cubit.dart';
import '../bloc/composer_state.dart';

/// SM-016 — "Gửi thư" (F03-S11): pick a platform to send the letter link to.
/// On confirm the cubit creates the letter + mints a one-time/7-day link, then
/// the host opens the platform's DM composer (or the share sheet) with the URL.
class SendScreen extends StatefulWidget {
  const SendScreen({required this.onBack, required this.onSent, super.key});

  final VoidCallback onBack;

  /// Called with the picked platform once the link is minted, so the host can
  /// open the DM / share sheet.
  final void Function(SharePlatform platform) onSent;

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  SharePlatform _platform = SharePlatform.messenger;

  static const _ground = Color(0xFFFBF5EC);

  // The eight platforms of SM-016 BR-04, in spec order (AC-07).
  static const _labels = <SharePlatform, (String, IconData)>{
    SharePlatform.messenger: ('Messenger', Icons.chat_bubble_outline),
    SharePlatform.instagram: ('Instagram', Icons.camera_alt_outlined),
    SharePlatform.tiktok: ('TikTok', Icons.music_note_outlined),
    SharePlatform.threads: ('Threads', Icons.alternate_email_outlined),
    SharePlatform.zalo: ('Zalo', Icons.forum_outlined),
    SharePlatform.whatsapp: ('WhatsApp', Icons.call_outlined),
    SharePlatform.imessage: ('iMessage', Icons.sms_outlined),
    SharePlatform.twitter: ('X', Icons.close_outlined),
  };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposerCubit, ComposerState>(
      listenWhen: (prev, next) => next.phase == ComposerPhase.sent,
      listener: (context, state) => widget.onSent(_platform),
      builder: (context, state) {
        final sending = state.phase == ComposerPhase.sending;
        return Scaffold(
          backgroundColor: _ground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: BackButton(onPressed: widget.onBack),
            title: Text(
              'Gửi thư',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                const _SendInfo(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: AppSpacing.lg,
                      crossAxisSpacing: AppSpacing.lg,
                      children: [
                        for (final entry in _labels.entries)
                          _PlatformTile(
                            label: entry.value.$1,
                            icon: entry.value.$2,
                            selected: entry.key == _platform,
                            onTap: () => setState(() => _platform = entry.key),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xxl,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: sending
                          ? null
                          : () => context.read<ComposerCubit>().send(
                              platform: _platform.wire,
                            ),
                      icon: sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: const Text('Tạo link & mở DM'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SendInfo extends StatelessWidget {
  const _SendInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EF),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            icon: Icons.person_outline,
            text: 'Mỗi người nhận một link riêng',
          ),
          SizedBox(height: AppSpacing.xs),
          _InfoRow(
            icon: Icons.lock_clock_outlined,
            text: 'Link mở 1 lần • hiệu lực 7 ngày',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          text,
          style: context.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PlatformTile extends StatelessWidget {
  const _PlatformTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: selected ? scheme.primary : scheme.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
            child: Icon(
              icon,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
