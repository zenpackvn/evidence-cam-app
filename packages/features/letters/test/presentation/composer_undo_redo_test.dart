// SM-013 — undo / redo in the composer, driven through the real top bar.
//
// The buttons were wired to `onTap: () {}` before, so they looked functional
// and did nothing. These drive the actual UI rather than the controller, which
// is the only way to catch that particular failure.
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

QuillController _editorController(WidgetTester tester) =>
    tester.widget<QuillEditor>(find.byType(QuillEditor)).controller;

/// The undo/redo buttons as the user meets them: an icon in the top bar.
Finder _undo() => find.byIcon(Icons.undo);
Finder _redo() => find.byIcon(Icons.redo);

/// Whether the circle behind [icon] is tappable. The composer disables an
/// action by passing a null `onTap`, which lands on the InkWell.
bool _enabled(WidgetTester tester, Finder icon) {
  final inkWell = find.ancestor(of: icon, matching: find.byType(InkWell));
  return tester.widget<InkWell>(inkWell.first).onTap != null;
}

void main() {
  late ComposerCubit cubit;

  Future<void> pumpComposer(WidgetTester tester) async {
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

  group('SM-013 — undo / redo', () {
    testWidgets('undo removes the last edit from the draft', (tester) async {
      await pumpComposer(tester);
      _editorController(tester).document.insert(0, 'Xin chào');
      await tester.pump();
      expect(cubit.state.content.text, contains('Xin chào'));

      await tester.tap(_undo());
      await tester.pump();

      // The cubit — not just the editor — must reflect the undo, or the letter
      // that gets sent still carries the reverted text.
      expect(cubit.state.content.text, isNot(contains('Xin chào')));
    });

    testWidgets('redo restores what undo removed', (tester) async {
      await pumpComposer(tester);
      _editorController(tester).document.insert(0, 'Xin chào');
      await tester.pump();

      await tester.tap(_undo());
      await tester.pump();
      expect(cubit.state.content.text, isNot(contains('Xin chào')));

      await tester.tap(_redo());
      await tester.pump();
      expect(cubit.state.content.text, contains('Xin chào'));
    });

    testWidgets('both are disabled on a fresh draft', (tester) async {
      await pumpComposer(tester);

      expect(_enabled(tester, _undo()), isFalse);
      expect(_enabled(tester, _redo()), isFalse);
    });

    testWidgets('undo enables after an edit; redo only after an undo', (
      tester,
    ) async {
      await pumpComposer(tester);
      _editorController(tester).document.insert(0, 'Xin chào');
      await tester.pump();

      expect(_enabled(tester, _undo()), isTrue);
      expect(_enabled(tester, _redo()), isFalse);

      await tester.tap(_undo());
      await tester.pump();

      expect(_enabled(tester, _redo()), isTrue);
    });

    // BR-04: the composer trims a paste that overshoots 500 chars. That trim is
    // its own correction, so it must not become an undo step — otherwise the
    // first undo restores the overflow, the composer trims it again, and the
    // button looks dead.
    testWidgets('one undo drops an over-limit paste entirely', (tester) async {
      await pumpComposer(tester);
      final controller = _editorController(tester);

      controller.document.insert(0, 'A' * (letterCharLimit + 200));
      await tester.pump();
      // The trim already happened.
      expect(cubit.state.content.text.length, letterCharLimit);

      await tester.tap(_undo());
      await tester.pump();

      expect(
        cubit.state.content.text,
        isEmpty,
        reason:
            'the trim leaked into the undo history: the first undo restored '
            'the overflow instead of dropping the paste',
      );
    });
  });
}
