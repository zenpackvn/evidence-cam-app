import 'dart:async';

import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/repositories/letters_repository.dart';
import '../domain/services/letter_share.dart';
import 'bloc/composer_cubit.dart';
import 'screens/attach_stamps_screen.dart';
import 'screens/composer_screen.dart';
import 'screens/letter_preview_screen.dart';
import 'screens/send_screen.dart';
import 'screens/send_success_screen.dart';

/// Entry point for the compose→send flow (SM-012..016). Given a template it
/// provides a [ComposerCubit] and walks the user through: compose → attach
/// stamps → pick platform → success. The host supplies the repositories, the
/// letter-link base URL, and a callback to actually open a platform DM.
///
/// This mounts a nested [Navigator] so the flow's back-stack is self-contained;
/// [onClose] leaves the flow entirely (e.g. back to Album/Home).
class ComposerFlow extends StatelessWidget {
  const ComposerFlow({
    required this.templateId,
    required this.letters,
    required this.stamps,
    required this.linkBaseUrl,
    required this.onClose,
    required this.onOpenShare,
    this.share = const LetterShare(),
    super.key,
  });

  final String templateId;
  final LettersRepository letters;
  final StampsRepository stamps;

  /// Base URL a letter link resolves under (from config); used to build the
  /// shareable URL from the minted link id.
  final String linkBaseUrl;

  final VoidCallback onClose;

  /// Opens the chosen platform's DM/share sheet with the letter URL. The host
  /// owns url_launcher / share_plus so this feature stays platform-agnostic.
  final void Function(SharePlatform platform, String letterUrl) onOpenShare;

  final LetterShare share;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ComposerCubit(letters, templateId: templateId),
      child: _ComposerNavigator(
        stamps: stamps,
        linkBaseUrl: linkBaseUrl,
        onClose: onClose,
        onOpenShare: onOpenShare,
      ),
    );
  }
}

class _ComposerNavigator extends StatelessWidget {
  const _ComposerNavigator({
    required this.stamps,
    required this.linkBaseUrl,
    required this.onClose,
    required this.onOpenShare,
  });

  final StampsRepository stamps;
  final String linkBaseUrl;
  final VoidCallback onClose;
  final void Function(SharePlatform platform, String letterUrl) onOpenShare;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateInitialRoutes: (navigator, _) => [
        MaterialPageRoute<void>(
          builder: (_) => _provide(
            context,
            ComposerScreen(
              onBack: onClose,
              onNext: () => _pushAttach(navigator, context),
            ),
          ),
        ),
      ],
    );
  }

  // Each pushed screen needs the same cubit instance, so re-provide it.
  Widget _provide(BuildContext context, Widget child) =>
      BlocProvider.value(value: context.read<ComposerCubit>(), child: child);

  Future<void> _pushAttach(
    NavigatorState navigator,
    BuildContext context,
  ) async {
    final result = await stamps.list();
    final list = switch (result) {
      Ok(:final value) => value,
      Err() => <Stamp>[],
    };
    if (!context.mounted) return;
    unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => _provide(
            context,
            AttachStampsScreen(
              stamps: list,
              onBack: navigator.pop,
              onDone: () => _pushPreview(navigator, context, list),
            ),
          ),
        ),
      ),
    );
  }

  /// F03-S09: the read-only preview between attaching stamps and sending.
  /// Sending an empty letter first raises the F03-S10 warning modal.
  void _pushPreview(
    NavigatorState navigator,
    BuildContext context,
    List<Stamp> list,
  ) {
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => _provide(
          context,
          Builder(
            builder: (innerContext) {
              final state = innerContext.watch<ComposerCubit>().state;
              final attached = state.stampIds.isEmpty
                  ? null
                  : list.where((s) => s.id == state.stampIds.first).firstOrNull;
              return LetterPreviewScreen(
                content: state.content,
                stampName: attached == null ? null : 'Tem của bạn',
                stampImageUrl: attached?.imageUrl,
                onEdit: navigator.pop,
                onSend: () async {
                  if (state.content.text.trim().isEmpty) {
                    final proceed = await showEmptyLetterWarning(innerContext);
                    if (!proceed) return;
                  }
                  if (innerContext.mounted) {
                    _pushSend(navigator, innerContext);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _pushSend(NavigatorState navigator, BuildContext context) {
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => _provide(
          context,
          SendScreen(
            onBack: navigator.pop,
            onSent: (platform) => _pushSuccess(navigator, context, platform),
          ),
        ),
      ),
    );
  }

  void _pushSuccess(
    NavigatorState navigator,
    BuildContext context,
    SharePlatform platform,
  ) {
    final link = context.read<ComposerCubit>().state.link;
    if (link == null) return;
    final url = link.shareUrl(linkBaseUrl);
    onOpenShare(platform, url);
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => SendSuccessScreen(linkUrl: url, onDone: onClose),
      ),
    );
  }
}
