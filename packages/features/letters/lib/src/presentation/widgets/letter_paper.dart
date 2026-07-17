import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/letter_content.dart';
import '../composer_catalog.dart';

/// The letter "paper" (F03-S04): a tinted, rounded sheet holding the editable
/// body in the chosen font. The paper color comes from the content (or the
/// template default); the font is applied to the whole body for the MVP.
class LetterPaper extends StatefulWidget {
  const LetterPaper({
    required this.content,
    required this.onTextChanged,
    super.key,
  });

  final LetterContent content;
  final ValueChanged<String> onTextChanged;

  @override
  State<LetterPaper> createState() => _LetterPaperState();
}

class _LetterPaperState extends State<LetterPaper> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.content.text);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Body font size and line-height factor; the ruling lines align to these so
  /// text sits on the lines (SM-013 BR-08).
  static const _fontSize = 17.0;
  static const _lineHeight = 1.6;

  @override
  Widget build(BuildContext context) {
    final template = templateById(widget.content.templateId);
    final paper = Color(widget.content.paperColor ?? template.paperColor);
    final textField = TextField(
      controller: _controller,
      onChanged: widget.onTextChanged,
      maxLines: null,
      maxLength: letterCharLimit,
      buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
          null,
      style: const TextStyle(
        fontSize: _fontSize,
        height: _lineHeight,
        color: Color(0xFF3A322C),
      ).copyWith(fontFamily: widget.content.fontFamily),
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Gửi bạn,\n\nViết những dòng thật đẹp...',
        isCollapsed: true,
      ),
    );
    return Container(
      constraints: const BoxConstraints(minHeight: 420),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1424211F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      // SM-013 BR-08: ruled lines are a decorative background painted behind the
      // text so they never block input; the line pitch matches the text line
      // height so glyphs rest on the rules.
      child: widget.content.ruled
          ? CustomPaint(
              painter: _RuledLinesPainter(
                color: const Color(0xFF3A322C).withValues(alpha: 0.12),
                lineHeight: _fontSize * _lineHeight,
              ),
              child: textField,
            )
          : textField,
    );
  }
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
