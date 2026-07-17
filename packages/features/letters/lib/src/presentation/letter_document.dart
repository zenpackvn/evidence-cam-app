import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../domain/entities/letter_content.dart';

/// Bridges the domain's Delta ops (the `content_json` contract) and the editor's
/// [Document] / [QuillController]. Keeping the conversion here is what lets the
/// domain stay editor-agnostic — nothing outside `presentation/` mentions Quill.

/// Builds the editable document for [content]: its rich body when it has one,
/// otherwise one rebuilt from the plain text (a letter written before rich text
/// existed still opens). A body Quill cannot parse falls back to plain text
/// rather than throwing — a letter must always open.
Document letterDocument(LetterContent content) {
  try {
    return Document.fromJson(content.richDelta);
  } on Object {
    final document = Document();
    if (content.text.isNotEmpty) document.insert(0, content.text);
    return document;
  }
}

/// A controller over [content]'s body. [readOnly] drives the preview and any
/// other non-editing render (SM-015 BR-01).
QuillController letterController(
  LetterContent content, {
  bool readOnly = false,
}) => QuillController(
  document: letterDocument(content),
  selection: const TextSelection.collapsed(offset: 0),
  readOnly: readOnly,
);

/// The document's body as domain Delta ops, ready to persist.
DeltaOps letterDeltaOf(Document document) => document.toDelta().toJson();
