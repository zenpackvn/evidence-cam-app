# AppTextArea

Multiline input with optional character count.

## File

`lib/src/core/widgets/common/app_text_area.dart`

```dart
import 'package:flutter/material.dart';

class AppTextArea extends StatelessWidget {
  const AppTextArea({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.validator,
    this.onChanged,
    this.maxLength,
    this.minLines = 3,
    this.maxLines = 6,
    this.showCounter = true,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final int minLines;
  final int maxLines;
  final bool showCounter;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUnfocus,
      buildCounter: showCounter
          ? null
          : (context, {required currentLength, required isFocused, maxLength}) =>
              null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        alignLabelWithHint: true,
      ),
    );
  }
}
```

## Rules

- Use `AppTextArea` instead of raw `TextFormField(maxLines: >1, ...)`.
- Always validates with `AutovalidateMode.onUnfocus`.
