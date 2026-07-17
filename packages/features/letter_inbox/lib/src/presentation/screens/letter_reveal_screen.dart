import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/repositories/inbox_repository.dart';
import '../bloc/reveal_cubit.dart';
import '../bloc/reveal_state.dart';
import '../widgets/envelope_reveal.dart';
import '../widgets/opened_letter_view.dart';

/// SM-017/019 — the receive flow: an intro card ("Bạn có một bức thư!",
/// F04-S01), the open animation (F04-S03/04), then the readable letter
/// (F04-S05) or a terminal state (already-opened / expired / invalid).
///
/// Works for both a signed-in recipient and an anonymous web reader; the host
/// supplies the link id and the reply/save affordances.
class LetterRevealScreen extends StatelessWidget {
  const LetterRevealScreen({
    required this.linkId,
    required this.onReply,
    this.viewerUid,
    this.senderName,
    super.key,
  });

  final String linkId;
  final String? viewerUid;
  final String? senderName;

  /// Called to start a reply with the original sender's name (prefill the
  /// recipient, SM-020 BR-01) and uid (address the "letter received" push,
  /// SM-026 D12).
  final void Function({required String senderName, required String senderUid})
  onReply;

  static const _ground = Color(0xFFFBF4EC);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RevealCubit(
        GetIt.instance<InboxRepository>(),
        linkId: linkId,
        viewerUid: viewerUid,
        senderName: senderName,
      ),
      child: Scaffold(
        backgroundColor: _ground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: BlocBuilder<RevealCubit, RevealState>(
              builder: (context, state) => switch (state.phase) {
                RevealPhase.intro => _Intro(
                  senderName: state.senderName,
                  onOpen: context.read<RevealCubit>().open,
                ),
                RevealPhase.opening => _Opening(
                  onRevealed: () {},
                ),
                RevealPhase.opened => OpenedLetterView(
                  letter: state.letter!,
                  senderName: state.senderName,
                  // SM-020 BR-01 / SM-026 D12: reply prefills the original
                  // sender and addresses the push back to them. Prefer the name
                  // the server resolved on the letter, then any deferred-link
                  // name.
                  onReply: () => onReply(
                    senderName: state.letter!.senderName.isNotEmpty
                        ? state.letter!.senderName
                        : (state.senderName ?? ''),
                    senderUid: state.letter!.senderUid,
                  ),
                ),
                RevealPhase.alreadyOpened => const _Terminal(
                  icon: Icons.drafts_outlined,
                  title: 'Thư đã được mở',
                  body: 'Bức thư này đã được mở trước đó. Mỗi link chỉ mở '
                      'được một lần.',
                ),
                RevealPhase.expired => const _Terminal(
                  icon: Icons.schedule_outlined,
                  title: 'Link đã hết hạn',
                  body: 'Bức thư này đã quá 7 ngày và không còn mở được nữa.',
                ),
                RevealPhase.invalid => const _Terminal(
                  icon: Icons.link_off_outlined,
                  title: 'Không tìm thấy thư',
                  body: 'Link không hợp lệ hoặc đã bị gỡ.',
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onOpen, this.senderName});

  final VoidCallback onOpen;
  final String? senderName;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFFF3E7D3),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Icon(Icons.mail, size: 56, color: scheme.primary),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Bạn có một bức thư!',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (senderName != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'từ $senderName',
            style: context.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        SizedBox(
          width: 200,
          height: 52,
          child: FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.mark_email_read_outlined),
            label: const Text('Mở thư'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Hiệu lực: còn 6 ngày',
          style: context.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Opening extends StatelessWidget {
  const _Opening({required this.onRevealed});

  final VoidCallback onRevealed;

  @override
  Widget build(BuildContext context) {
    // The animation runs while the network open resolves; the cubit switches to
    // `opened` when ready, replacing this with the letter.
    return EnvelopeReveal(onRevealed: onRevealed);
  }
}

class _Terminal extends StatelessWidget {
  const _Terminal({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: scheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.xl),
          Text(
            title,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
