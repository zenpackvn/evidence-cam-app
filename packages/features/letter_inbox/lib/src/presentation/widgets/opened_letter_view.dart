import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/received_letter.dart';

/// The readable opened letter (F04-S05): the sender header, the letter body on
/// tinted paper, the attached stamps, and Save-to-Album / Reply actions.
class OpenedLetterView extends StatelessWidget {
  const OpenedLetterView({
    required this.letter,
    required this.senderName,
    required this.onSaveStamps,
    required this.onReply,
    this.stampsSaved = false,
    this.savingStamps = false,
    super.key,
  });

  final ReceivedLetter letter;
  final String? senderName;
  final VoidCallback onSaveStamps;
  final VoidCallback onReply;
  final bool stampsSaved;
  final bool savingStamps;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      children: [
        _SenderHeader(name: senderName),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Thư đã mở',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
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
        _Actions(
          onSaveStamps: onSaveStamps,
          onReply: onReply,
          stampsSaved: stampsSaved,
          savingStamps: savingStamps,
        ),
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
  const _Actions({
    required this.onSaveStamps,
    required this.onReply,
    required this.stampsSaved,
    required this.savingStamps,
  });

  final VoidCallback onSaveStamps;
  final VoidCallback onReply;
  final bool stampsSaved;
  final bool savingStamps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: (stampsSaved || savingStamps) ? null : onSaveStamps,
            icon: savingStamps
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(stampsSaved ? Icons.check : Icons.download_outlined),
            label: Text(stampsSaved ? 'Đã lưu vào Album' : 'Lưu vào Album'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onReply,
            icon: const Icon(Icons.reply_outlined),
            label: const Text('Trả lời'),
          ),
        ),
      ],
    );
  }
}
