import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/received_letter.dart';

/// The readable opened letter (F04-S05): the sender header, the letter body on
/// tinted paper, the attached stamps, and the Reply action. There is no
/// save-stamp action — received stamps are never added to the recipient's album
/// (SM-017 BR-05 / SM-019 BR-03).
class OpenedLetterView extends StatelessWidget {
  const OpenedLetterView({
    required this.letter,
    required this.senderName,
    required this.onReply,
    this.onShare,
    super.key,
  });

  final ReceivedLetter letter;
  final String? senderName;
  final VoidCallback onReply;

  /// Opens the share-to-social flow for this letter (SM-025 Mức 1/2/3). Null
  /// when there is no attached stamp to lay out.
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      children: [
        _SenderHeader(name: senderName),
        const SizedBox(height: AppSpacing.md),
        // .pen F04-S05: a coral heart above the "Thư đã mở" title (30/w700).
        Icon(Icons.favorite, size: 20, color: scheme.primary),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Thư đã mở',
          style: context.textTheme.displayMedium?.copyWith(fontSize: 30),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Cảm ơn bạn đã chạm vào những lời yêu thương ❤️',
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 300),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF6EC),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1424211F),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    letter.text,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: Color(0xFF3A322C),
                    ),
                  ),
                ),
                if (letter.stamps.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _AttachedStamps(letter: letter),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Actions(onReply: onReply, onShare: onShare),
      ],
    );
  }
}

class _SenderHeader extends StatelessWidget {
  const _SenderHeader({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: scheme.primaryContainer,
          child: Icon(Icons.person, size: 16, color: scheme.onPrimaryContainer),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          name ?? 'Một người bạn',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AttachedStamps extends StatelessWidget {
  const _AttachedStamps({required this.letter});

  final ReceivedLetter letter;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final stamp in letter.stamps)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
              width: 72,
              height: 96,
              child: AppNetworkImage(
                imageUrl: stamp.thumbUrl ?? stamp.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.onReply, this.onShare});

  final VoidCallback onReply;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    // SM-019 BR-03: Reply (login-gated). No "save stamp" action. SM-025: an
    // optional Share when the letter has a stamp to lay out.
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: onReply,
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              textStyle: context.textTheme.titleMedium,
            ),
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Trả lời'),
          ),
        ),
        if (onShare != null) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.ios_share),
              label: const Text('Chia sẻ'),
            ),
          ),
        ],
      ],
    );
  }
}
