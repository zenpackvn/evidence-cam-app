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
  static const _package = 'feature_letters';

  // The eight platforms of SM-016 BR-04, in spec order (AC-07), each with its
  // brand logo (`.pen` f3-pf-Nc). ponytail: single-select for now — the design
  // hints at multi-select, which would change the cubit's send contract.
  static const _platforms = <(SharePlatform, String, String)>[
    (SharePlatform.messenger, 'Messenger', 'f3-pf-1c.png'),
    (SharePlatform.instagram, 'Instagram DM', 'f3-pf-2c.png'),
    (SharePlatform.tiktok, 'TikTok DM', 'f3-pf-3c.png'),
    (SharePlatform.threads, 'Threads', 'f3-pf-4c.png'),
    (SharePlatform.zalo, 'Zalo', 'f3-pf-5c.png'),
    (SharePlatform.whatsapp, 'WhatsApp', 'f3-pf-6c.png'),
    (SharePlatform.imessage, 'iMessage', 'f3-pf-7c.png'),
    (SharePlatform.twitter, 'X / Twitter', 'f3-pf-8c.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposerCubit, ComposerState>(
      listenWhen: (prev, next) => next.phase == ComposerPhase.sent,
      listener: (context, state) => widget.onSent(_platform),
      builder: (context, state) {
        final sending = state.phase == ComposerPhase.sending;
        return Scaffold(
          backgroundColor: _ground,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    0,
                  ),
                  child: _Header(onBack: widget.onBack),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    children: [
                      const _RulesCard(),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Chọn nền tảng gửi đến',
                        style: context.textTheme.displayMedium?.copyWith(
                          fontSize: 21,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 80 / 92,
                        children: [
                          for (final (platform, label, asset) in _platforms)
                            _PlatformTile(
                              label: label,
                              asset: asset,
                              selected: platform == _platform,
                              onTap: () => setState(() => _platform = platform),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '🌼 Chọn nền tảng bạn hay dùng để mở DM cho nhanh.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: sending
                              ? null
                              : () => context.read<ComposerCubit>().send(
                                  platform: _platform.wire,
                                ),
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colorScheme.primary,
                            shape: const StadiumBorder(),
                            textStyle: context.textTheme.titleMedium,
                          ),
                          icon: sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send, size: 20),
                          label: const Text('Tạo link & mở DM'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: widget.onBack,
                        style: TextButton.styleFrom(
                          foregroundColor: context.colorScheme.primary,
                          textStyle: context.textTheme.titleMedium,
                        ),
                        child: const Text('Quay lại xem trước'),
                      ),
                    ],
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

/// Back button, centered "StampMail" wordmark, then the "Gửi thư" title
/// (`.pen` F03-S11 header).
class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Material(
              color: context.brand.surfaceElevated,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onBack,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.chevron_left, size: 22),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'StampMail',
                  style: context.textTheme.displayMedium?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 44),
          ],
        ),
        Text(
          'Gửi thư',
          style: context.textTheme.displayMedium?.copyWith(fontSize: 32),
        ),
      ],
    );
  }
}

/// The one-link-per-recipient / expiry rules card (`.pen` soft-peach panel).
class _RulesCard extends StatelessWidget {
  const _RulesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.brand.softPeach,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: const Column(
        children: [
          _RuleRow(
            icon: Icons.person_outline,
            text: 'Mỗi người nhận = một link riêng.',
          ),
          SizedBox(height: 10),
          _RuleRow(
            icon: Icons.lock_clock_outlined,
            text: 'Link mở được 1 lần • hiệu lực 7 ngày.',
          ),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: context.colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// One platform: its brand logo in a surface-elevated card, a coral check
/// badge when picked (`.pen` F03-S11 platform tile).
class _PlatformTile extends StatelessWidget {
  const _PlatformTile({
    required this.label,
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          color: context.brand.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? scheme.primary : context.brand.borderSubtle,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/platforms/$asset',
                    package: _SendScreenState._package,
                    width: 40,
                    height: 40,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 13, color: scheme.onPrimary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
