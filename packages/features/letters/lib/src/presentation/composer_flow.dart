import 'dart:async';

import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/repositories/letters_repository.dart';
import '../domain/services/letter_share.dart';
import 'bloc/composer_cubit.dart';
import 'composer_catalog.dart';
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
    this.replyToUid,
    super.key,
  });

  final String templateId;
  final LettersRepository letters;
  final StampsRepository stamps;

  /// Set when composing a reply (SM-020) — the original sender's uid, threaded
  /// to the created letter for the "letter received" push (SM-026 D12).
  final String? replyToUid;

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
      create: (_) => ComposerCubit(
        letters,
        templateId: templateId,
        replyToUid: replyToUid,
      ),
      child: _ComposerNavigator(
        stamps: stamps,
        linkBaseUrl: linkBaseUrl,
        onClose: onClose,
        onOpenShare: onOpenShare,
      ),
    );
  }
}

class _ComposerNavigator extends StatefulWidget {
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
  State<_ComposerNavigator> createState() => _ComposerNavigatorState();
}

class _ComposerNavigatorState extends State<_ComposerNavigator> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  StampsRepository get stamps => widget.stamps;
  String get linkBaseUrl => widget.linkBaseUrl;
  VoidCallback get onClose => widget.onClose;
  void Function(SharePlatform, String) get onOpenShare => widget.onOpenShare;

  @override
  Widget build(BuildContext context) {
    // System back steps through the nested flow (compose → attach → preview →
    // send → success); only from the first screen does it fall through and leave
    // the flow. Without this the OS back would pop the whole /compose route at
    // once, skipping the steps.
    return NavigatorPopHandler(
      onPopWithResult: (_) => _navigatorKey.currentState?.maybePop(),
      child: Navigator(
        key: _navigatorKey,
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
      ),
    );
  }

  // Each pushed screen needs the same cubit instance, so re-provide it.
  Widget _provide(BuildContext context, Widget child) =>
      BlocProvider.value(value: context.read<ComposerCubit>(), child: child);

  /// The stamp's display label: the name the user gave it (SM-022 BR-08),
  /// falling back to "Tem của bạn" only when it was left unnamed.
  String _stampLabel(Stamp stamp) =>
      stamp.name.trim().isNotEmpty ? stamp.name.trim() : 'Tem của bạn';

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
              final cubit = innerContext.read<ComposerCubit>();
              final state = innerContext.watch<ComposerCubit>().state;
              final attached = state.stampIds.isEmpty
                  ? null
                  : list.where((s) => s.id == state.stampIds.first).firstOrNull;
              return LetterPreviewScreen(
                content: state.content,
                // The full stamp layout, so the preview matches "Đính tem" — and
                // the stamps stay adjustable here too.
                stamps: list,
                stampIds: state.stampIds,
                placements: state.placements,
                onMoveStamp: cubit.moveStamp,
                onRotateStamp: cubit.rotateStamp,
                stampName: attached == null
                    ? null
                    : (state.stampIds.length > 1
                          ? '${state.stampIds.length} con tem'
                          : _stampLabel(attached)),
                stampImageUrl: attached?.imageUrl,
                // "Chỉnh sửa" returns to the composer; "Đổi tem" to the stamp
                // picker one step back; "Đổi mẫu" opens the template chooser.
                onEdit: () => navigator.popUntil((r) => r.isFirst),
                onChangeStamp: navigator.pop,
                onChangeTemplate: () => _pickTemplate(innerContext),
                onSend: () async {
                  if (state.content.text.trim().isEmpty) {
                    final proceed = await showEmptyLetterWarning(innerContext);
                    if (!proceed) return;
                  }
                  if (innerContext.mounted) {
                    _pushSend(navigator, innerContext, attached);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// "Đổi mẫu" (F03-S09): a bottom sheet to swap the letter template; the cubit
  /// re-tints the paper and the preview rebuilds.
  void _pickTemplate(BuildContext context) {
    final cubit = context.read<ComposerCubit>();
    final current = cubit.state.content.templateId;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Đổi mẫu thư',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Creator/dev build: all templates unlocked (no premium gate).
                  for (final t in letterTemplates)
                    ListTile(
                      leading: t.artAsset != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                t.artAsset!,
                                width: 56,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : null,
                      title: Text(t.label),
                      trailing: t.id == current
                          ? Icon(
                              Icons.check,
                              color: Theme.of(sheetContext).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        cubit.selectTemplate(t.id);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _pushSend(
    NavigatorState navigator,
    BuildContext context,
    Stamp? stamp,
  ) {
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => _provide(
          context,
          SendScreen(
            stampName: stamp == null ? null : _stampLabel(stamp),
            stampImageUrl: stamp?.imageUrl,
            onBack: navigator.pop,
            onSent: (platform) =>
                _pushSuccess(navigator, context, platform, stamp),
          ),
        ),
      ),
    );
  }

  void _pushSuccess(
    NavigatorState navigator,
    BuildContext context,
    SharePlatform platform,
    Stamp? stamp,
  ) {
    final state = context.read<ComposerCubit>().state;
    final link = state.link;
    if (link == null) return;
    final url = link.shareUrl(linkBaseUrl);
    onOpenShare(platform, url);
    // "gửi như nào thì hiện như vậy" (fc2065): the success screen echoes the
    // exact platform(s) sent to, the letter's title, and its attached stamp.
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => SendSuccessScreen(
          linkUrl: url,
          platforms: [platform],
          letterTitle: state.content.title.isNotEmpty
              ? state.content.title
              : templateById(state.content.templateId).label,
          stampName: stamp == null ? null : _stampLabel(stamp),
          stampImageUrl: stamp?.imageUrl,
          onDone: onClose,
        ),
      ),
    );
  }
}
