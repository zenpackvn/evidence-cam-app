import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/letter_link.dart';
import '../../domain/letter_display.dart';
import '../../domain/repositories/letters_repository.dart';

/// Loads the sent-letters list for the "Thư" tab (SM-021, F04-S07d). The tab
/// is sent-only: received letters are never stored (SM-017 BR-10), so there is
/// no inbox to show.
@injectable
class SentLettersCubit extends Cubit<SentLettersState> {
  SentLettersCubit(this._letters, this._stamps)
    : super(const SentLettersState(isLoading: true));

  final LettersRepository _letters;
  final StampsRepository _stamps;

  Future<void> load() async {
    emit(const SentLettersState(isLoading: true));
    final result = await _letters.sent();
    switch (result) {
      case Ok(value: final letters):
        // Enrich each row the same way the Home "Thư gần đây" cards are, so the
        // Hộp thư shows the letter's title, occasion symbol and attached stamp
        // instead of a generic "Thư gửi qua …" line (SM-004 F01-S16 / SM-021).
        final stampById = {
          for (final s in switch (await _stamps.listLocal()) {
            Ok(value: final l) => l,
            Err() => const <Stamp>[],
          })
            s.id: s,
        };
        final views = await Future.wait<SentLetterView>([
          for (final sent in letters) _toView(sent, stampById),
        ]);
        emit(SentLettersState(letters: views));
      case Err(:final failure):
        emit(SentLettersState(error: failure.message));
    }
  }

  Future<SentLetterView> _toView(
    SentLetter sent,
    Map<String, Stamp> stampById,
  ) async {
    final meta = await _letters.cachedMeta(sent.link.letterId);
    final stampId = (meta?.stampIds.isNotEmpty ?? false)
        ? meta!.stampIds.first
        : null;
    final stamp = stampId == null ? null : stampById[stampId];
    final content = meta?.content;
    return SentLetterView(
      sent: sent,
      title: letterCardTitle(content),
      icon: letterOccasionEmoji(
        '${content?.title ?? ''} ${content?.text ?? ''}',
      ),
      stampImageUrl: stamp?.thumbUrl ?? stamp?.imageUrl,
    );
  }

  /// Recreates a share link for an expired letter (SM-021 BR-04) and reloads.
  /// Blocked for an already-opened letter (BR-05) — it has already reached its
  /// recipient. Returns whether a new link was minted.
  Future<bool> recreateLink(SentLetter sent) async {
    if (sent.status == SentStatus.opened) return false; // BR-05
    emit(state.copyWith(recreatingLetterId: sent.link.letterId));
    final result = await _letters.createLink(
      sent.link.letterId,
      platform: sent.link.platform,
    );
    emit(state.copyWith(clearRecreating: true));
    if (result is Ok) {
      await load();
      return true;
    }
    return false;
  }
}

/// A sent-letter row enriched for display: the link/status plus the letter's
/// title, occasion symbol and attached-stamp picture, mirroring the Home
/// "Thư gần đây" card (SM-021 / SM-004 F01-S16).
class SentLetterView {
  const SentLetterView({
    required this.sent,
    required this.title,
    required this.icon,
    this.stampImageUrl,
  });

  final SentLetter sent;
  final String title;

  /// Occasion emoji shown inside the envelope tile.
  final String icon;

  /// The attached stamp's picture, or null when the letter has no cached stamp.
  final String? stampImageUrl;
}

class SentLettersState {
  const SentLettersState({
    this.letters = const [],
    this.isLoading = false,
    this.error,
    this.recreatingLetterId,
  });

  final List<SentLetterView> letters;
  final bool isLoading;
  final String? error;

  /// The letterId whose link is currently being recreated (BR-04), or null.
  final String? recreatingLetterId;

  SentLettersState copyWith({
    String? recreatingLetterId,
    bool clearRecreating = false,
  }) => SentLettersState(
    letters: letters,
    isLoading: isLoading,
    error: error,
    recreatingLetterId: clearRecreating
        ? null
        : (recreatingLetterId ?? this.recreatingLetterId),
  );
}
