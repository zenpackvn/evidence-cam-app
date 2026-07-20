import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'editor_tab_item.dart';

/// The inline-formatting row of the composer sheet (.pen F03-S04 `tab-In đậm` /
/// `tab-Nghiêng` / `tab-Gạch chân`): toggles that apply to the current
/// selection (SM-013 BR-02, AC-02).
///
/// Deliberately not `QuillSimpleToolbar` — the design owns this row's look, so
/// it is built from the .pen tab item and drives the controller directly.
///
/// Each toggle reflects the selection it would act on, so it rebuilds with the
/// controller (selection and style both notify it).
class LetterFormatBar extends StatelessWidget {
  const LetterFormatBar({required this.controller, super.key});

  final QuillController controller;

  void _toggle(
    Attribute<Object?> attribute,
    Map<String, Attribute<Object?>> active,
  ) {
    final isOn = active.containsKey(attribute.key);
    controller.formatSelection(
      isOn ? Attribute.clone(attribute, null) : attribute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final active = controller.getSelectionStyle().attributes;
        return Row(
          children: [
            EditorTabItem(
              icon: Icons.format_bold,
              label: 'In đậm',
              active: active.containsKey(Attribute.bold.key),
              onTap: () => _toggle(Attribute.bold, active),
            ),
            EditorTabItem(
              icon: Icons.format_italic,
              label: 'Nghiêng',
              active: active.containsKey(Attribute.italic.key),
              onTap: () => _toggle(Attribute.italic, active),
            ),
            EditorTabItem(
              icon: Icons.format_underlined,
              label: 'Gạch chân',
              active: active.containsKey(Attribute.underline.key),
              onTap: () => _toggle(Attribute.underline, active),
            ),
          ],
        );
      },
    );
  }
}
