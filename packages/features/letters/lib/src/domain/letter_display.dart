import 'entities/letter_content.dart';

/// Presentation helpers shared by the Home "Thư gần đây" cards and the "Hộp
/// thư" list, so the same letter shows the same title and occasion symbol in
/// both places (SM-004 F01-S16 / SM-021).

/// A theme emoji for a letter's occasion, matched from its words — a birthday
/// letter shows 🎂, a thank-you 💐, and so on.
String letterOccasionEmoji(String text) {
  final t = text.toLowerCase();
  bool has(List<String> keywords) => keywords.any(t.contains);
  if (has(['sinh nhật', 'birthday', 'mừng tuổi', 'hpbd'])) return '🎂';
  if (has(['giáng sinh', 'noel', 'christmas', 'xmas'])) return '🎄';
  if (has(['tết', 'năm mới', 'new year', 'lì xì', 'li xi'])) return '🧧';
  if (has(['cảm ơn', 'biết ơn', 'thank', 'cam on'])) return '💐';
  if (has(['nhớ', 'du lịch', 'chuyến đi', 'trip', 'travel', 'đà lạt'])) {
    return '🌿';
  }
  if (has(['yêu', 'thương', 'love', 'crush', 'valentine'])) return '❤️';
  if (has(['xin lỗi', 'sorry', 'xin loi'])) return '🌷';
  if (has(['chúc mừng', 'congrat', 'mừng', 'chuc mung'])) return '🎉';
  return '💌';
}

/// The card title for a letter: the writer's typed title (SM-013), else the
/// first non-empty line of the body, else a friendly fallback when the body is
/// empty or not cached on this device.
String letterCardTitle(LetterContent? content) {
  final typed = content?.title.trim() ?? '';
  if (typed.isNotEmpty) return typed;
  final text = content?.text.trim() ?? '';
  if (text.isEmpty) return 'Thư của bạn';
  final firstLine = text
      .split('\n')
      .firstWhere((l) => l.trim().isNotEmpty, orElse: () => text)
      .trim();
  return firstLine.length > 40 ? '${firstLine.substring(0, 40)}…' : firstLine;
}
