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

    // A decorative frame in the template's accent colour — a soft mat + a
    // keyline — so the letter "wears" its chosen template (F03 fc1776).
    final accent = Color(templateAccentColor(template.id));
    return Container(
      constraints: const BoxConstraints(minHeight: 420),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: accent.withValues(alpha: 0.55), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1424211F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: paper,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            // The editor needs FlutterQuillLocalizations. The app shell does
            // not register the delegate (and letters cannot reach into it), so
            // the feature supplies it here — merged over the app's own.
            child: Localizations.override(
              context: context,
              delegates: const [FlutterQuillLocalizations.delegate],
              // SM-013 BR-08: the rules are a decorative background painted
              // behind the text, so they never block input.
              child: content.ruled
                  ? CustomPaint(
                      painter: _RuledLinesPainter(
                        color: const Color(
                          letterDefaultInk,
                        ).withValues(alpha: 0.12),
                        lineHeight: _fontSize * _lineHeight,
                      ),
                      child: editor,
                    )
                  : editor,
            ),
          ),
          // Template decorations (e.g. 🎂🎈 for a birthday) in the corners —
          // the written content is unchanged, these just dress the frame.
          ..._templateDecorations(templateIcons(content.templateId)),
        ],
      ),
    );
  }

  List<Widget> _templateDecorations(List<String> icons) {
    if (icons.isEmpty) return const [];
    String at(int i) => icons[i % icons.length];
    Widget deco(String e, double size) =>
        Text(e, style: TextStyle(fontSize: size));
    // Decorations scattered around the whole border (corners + edge midpoints),
    // hanging just off the frame — like the fc1776 demo. They ride the frame,
    // so they spread out as the letter grows.
    return [
      Positioned(top: -16, left: -6, child: deco(at(0), 28)),
      Positioned(
        top: -20,
        left: 0,
        right: 0,
        child: Center(child: deco(at(1), 26)),
      ),
      Positioned(top: -16, right: -6, child: deco(at(2), 28)),
      Positioned(
        top: 0,
        bottom: 0,
        right: -14,
        child: Center(child: deco(at(3), 26)),
      ),
      Positioned(bottom: -14, right: -4, child: deco(at(0), 26)),
      Positioned(
        bottom: -18,
        left: 0,
        right: 0,
        child: Center(child: deco(at(2), 26)),
      ),
      Positioned(bottom: -14, left: -4, child: deco(at(1), 26)),
      Positioned(
        top: 0,
        bottom: 0,
        left: -14,
        child: Center(child: deco(at(3), 26)),
      ),
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
