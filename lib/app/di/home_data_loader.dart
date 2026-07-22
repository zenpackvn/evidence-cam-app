import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:feature_home/feature_home.dart';
import 'package:feature_letters/feature_letters.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_contracts/shared_contracts.dart';

/// Composition-root implementation of the home dashboard's [HomeDataLoader]:
/// reads the album (recent stamps) and letters (recent sent letters) features.
/// Lives in the app shell so `feature_home` stays free of cross-feature
/// imports (SM-004).
@LazySingleton(as: HomeDataLoader)
class StampMailHomeDataLoader implements HomeDataLoader {
  StampMailHomeDataLoader(this._stamps, this._letters, this._quota);

  final StampsRepository _stamps;
  final LettersRepository _letters;
  final QuotaReader _quota;

  static const _maxStamps = 6;
  static const _maxLetters = 5;

  @override
  Future<HomeData> load() async {
    // Stamps come from the local store first (offline-first, SM-004 BR-06).
    final stampList = switch (await _stamps.listLocal()) {
      Ok(value: final list) => list,
      Err() => const <Stamp>[],
    };
    // Look up a letter's attached stamp so its Home card can show that stamp as
    // the letter's picture (SM-004 F01-S16).
    final stampById = {for (final s in stampList) s.id: s};
    final stamps = [
      for (final s in stampList.take(_maxStamps))
        StampRef(
          id: s.id,
          imageUrl: s.imageUrl,
          thumbUrl: s.thumbUrl,
          createdAt: s.createdAt,
          // Carry the user's stamp name (SM-022 BR-08) so the "Tem gần đây"
          // card shows it instead of the generic "Tem của bạn". Empty → null
          // so the card's date/label fallback still kicks in.
          name: s.name.isEmpty ? null : s.name,
        ),
    ];

    final letters = switch (await _letters.sent()) {
      Ok(value: final list) => await Future.wait<HomeLetterItem>([
        for (final sent in list.take(_maxLetters))
          _toLetterItem(sent, stampById),
      ]),
      Err() => const <HomeLetterItem>[],
    };

    // Quota for the low-quota nudge (SM-030). A read failure degrades to
    // unlimited so the banner just stays hidden rather than erroring the home.
    final quota = switch (await _quota()) {
      Ok(value: final q) => q,
      Err() => QuotaRemaining.unlimited,
    };

    return HomeData(
      recentStamps: stamps,
      recentLetters: letters,
      quota: quota,
    );
  }

  Future<HomeLetterItem> _toLetterItem(
    SentLetter sent,
    Map<String, Stamp> stampById,
  ) async {
    final link = sent.link;
    final status = switch (sent.status) {
      SentStatus.opened => 'Đã mở',
      SentStatus.expired => 'Hết hạn',
      SentStatus.pending => 'Đang chờ mở',
    };
    // Title from the letter body, picture from its first attached stamp — both
    // from the local cache, so the card shows what the letter is instead of
    // "Thư gửi qua …" with a generic envelope (SM-004 F01-S16).
    final meta = await _letters.cachedMeta(link.letterId);
    final stampId = (meta?.stampIds.isNotEmpty ?? false)
        ? meta!.stampIds.first
        : null;
    final stamp = stampId == null ? null : stampById[stampId];
    final content = meta?.content;
    final title = letterCardTitle(content);
    final date = _formatDate(link.createdAt.toLocal());
    final recipient = content?.recipient.trim() ?? '';
    return HomeLetterItem(
      id: link.id,
      letterId: link.letterId,
      title: title,
      // "Gửi đến <người nhận> · ngày" when the sender named one, else status.
      meta: recipient.isNotEmpty
          ? 'Gửi đến $recipient · $date'
          : '$status · $date',
      opened: sent.status == SentStatus.opened,
      icon: letterOccasionEmoji('$title ${content?.text ?? ''}'),
      stampImageUrl: stamp?.thumbUrl ?? stamp?.imageUrl,
    );
  }

  String _formatDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}
