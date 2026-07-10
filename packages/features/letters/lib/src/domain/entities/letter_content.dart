import 'dart:convert';

/// The composed content of a letter — template, text, and simple styling —
/// serialized to the opaque `content_json` the server stores (SM-013). Kept
/// deliberately small for the P0 slice; richer styling (paper color, ruling,
/// per-paragraph color, stickers) can extend this without a server change.
class LetterContent {
  const LetterContent({
    required this.templateId,
    required this.text,
    this.paperColor,
    this.fontFamily,
  });

  factory LetterContent.fromJson(Map<String, dynamic> json) => LetterContent(
    templateId: (json['template_id'] as String?) ?? 'classic',
    text: (json['text'] as String?) ?? '',
    paperColor: json['paper_color'] as int?,
    fontFamily: json['font_family'] as String?,
  );

  /// Parses the server's `content_json`. Falls back to an empty classic letter
  /// on malformed input so a bad row never crashes the sent box.
  factory LetterContent.decode(String contentJson) {
    if (contentJson.isEmpty) {
      return const LetterContent(templateId: 'classic', text: '');
    }
    try {
      final decoded = jsonDecode(contentJson);
      if (decoded is Map<String, dynamic>) {
        return LetterContent.fromJson(decoded);
      }
    } on FormatException {
      // fall through
    }
    return const LetterContent(templateId: 'classic', text: '');
  }

  final String templateId;
  final String text;

  /// ARGB paper color, if the user picked one.
  final int? paperColor;

  /// Font family token, if the user picked one.
  final String? fontFamily;

  Map<String, dynamic> toJson() => {
    'template_id': templateId,
    'text': text,
    if (paperColor != null) 'paper_color': paperColor,
    if (fontFamily != null) 'font_family': fontFamily,
  };

  /// Serialized form stored server-side as `content_json`.
  String encode() => jsonEncode(toJson());
}
