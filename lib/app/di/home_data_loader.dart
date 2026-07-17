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
    final stamps = switch (await _stamps.listLocal()) {
      Ok(value: final list) => [
        for (final s in list.take(_maxStamps))
          StampRef(
            id: s.id,
            imageUrl: s.imageUrl,
            thumbUrl: s.thumbUrl,
            createdAt: s.createdAt,
          ),
      ],
      Err() => const <StampRef>[],
    };

    final letters = switch (await _letters.sent()) {
      Ok(value: final list) => [
        for (final sent in list.take(_maxLetters)) _toLetterItem(sent),
      ],
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

  HomeLetterItem _toLetterItem(SentLetter sent) {
    final link = sent.link;
    final status = switch (sent.status) {
      SentStatus.opened => 'Đã mở',
      SentStatus.expired => 'Hết hạn',
      SentStatus.pending => 'Đang chờ mở',
    };
    return HomeLetterItem(
      id: link.id,
      title: 'Thư gửi qua ${_platformLabel(link.platform ?? '')}',
      meta: '$status · ${_formatDate(link.createdAt.toLocal())}',
      opened: sent.status == SentStatus.opened,
    );
  }

  // Labels for the SM-016 BR-04 share platforms (wire values from SharePlatform).
  String _platformLabel(String platform) => switch (platform) {
    'messenger' => 'Messenger',
    'instagram' => 'Instagram',
    'tiktok' => 'TikTok',
    'threads' => 'Threads',
    'zalo' => 'Zalo',
    'whatsapp' => 'WhatsApp',
    'imessage' => 'iMessage',
    'twitter' => 'X',
    '' => 'liên kết',
    _ => platform,
  };

  String _formatDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}
