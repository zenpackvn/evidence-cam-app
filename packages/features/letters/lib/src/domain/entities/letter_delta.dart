/// The rich-text body of a letter, expressed as Quill Delta ops (SM-013
/// BR-02 bold/italic/align, BR-09 per-selection color).
///
/// This lives in the domain and stays **pure Dart on purpose**: the ops list is
/// the app ↔ web-viewer contract (`content_json`, D1.5 renderer parity), so its
/// shape is business vocabulary, not an editor detail. `flutter_quill` consumes
/// this shape (`Document.fromJson`) but nothing here depends on the editor.
///
/// Shape (the standard Delta document form):
/// ```json
/// [ {"insert": "Gửi bạn"},
///   {"insert": " thân mến", "attributes": {"bold": true, "color": "#F35B43"}},
///   {"insert": "\n", "attributes": {"align": "center"}} ]
/// ```
/// Inline attributes (`bold`/`italic`/`color`) ride on the text op; block
/// attributes (`align`) ride on the newline that closes the paragraph. Colors
/// use `#RRGGBB` — what Quill parses and what CSS takes verbatim, so the web
/// viewer needs no translation table.
library;

/// A Delta document: an ordered list of insert ops.
typedef DeltaOps = List<Map<String, dynamic>>;

/// Max characters in a letter body (SM-013 BR-04). Counts the plain text, so
/// formatting never costs the user characters.
const letterCharLimit = 500;

/// A Delta document must end with a newline — Quill's `Document.fromJson`
/// rejects one that does not.
DeltaOps _withTrailingNewline(DeltaOps ops) {
  if (ops.isEmpty) return [_op('\n')];
  final last = ops.last['insert'];
  if (last is String && last.endsWith('\n')) return ops;
  return [...ops, _op('\n')];
}

Map<String, dynamic> _op(String insert) => {'insert': insert};

/// Builds a Delta from unformatted text — used for letters written before rich
/// text existed, so an old `content_json` still opens in the editor.
DeltaOps deltaFromPlainText(String text) =>
    _withTrailingNewline(text.isEmpty ? [] : [_op(text)]);

/// The plain-text projection of [ops]: what the character limit counts, and
/// what a letter persists in its `text` field as the fallback for readers that
/// cannot render Delta. The document's closing newline is not part of the
/// letter's text.
String plainTextFromDelta(DeltaOps ops) {
  final buffer = StringBuffer();
  for (final op in ops) {
    final insert = op['insert'];
    if (insert is String) buffer.write(insert);
  }
  final text = buffer.toString();
  return text.endsWith('\n') ? text.substring(0, text.length - 1) : text;
}

/// Truncates [ops] to [limit] plain-text characters, keeping the formatting of
/// what survives (SM-013 BR-04). The editor already blocks typing past the
/// limit; this is the guard for content arriving any other way (paste, a
/// letter decoded from an older/looser writer).
DeltaOps clipDelta(DeltaOps ops, int limit) {
  if (plainTextFromDelta(ops).length <= limit) return ops;

  final clipped = <Map<String, dynamic>>[];
  var count = 0;
  for (final op in ops) {
    final insert = op['insert'];
    if (insert is! String) continue;
    final room = limit - count;
    if (room <= 0) break;
    final kept = insert.length <= room ? insert : insert.substring(0, room);
    count += kept.length;
    clipped.add({...op, 'insert': kept});
  }
  return _withTrailingNewline(clipped);
}

/// Reads the `delta` field of a `content_json`, returning null when it is
/// absent or malformed so the caller falls back to the plain `text`. A letter
/// must never fail to open because its formatting is unreadable.
DeltaOps? deltaFromJson(Object? raw) {
  if (raw is! List || raw.isEmpty) return null;
  final ops = <Map<String, dynamic>>[];
  for (final op in raw) {
    // Insert-only: a letter body is a document, never a change set.
    if (op is! Map || op['insert'] == null) return null;
    ops.add(Map<String, dynamic>.from(op));
  }
  return _withTrailingNewline(ops);
}
