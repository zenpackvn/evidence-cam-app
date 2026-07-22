import 'dart:convert';

import 'letter_delta.dart';

// The Delta shape and its helpers are part of this contract's public surface:
// anything that renders a letter (preview, inbox, the web viewer's Dart-side
// tests) needs them alongside the entity.
export 'letter_delta.dart';

/// The composed content of a letter — template, body, and styling — serialized
/// to the opaque `content_json` the server stores and passes through (SM-013).
///
/// ## Schema compatibility (this is a contract, not an internal type)
///
/// `content_json` is the app ↔ web-viewer contract (D1.5), so the schema only
/// ever grows. The body is carried **twice, on purpose**:
///
/// * [text] — plain text, always written. The fallback every reader
///   understands: letters written before rich text existed, and the web viewer
///   until it ships the Delta renderer, still show the words.
/// * [delta] — the rich body (bold/italic/align/per-selection color, BR-02 /
///   BR-09), written only when present. Readers that know it render formatting.
///
/// [text] is kept as the plain-text projection of [delta] — see [withBody],
/// the only way to set the body, which enforces that invariant so the two can
/// never drift. Reading is symmetric: a letter with no `delta` yields one
/// derived from its [text] via [richDelta], so old letters open in the rich
/// editor unchanged.
class LetterContent {
  const LetterContent({
    required this.templateId,
    required this.text,
    this.title = '',
    this.recipient = '',
    this.delta,
    this.paperColor,
    this.fontFamily,
    this.ruled = false,
  });

  factory LetterContent.fromJson(Map<String, dynamic> json) => LetterContent(
    templateId: (json['template_id'] as String?) ?? 'classic',
    text: (json['text'] as String?) ?? '',
    title: (json['title'] as String?) ?? '',
    recipient: (json['recipient'] as String?) ?? '',
    // Absent (old letter) or malformed → null, and [richDelta] rebuilds the
    // body from `text` rather than failing to open the letter.
    delta: deltaFromJson(json['delta']),
    paperColor: json['paper_color'] as int?,
    fontFamily: json['font_family'] as String?,
    ruled: (json['ruled'] as bool?) ?? false,
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

  /// A short, user-given title for the letter (e.g. "Chúc mừng sinh nhật"),
  /// shown on the Home "Thư gần đây" card. Empty when the writer left it blank.
  final String title;

  /// Who the letter is for (the name the sender typed at send time), shown as
  /// "Gửi đến …" on the Home card. Empty when not given.
  final String recipient;

  /// The body as plain text — the cross-reader fallback, and what the
  /// character limit counts (BR-04). Always the plain-text projection of
  /// [delta] when one is present.
  final String text;

  /// The body as Quill Delta ops (BR-02 / BR-09), or null for a letter with no
  /// formatting recorded. Prefer [richDelta] when rendering.
  final DeltaOps? delta;

  /// ARGB paper color, if the user picked one.
  final int? paperColor;

  /// Font family token, if the user picked one. Applies to the whole body
  /// (BR-03 / AC-05), so it stays a content field rather than a Delta
  /// attribute.
  final String? fontFamily;

  /// Whether the editor shows horizontal ruled lines (SM-013 BR-08). Persisted
  /// so the recipient sees the same ruling. Defaults to off (plain paper).
  final bool ruled;

  /// The body as Delta ops, always renderable: [delta] when the letter carries
  /// one, otherwise built from the plain [text].
  DeltaOps get richDelta => delta ?? deltaFromPlainText(text);

  /// Replaces the body from a rich [delta], clipping to [letterCharLimit] and
  /// re-deriving [text] so the plain fallback always matches what is rendered.
  LetterContent withBody(DeltaOps delta) {
    final clipped = clipDelta(delta, letterCharLimit);
    return LetterContent(
      templateId: templateId,
      text: plainTextFromDelta(clipped),
      title: title,
      recipient: recipient,
      delta: clipped,
      paperColor: paperColor,
      fontFamily: fontFamily,
      ruled: ruled,
    );
  }

  /// Replaces the body with unformatted [text], dropping any recorded
  /// formatting. Clips to [letterCharLimit] (BR-04).
  LetterContent withPlainBody(String text) {
    final clipped = text.length > letterCharLimit
        ? text.substring(0, letterCharLimit)
        : text;
    return LetterContent(
      templateId: templateId,
      text: clipped,
      title: title,
      recipient: recipient,
      paperColor: paperColor,
      fontFamily: fontFamily,
      ruled: ruled,
    );
  }

  /// Copies non-body fields. The body ([text] / [delta]) is deliberately not
  /// settable here — use [withBody] or [withPlainBody], which keep the two in
  /// sync.
  LetterContent copyWith({
    String? templateId,
    String? title,
    String? recipient,
    int? paperColor,
    String? fontFamily,
    bool? ruled,
  }) => LetterContent(
    templateId: templateId ?? this.templateId,
    text: text,
    title: title ?? this.title,
    recipient: recipient ?? this.recipient,
    delta: delta,
    paperColor: paperColor ?? this.paperColor,
    fontFamily: fontFamily ?? this.fontFamily,
    ruled: ruled ?? this.ruled,
  );

  Map<String, dynamic> toJson() => {
    'template_id': templateId,
    // Always written: the reader that does not know `delta` still gets words.
    'text': text,
    if (title.isNotEmpty) 'title': title,
    if (recipient.isNotEmpty) 'recipient': recipient,
    if (delta != null) 'delta': delta,
    if (paperColor != null) 'paper_color': paperColor,
    if (fontFamily != null) 'font_family': fontFamily,
    if (ruled) 'ruled': true,
  };

  /// Serialized form stored server-side as `content_json`.
  String encode() => jsonEncode(toJson());
}
