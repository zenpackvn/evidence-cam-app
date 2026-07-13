import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:feature_home/feature_home.dart';
import 'package:feature_letter_inbox/feature_letter_inbox.dart';
import 'package:feature_letters/feature_letters.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_contracts/shared_contracts.dart';

/// Composition-root implementation of the home dashboard's [HomeDataLoader]:
/// reads the album (recent stamps), letters (recent sent letters), and inbox
/// (unread count) features. Lives in the app shell so `feature_home` stays
/// free of cross-feature imports (SM-004).
@LazySingleton(as: HomeDataLoader)
class StampMailHomeDataLoader implements HomeDataLoader {
  StampMailHomeDataLoader(this._stamps, this._letters, this._inbox);

  final StampsRepository _stamps;
  final LettersRepository _letters;
  final InboxRepository _inbox;

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

    final unread = switch (await _inbox.unreadCount()) {
      Ok(value: final count) => count,
      Err() => 0,
    };

    return HomeData(
      unreadLetters: unread,
      recentStamps: stamps,
      recentLetters: letters,
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

  String _platformLabel(String platform) => switch (platform) {
    'messenger' => 'Messenger',
    'zalo' => 'Zalo',
    'instagram' => 'Instagram',
    'facebook' => 'Facebook',
    'telegram' => 'Telegram',
    'tiktok' => 'TikTok',
    'x' => 'X',
    '' => 'liên kết',
    _ => platform,
  };

  String _formatDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}
