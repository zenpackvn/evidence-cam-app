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

  @override
  Widget build(BuildContext context) {
    final template = templateById(widget.content.templateId);
    final paper = Color(widget.content.paperColor ?? template.paperColor);
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
      child: TextField(
        controller: _controller,
        onChanged: widget.onTextChanged,
        maxLines: null,
        maxLength: letterCharLimit,
        buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
            null,
        style: TextStyle(
          fontFamily: widget.content.fontFamily,
          fontSize: 17,
          height: 1.6,
          color: const Color(0xFF3A322C),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Gửi bạn,\n\nViết những dòng thật đẹp...',
          isCollapsed: true,
        ),
      ),
    );
  }
}
