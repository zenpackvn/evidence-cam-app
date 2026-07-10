import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A row of [length] single-digit boxes for entering a numeric verification
/// code. Advances focus as the user types, backspaces to the previous box on
/// delete, and reports the assembled code via [onChanged] / [onCompleted].
///
/// Purely presentational: the parent owns the code value and decides what a
/// completed code means (verify email, reset password, …).
class OtpInput extends StatefulWidget {
  const OtpInput({
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.hasError = false,
    super.key,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  /// Paints every box with the error outline (e.g. an invalid code).
  final bool hasError;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // A paste landed in one box — distribute it across the remaining boxes.
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final next = digits.length.clamp(0, widget.length - 1);
      _nodes[next].requestFocus();
    } else if (value.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    }
    final code = _code;
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  KeyEventResult _onKey(int index, FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _nodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      widget.onChanged?.call(_code);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < widget.length; i++)
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                right: i == widget.length - 1 ? 0 : AppSpacing.sm,
              ),
              child: Focus(
                onKeyEvent: (node, event) => _onKey(i, node, event),
                child: AspectRatio(
                  aspectRatio: 0.82,
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _nodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: i == 0 ? widget.length : 1,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: context.textTheme.displaySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                      contentPadding: EdgeInsets.zero,
                      border: _border(colorScheme.outlineVariant),
                      enabledBorder: _border(
                        widget.hasError
                            ? colorScheme.error
                            : colorScheme.outlineVariant,
                      ),
                      focusedBorder: _border(colorScheme.primary, width: 2),
                    ),
                    onChanged: (value) => _onChanged(i, value),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
