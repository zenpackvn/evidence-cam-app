import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/letter.dart';
import '../../domain/entities/letter_link.dart';
import '../../domain/letter_display.dart';
import '../../domain/repositories/letters_repository.dart';

/// Loads the sent-letters list for the "Thư" tab (SM-021, F04-S07d). The tab
/// is sent-only: received letters are never stored (SM-017 BR-10), so there is
/// no inbox to show.
///
/// Each row is enriched (title, occasion symbol, attached-stamp picture) the
/// same way the Home "Thư gần đây" cards are, and the letter documents from
/// the server are joined in as well so the "xem thư đã gửi" detail can show a
/// letter's content next to its link statuses.
@injectable
class SentLettersCubit extends Cubit<SentLettersState> {
  SentLettersCubit(this._letters, this._stamps)
    : super(const SentLettersState(isLoading: true));

  final LettersRepository _letters;
  final StampsRepository _stamps;

  Future<void> load() async {
    emit(const SentLettersState(isLoading: true));
    final results = await Future.wait([_letters.sent(), _letters.letters()]);
    final sentResult = results[0] as Result<List<SentLetter>>;
    final docsResult = results[1] as Result<List<Letter>>;
    switch (sentResult) {
      case Ok(value: final links):
        // Enrich each row from the locally-cached composed letter (title,
        // occasion symbol, attached stamp), mirroring the Home cards.
        final stampById = {
          for (final s in switch (await _stamps.listLocal()) {
            Ok(value: final l) => l,
            Err() => const <Stamp>[],
          })
            s.id: s,
        };
        final letterDocs = switch (docsResult) {
          Ok(value: final d) => {for (final l in d) l.id: l},
          Err() => const <String, Letter>{},
        };
        final views = await Future.wait<SentLetterView>([
          for (final sent in links)
            _toView(sent, stampById, letterDocs[sent.link.letterId]),
        ]);
        emit(SentLettersState(rawLinks: links, letters: views, letterDocs: letterDocs));
      case Err(:final failure):
        emit(SentLettersState(error: failure.message));
    }
  }

  Future<SentLetterView> _toView(
    SentLetter sent,
    Map<String, Stamp> stampById,
    Letter? doc,
  ) async {
    final meta = await _letters.cachedMeta(sent.link.letterId);
    // Prefer the server letter document's title/stamp when available; fall back
    // to the locally-cached copy (older servers, or a letter sent elsewhere).
    final content = doc?.content ?? meta?.content;
    final stampIds = (doc?.stampIds.isNotEmpty ?? false)
        ? doc!.stampIds
        : (meta?.stampIds ?? const <String>[]);
    final stampId = stampIds.isNotEmpty ? stampIds.first : null;
    final stamp = stampId == null ? null : stampById[stampId];
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
    this.rawLinks = const [],
    this.letters = const [],
    this.letterDocs = const {},
    this.isLoading = false,
    this.error,
    this.recreatingLetterId,
  });

  /// The raw sent links (all of them), used by the detail's per-link list.
  final List<SentLetter> rawLinks;

  /// The enriched rows shown in the mailbox list.
  final List<SentLetterView> letters;

  /// The caller's letter documents by id (SM-021 detail view). Empty against
  /// servers that don't expose the letters route.
  final Map<String, Letter> letterDocs;

  final bool isLoading;
  final String? error;

  /// The letterId whose link is currently being recreated (BR-04), or null.
  final String? recreatingLetterId;

  /// Every link minted for [letterId], newest first — one letter can carry
  /// several (multi-platform sends, renewals; D11).
  List<SentLetter> linksFor(String letterId) => [
    for (final l in rawLinks)
      if (l.link.letterId == letterId) l,
  ]..sort((a, b) => b.link.createdAt.compareTo(a.link.createdAt));

  /// The letter document behind [letterId], when the server provides it.
  Letter? letterFor(String letterId) => letterDocs[letterId];

  SentLettersState copyWith({
    String? recreatingLetterId,
    bool clearRecreating = false,
  }) => SentLettersState(
    rawLinks: rawLinks,
    letters: letters,
    letterDocs: letterDocs,
    isLoading: isLoading,
    error: error,
    recreatingLetterId: clearRecreating
        ? null
        : (recreatingLetterId ?? this.recreatingLetterId),
  );
}
