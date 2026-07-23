import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../domain/entities/letter_content.dart';
import '../composer_catalog.dart';
import '../letter_document.dart';

/// The letter "paper" (F03-S04): a tinted, rounded sheet holding the rich body
/// (SM-013 BR-07). The paper color comes from the content (or the template
/// default); the font applies to the whole body (BR-03 / AC-05), while
/// bold/italic/align/color live per-run in the document (BR-02 / BR-09).
///
/// The body is owned by [controller], not by this widget: the composer's
/// toolbar formats the same selection the editor shows, so the controller is
/// created by the screen and shared. Rebuilding here never touches the
/// document, so a paper/font change cannot disturb the caret.
class LetterPaper extends StatelessWidget {
  const LetterPaper({
    required this.content,
    required this.controller,
    this.focusNode,
    super.key,
  });

  final LetterContent content;
  final QuillController controller;
  final FocusNode? focusNode;

  /// Body font size and line-height factor. Locked through [DefaultStyles] so
  /// every font renders on the same pitch and the ruling lines stay aligned
  /// with the text (SM-013 BR-08).
  static const _fontSize = 17.0;
  static const _lineHeight = 1.6;

  @override
  Widget build(BuildContext context) {
    final template = templateById(content.templateId);
    final paper = Color(content.paperColor ?? template.paperColor);

    // Load the selected font through google_fonts so the whole body renders in
    // it (BR-03 / AC-05); a bare fontFamily string wouldn't register the font.
    final bodyStyle = letterFontStyle(
      content.fontFamily,
      const TextStyle(
        fontSize: _fontSize,
        height: _lineHeight,
        color: Color(letterDefaultInk),
      ),
    );
    // Zero every block/line spacing: the rules are painted on a fixed pitch of
    // `_fontSize * _lineHeight`, so any extra paragraph spacing would drift the
    // text off the lines.
    DefaultTextBlockStyle block(TextStyle style) => DefaultTextBlockStyle(
      style,
      HorizontalSpacing.zero,
      VerticalSpacing.zero,
      VerticalSpacing.zero,
      null,
    );

    final editor = QuillEditor.basic(
      controller: controller,
      focusNode: focusNode,
      config: QuillEditorConfig(
        // Single line on purpose: flutter_quill 11.5.1 builds the placeholder
        // document by interpolating this string straight into a JSON literal
        // (`raw_editor_state.dart`), so a newline or quote here throws a
        // FormatException on the first build rather than failing gracefully.
        placeholder: 'Gửi bạn, viết những dòng thật đẹp...',
        padding: EdgeInsets.zero,
        // The composer scrolls the whole paper, so the editor grows instead of
        // scrolling inside itself.
        scrollable: false,
        expands: false,
        customStyles: DefaultStyles(
          paragraph: block(bodyStyle),
          placeHolder: block(
            bodyStyle.copyWith(
              color: const Color(letterDefaultInk).withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );

    // fc1644 look: a plain sheet with the template's decorations scattered
    // around the edges (flowers → 🎂🎈 for a birthday), the written content in
    // the middle, and the top-left kept clear for the stamp the user attaches.
    final body = content.ruled
        ? CustomPaint(
            painter: _RuledLinesPainter(
              color: const Color(letterDefaultInk).withValues(alpha: 0.12),
              lineHeight: _fontSize * _lineHeight,
            ),
            child: editor,
          )
        : editor;
    return Container(
      constraints: const BoxConstraints(minHeight: 420),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1424211F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // The writing area — padded so the corner/edge decorations frame it.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              44,
            ),
            // The editor needs FlutterQuillLocalizations. The app shell does not
            // register the delegate (and letters cannot reach into it), so the
            // feature supplies it here — merged over the app's own.
            child: Localizations.override(
              context: context,
              delegates: const [FlutterQuillLocalizations.delegate],
              child: body,
            ),
          ),
          ..._templateDecorations(templateIcons(content.templateId)),
        ],
      ),
    );
  }

  /// Template decorations scattered around the sheet edges (fc1644): bigger in
  /// the bottom corners, a couple up the sides, the top-left left clear for the
  /// stamp. The written content is unchanged.
  List<Widget> _templateDecorations(List<String> icons) {
    if (icons.isEmpty) return const [];
    String at(int i) => icons[i % icons.length];
    Widget deco(String e, double size, double rot) => Transform.rotate(
      angle: rot,
      child: Text(e, style: TextStyle(fontSize: size)),
    );
    return [
      Positioned(bottom: 6, left: 8, child: deco(at(0), 34, -0.15)),
      Positioned(bottom: 4, right: 10, child: deco(at(1), 32, 0.12)),
      Positioned(bottom: 30, right: 8, child: deco(at(2), 22, -0.1)),
      Positioned(top: 8, right: 8, child: deco(at(3), 26, 0.1)),
      Positioned(top: 96, left: 4, child: deco(at(2), 22, -0.12)),
      Positioned(top: 120, right: 2, child: deco(at(0), 20, 0.1)),
    ];
  }
}

/// A [LetterPaper] that renders a finished letter and cannot be edited
/// (SM-015 BR-01 preview; also the shape any other read-only render needs).
///
/// Owns a read-only controller derived from [content], so callers can render a
/// letter straight from its `content_json` without managing editor state. The
/// controller is rebuilt only when the content object actually changes.
class ReadOnlyLetterPaper extends StatefulWidget {
  const ReadOnlyLetterPaper({required this.content, super.key});

  final LetterContent content;

  @override
  State<ReadOnlyLetterPaper> createState() => _ReadOnlyLetterPaperState();
}

class _ReadOnlyLetterPaperState extends State<ReadOnlyLetterPaper> {
  late QuillController _controller = letterController(
    widget.content,
    readOnly: true,
  );

  @override
  void didUpdateWidget(ReadOnlyLetterPaper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The cubit emits a new content object per edit and reuses it otherwise, so
    // identity is the cheap, exact signal that the body needs re-parsing.
    if (!identical(oldWidget.content, widget.content)) {
      _controller.dispose();
      _controller = letterController(widget.content, readOnly: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LetterPaper(content: widget.content, controller: _controller);
}

/// Paints evenly spaced horizontal rules across the paper body (SM-013 BR-08).
class _RuledLinesPainter extends CustomPainter {
  const _RuledLinesPainter({required this.color, required this.lineHeight});

  final Color color;
  final double lineHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    // Draw under each text baseline row.
    for (var y = lineHeight; y < size.height; y += lineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_RuledLinesPainter old) =>
      old.color != color || old.lineHeight != lineHeight;
}
