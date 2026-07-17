import 'package:shared_contracts/shared_contracts.dart';

/// A sent letter as shown on the Home dashboard (F01-S16 letter cards).
class HomeLetterItem {
  const HomeLetterItem({
    required this.id,
    required this.title,
    required this.meta,
    required this.opened,
    this.envelopeImageUrl,
    this.stampImageUrl,
  });

  final String id;

  /// Card title, e.g. the platform the letter was sent through.
  final String title;

  /// Secondary line, e.g. "Đã mở · 20/05/2024".
  final String meta;

  final bool opened;

  /// Envelope thumbnail (58×48 in the card); falls back to an icon when null.
  final String? envelopeImageUrl;

  /// The attached stamp's mini preview (38×42), when the letter has one.
  final String? stampImageUrl;
}

/// Everything the Home dashboard shows (SM-004): the most recent stamps
/// (BR-02) and recent sent letters. No unread count — received letters are
/// never stored (SM-017 BR-10).
class HomeData {
  const HomeData({
    this.recentStamps = const [],
    this.recentLetters = const [],
    this.quota = QuotaRemaining.unlimited,
  });

  static const empty = HomeData();

  final List<StampRef> recentStamps;
  final List<HomeLetterItem> recentLetters;

  /// Remaining monthly quota, for the low-quota nudge (SM-030). Defaults to
  /// unlimited so the banner stays hidden until real data loads / for Premium.
  final QuotaRemaining quota;

  /// First-run state: nothing created yet → show the hero invite (BR-02,
  /// F01-S15).
  bool get isEmpty => recentStamps.isEmpty && recentLetters.isEmpty;
}

/// Loads [HomeData] from the app's feature repositories. Implemented by the
/// composition root (which may read the album / letters / inbox features);
/// the home feature itself stays feature-import-free.
// ignore: one_member_abstracts
abstract class HomeDataLoader {
  Future<HomeData> load();
}
