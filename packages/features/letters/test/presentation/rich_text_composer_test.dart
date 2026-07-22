// SM-013 rich text, driven through the real composer UI:
//   • BR-02 / AC-02 — bold, italic and alignment apply to the selection.
//   • BR-09 / AC-09 — ink applies only to the selected run; other paragraphs
//     keep their own color.
//   • BR-04 / AC-04 — the 500-char limit still holds on a rich body.
//   • SM-015 BR-01 — the preview renders the same Delta, read-only.
// Formatting is applied by tapping the composer's own toolbar, so these assert
// the wiring end-to-end rather than the controller in isolation.
import 'package:app_ui/app_ui.dart';
import 'package:architecture/architecture.dart';
import 'package:feature_letters/feature_letters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

class _FakeLetters implements LettersRepository {
  @override
  Future<Result<Letter>> create(LetterInput input) async => Ok(
    Letter(
      id: 'L1',
      content: input.content,
      stampIds: input.stampIds,
      createdAt: DateTime(2026, 7, 17),
    ),
  );

  @override
  Future<Result<LetterLink>> createLink(
    String letterId, {
    String? platform,
  }) async => Ok(
    LetterLink(
      id: 'tok',
      letterId: letterId,
      platform: platform,
      createdAt: DateTime(2026, 7, 17),
      expiresAt: DateTime(2026, 7, 24),
    ),
  );

  @override
  Future<Result<List<SentLetter>>> sent() async => const Ok([]);

  @override
  Future<LetterContent?> cachedContent(String letterId) async => null;

  @override
  Future<CachedLetter?> cachedMeta(String letterId) async => null;
}

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('vi'),
  home: child,
);

/// The live editor controller — the composer owns it, so reach it through the
/// widget the user is actually typing into.
QuillController _editorController(WidgetTester tester) =>
    tester.widget<QuillEditor>(find.byType(QuillEditor)).controller;

/// Types [text] into the editor and selects [base]..[extent] — i.e. what the
/// user has "bôi đen" before pressing a format button.
Future<QuillController> _writeAndSelect(
  WidgetTester tester,
  String text, {
  required int base,
  required int extent,
}) async {
  final controller = _editorController(tester)..document.insert(0, text);
  await tester.pump();
  controller.updateSelection(
    TextSelection(baseOffset: base, extentOffset: extent),
    ChangeSource.local,
  );
  await tester.pump();
  return controller;
}

/// The op carrying [text] in the draft's persisted body. Matches on `contains`
/// because Quill merges the paragraph's closing newline into the last text op.
Map<String, dynamic> _opWith(ComposerCubit cubit, String text) =>
    cubit.state.content.delta!.firstWhere(
      (op) => (op['insert'] as String).contains(text),
    );

Map<String, dynamic>? _attrs(Map<String, dynamic> op) =>
    op['attributes'] as Map<String, dynamic>?;

void main() {
  late ComposerCubit cubit;

  Future<void> pumpComposer(WidgetTester tester) async {
    // A phone-sized surface (the .pen frames are 393 wide) so the sheet lays
    // out as designed rather than in the 800×600 test default.
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    cubit = ComposerCubit(_FakeLetters(), templateId: 'classic');
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _wrap(
        BlocProvider.value(
          value: cubit,
          child: ComposerScreen(onBack: () {}, onNext: () {}),
        ),
      ),
    );
  }

  group('SM-013 BR-02 — formatting applies to the selection', () {
    testWidgets('AC-02: bold applies to the selected run only', (tester) async {
      await pumpComposer(tester);
      await _writeAndSelect(tester, 'Xin chào bạn', base: 0, extent: 8);

      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      expect(_attrs(_opWith(cubit, 'Xin chào'))?['bold'], isTrue);
      // The text outside the selection is untouched.
      expect(_attrs(_opWith(cubit, ' bạn'))?['bold'], isNull);
    });

    testWidgets('bold toggles back off', (tester) async {
      await pumpComposer(tester);
      await _writeAndSelect(tester, 'Xin chào bạn', base: 0, extent: 8);

      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      expect(_attrs(_opWith(cubit, 'Xin chào bạn'))?['bold'], isNull);
    });

    testWidgets('italic applies to the selected run only', (tester) async {
      await pumpComposer(tester);
      await _writeAndSelect(tester, 'Xin chào bạn', base: 0, extent: 8);

      await tester.tap(find.byIcon(Icons.format_italic));
      await tester.pump();

      expect(_attrs(_opWith(cubit, 'Xin chào'))?['italic'], isTrue);
      expect(_attrs(_opWith(cubit, ' bạn'))?['italic'], isNull);
    });

    testWidgets('alignment applies to the selected paragraph', (tester) async {
      await pumpComposer(tester);
      await _writeAndSelect(tester, 'Đoạn một\nĐoạn hai', base: 0, extent: 4);

      await tester.tap(find.text('Căn lề'));
      await tester.pump();
      await tester.tap(find.text('Giữa'));
      await tester.pump();

      // `align` is a block attribute: it lands on the newline closing the
      // selected paragraph, and the second paragraph keeps the default.
      final ops = cubit.state.content.delta!;
      expect(_attrs(ops[1])?['align'], 'center');
      expect(
        ops.where((op) => _attrs(op)?['align'] != null).length,
        1,
        reason: 'only the selected paragraph is centered',
      );
    });

    testWidgets('left alignment is stored as no attribute, keeping the Delta '
        'at the viewer default', (tester) async {
      await pumpComposer(tester);
      await _writeAndSelect(tester, 'Đoạn một', base: 0, extent: 4);

      await tester.tap(find.text('Căn lề'));
      await tester.pump();
      await tester.tap(find.text('Giữa'));
      await tester.pump();
      await tester.tap(find.text('Trái'));
      await tester.pump();

      final ops = cubit.state.content.delta!;
      expect(ops.every((op) => _attrs(op)?['align'] == null), isTrue);
    });
  });

  group('SM-013 BR-09 — ink per selection', () {
    testWidgets('AC-09: coloring one paragraph leaves the other unchanged', (
      tester,
    ) async {
      await pumpComposer(tester);
      await _writeAndSelect(tester, 'Đoạn một\nĐoạn hai', base: 0, extent: 8);

      await tester.tap(find.text('Màu chữ'));
      await tester.pump();
      await tester.tap(find.byKey(letterInkSwatchKey(0xFFF35B43)));
      await tester.pump();

      expect(_attrs(_opWith(cubit, 'Đoạn một'))?['color'], '#F35B43');
      // The paragraph the user did not select keeps the default ink.
      final untouched = cubit.state.content.delta!.where(
        (op) => (op['insert'] as String).contains('Đoạn hai'),
      );
      expect(untouched, isNotEmpty);
      expect(untouched.every((op) => _attrs(op)?['color'] == null), isTrue);
    });

    testWidgets('two paragraphs can hold different inks at once', (
      tester,
    ) async {
      await pumpComposer(tester);
      final controller = await _writeAndSelect(
        tester,
        'Đoạn một\nĐoạn hai',
        base: 0,
        extent: 8,
      );

      await tester.tap(find.text('Màu chữ'));
      await tester.pump();
      await tester.tap(find.byKey(letterInkSwatchKey(0xFFF35B43)));
      await tester.pump();

      controller.updateSelection(
        const TextSelection(baseOffset: 9, extentOffset: 17),
        ChangeSource.local,
      );
      await tester.pump();
      await tester.tap(find.byKey(letterInkSwatchKey(0xFF2F6FB5)));
      await tester.pump();

      expect(_attrs(_opWith(cubit, 'Đoạn một'))?['color'], '#F35B43');
      expect(_attrs(_opWith(cubit, 'Đoạn hai'))?['color'], '#2F6FB5');
    });

    testWidgets('picking the default ink clears the color attribute', (
      tester,
    ) async {
      await pumpComposer(tester);
      await _writeAndSelect(tester, 'Đoạn một', base: 0, extent: 8);

      await tester.tap(find.text('Màu chữ'));
      await tester.pump();
      await tester.tap(find.byKey(letterInkSwatchKey(0xFFF35B43)));
      await tester.pump();
      await tester.tap(find.byKey(letterInkSwatchKey(letterDefaultInk)));
      await tester.pump();

      expect(_attrs(_opWith(cubit, 'Đoạn một'))?['color'], isNull);
    });
  });

  group('SM-013 BR-04 — the limit still holds on a rich body', () {
    testWidgets('AC-04: text past 500 characters is refused', (tester) async {
      await pumpComposer(tester);
      final controller = _editorController(tester)
        ..document.insert(0, 'a' * 600);
      await tester.pump();

      // `document.length` counts the closing newline.
      expect(controller.document.length - 1, letterCharLimit);
      expect(cubit.state.charCount, letterCharLimit);
      expect(cubit.state.content.text.length, letterCharLimit);
    });

    testWidgets('formatting does not consume characters', (tester) async {
      await pumpComposer(tester);
      await _writeAndSelect(tester, 'Xin chào bạn', base: 0, extent: 8);

      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      expect(cubit.state.charCount, 'Xin chào bạn'.length);
    });
  });

  // The rich-text upgrade moved the body from a TextField to Quill, so the
  // whole-letter styling rules must be re-proven through the new render path.
  group('SM-013 — the whole-letter rules still hold', () {
    testWidgets('AC-05: a font applies to the whole body, not the selection', (
      tester,
    ) async {
      await pumpComposer(tester);
      await _writeAndSelect(tester, 'Xin chào bạn', base: 0, extent: 4);

      await tester.tap(find.text('Playfair'));
      await tester.pump();

      expect(cubit.state.content.fontFamily, 'Playfair Display');
      // The font is locked in through the editor's styles (google_fonts appends
      // a variant suffix to the family name, e.g. "Playfair Display_regular").
      final editor = tester.widget<QuillEditor>(find.byType(QuillEditor));
      expect(
        editor.config.customStyles?.paragraph?.style.fontFamily,
        contains('Playfair'),
      );
      // …not written per-run, so it cannot end up applying to the selection
      // only (BR-03: "toàn bộ nội dung đổi phông ngay").
      expect(
        cubit.state.content.delta!.every((op) => _attrs(op)?['font'] == null),
        isTrue,
      );
    });

    testWidgets('AC-06: the paper color changes without touching the body', (
      tester,
    ) async {
      await pumpComposer(tester);
      await _writeAndSelect(tester, 'Xin chào', base: 0, extent: 4);
      final before = cubit.state.content.delta;

      // Paper swatches live on the "Giấy nền" tab (F03-S05).
      await tester.tap(find.text('Giấy nền'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Giấy A4'));
      await tester.pump();

      expect(cubit.state.content.paperColor, 0xFFFBFBF8);
      expect(cubit.state.content.delta, before);
      expect(cubit.state.content.text, 'Xin chào');
    });

    testWidgets('BR-08: ruling keeps the body and its formatting', (
      tester,
    ) async {
      await pumpComposer(tester);
      await _writeAndSelect(tester, 'Xin chào bạn', base: 0, extent: 8);
      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      // The ruling toggle lives on the "Giấy nền" tab (F03-S05).
      await tester.tap(find.text('Giấy nền'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.notes));
      await tester.pump();

      expect(cubit.state.content.ruled, isTrue);
      expect(_attrs(_opWith(cubit, 'Xin chào'))?['bold'], isTrue);
      expect(cubit.state.content.text, 'Xin chào bạn');
    });
  });

  group('SM-015 BR-01 — preview renders the same body, read-only', () {
    testWidgets('a rich body renders and cannot be edited', (tester) async {
      const content = LetterContent(
        templateId: 'classic',
        text: 'Xin chào bạn',
        delta: [
          {'insert': 'Xin chào'},
          {
            'insert': ' bạn',
            'attributes': {'bold': true, 'color': '#F35B43'},
          },
          {'insert': '\n'},
        ],
      );

      await tester.pumpWidget(
        _wrap(
          LetterPreviewScreen(content: content, onEdit: () {}, onSend: () {}),
        ),
      );
      await tester.pump();

      final controller = _editorController(tester);
      expect(controller.readOnly, isTrue);
      expect(controller.document.toPlainText().trim(), 'Xin chào bạn');
      // The formatting survived the trip through content_json's shape.
      expect(
        controller.document.toDelta().toJson()[1]['attributes'],
        containsPair('bold', true),
      );
    });

    testWidgets('a letter with no delta (written before rich text) still '
        'renders its text', (tester) async {
      final content = LetterContent.decode(
        '{"template_id":"classic","text":"thư cũ"}',
      );

      await tester.pumpWidget(
        _wrap(
          LetterPreviewScreen(content: content, onEdit: () {}, onSend: () {}),
        ),
      );
      await tester.pump();

      expect(_editorController(tester).document.toPlainText().trim(), 'thư cũ');
    });
  });
}
