// Widget coverage for the SOẠN THƯ gaps closed during converge:
//   • SM-012 BR-04/AC-02..03/AC-07 — template list opens the full preview
//     first; a locked Premium card previews then shows the upgrade CTA.
//   • SM-013 BR-08/AC-07..08 — the "Kẻ dòng" toggle in the composer editor.
//   • SM-014 AC-02 — picking a 4th stamp is blocked with a limit message.
import 'package:app_ui/app_ui.dart';
import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:feature_letters/feature_letters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
}

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('vi'),
  home: child,
);

Stamp _stamp(String id) => Stamp(
  id: id,
  imageUrl: 'https://example.test/$id.png',
  source: StampSource.created,
  createdAt: DateTime(2026, 7, 17),
);

void main() {
  // ── SM-012 · template list → preview ───────────────────────────────────────
  group(
    'TemplateListScreen preview flow (SM-012 BR-03/BR-04/AC-02..03/AC-07)',
    () {
      testWidgets('tapping a Free card opens the full preview with a use CTA', (
        tester,
      ) async {
        LetterTemplate? picked;
        await tester.pumpWidget(
          _wrap(TemplateListScreen(onPick: (t) => picked = t)),
        );

        // "Cổ điển" (classic) is a Free template. The card shows no visible
        // label (pure art per the .pen), so locate it by its key.
        await tester.tap(find.byKey(const ValueKey('template-classic')));
        await tester.pumpAndSettle();

        // AC-02: full preview screen is shown with the Free CTA, not the upgrade.
        expect(find.text('Xem trước template'), findsOneWidget);
        expect(find.text('Dùng template này'), findsOneWidget);
        expect(find.text('Nâng cấp Premium'), findsNothing);

        // AC-04: confirming picks the template.
        await tester.tap(find.text('Dùng template này'));
        await tester.pumpAndSettle();
        expect(picked?.id, 'classic');
      });

      testWidgets(
        'every template is Free — tapping opens the preview with the use CTA, '
        'no upgrade (D15 revised)',
        (tester) async {
          LetterTemplate? picked;
          var upgraded = false;
          await tester.pumpWidget(
            _wrap(
              TemplateListScreen(
                onPick: (t) => picked = t,
                onUpgrade: () => upgraded = true,
              ),
            ),
          );

          // A formerly-Premium template (birthday) is now Free.
          final birthday = find.byKey(const ValueKey('template-birthday'));
          await tester.dragUntilVisible(
            birthday,
            find.byType(GridView),
            const Offset(0, -220),
          );
          await tester.pumpAndSettle();
          await tester.tap(birthday);
          await tester.pumpAndSettle();

          expect(find.text('Xem trước template'), findsOneWidget);
          // The free use CTA shows; no upgrade CTA anywhere.
          expect(find.text('Dùng template này'), findsOneWidget);
          expect(find.text('Nâng cấp Premium'), findsNothing);

          await tester.tap(find.text('Dùng template này'));
          await tester.pumpAndSettle();
          expect(picked?.id, 'birthday');
          expect(upgraded, isFalse);
        },
      );

      testWidgets('a Premium user can use a Premium template directly', (
        tester,
      ) async {
        LetterTemplate? picked;
        await tester.pumpWidget(
          _wrap(
            TemplateListScreen(isPremium: true, onPick: (t) => picked = t),
          ),
        );

        final birthday = find.byKey(const ValueKey('template-birthday'));
        await tester.dragUntilVisible(
          birthday,
          find.byType(GridView),
          const Offset(0, -220),
        );
        await tester.pumpAndSettle();
        await tester.tap(birthday);
        await tester.pumpAndSettle();
        expect(find.text('Dùng template này'), findsOneWidget);

        await tester.tap(find.text('Dùng template này'));
        await tester.pumpAndSettle();
        expect(picked?.id, 'birthday');
      });
    },
  );

  // ── SM-013 · kẻ dòng ───────────────────────────────────────────────────────
  group('ComposerEditorPanel ruling toggle (SM-013 BR-08/AC-07..08)', () {
    testWidgets('toggling "Kẻ dòng" drives the cubit and paints/removes lines', (
      tester,
    ) async {
      final cubit = ComposerCubit(_FakeLetters(), templateId: 'classic');
      addTearDown(cubit.close);

      await tester.pumpWidget(
        _wrap(
          BlocProvider.value(
            value: cubit,
            child: ComposerScreen(onBack: () {}, onNext: () {}),
          ),
        ),
      );

      // Default: plain paper, no ruling painter.
      expect(cubit.state.content.ruled, isFalse);

      // AC-07: turn ruling on (tap the "Kẻ dòng" segment via its unique icon —
      // the section header shares the same label text).
      await tester.tap(find.byIcon(Icons.notes));
      await tester.pump();
      expect(cubit.state.content.ruled, isTrue);

      // AC-08: turn ruling off again.
      await tester.tap(find.byIcon(Icons.crop_portrait));
      await tester.pump();
      expect(cubit.state.content.ruled, isFalse);
    });
  });

  // ── SM-014 · giới hạn 3 tem ─────────────────────────────────────────────────
  group('AttachStampsScreen stamp limit (SM-014 AC-02)', () {
    testWidgets('picking a 4th stamp is blocked and shows the limit message', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cubit = ComposerCubit(_FakeLetters(), templateId: 'classic');
      addTearDown(cubit.close);
      final stamps = [for (var i = 1; i <= 4; i++) _stamp('s$i')];

      await tester.pumpWidget(
        _wrap(
          BlocProvider.value(
            value: cubit,
            child: AttachStampsScreen(
              stamps: stamps,
              onBack: () {},
              onDone: () {},
            ),
          ),
        ),
      );

      // Attach the max of 3.
      ['s1', 's2', 's3'].forEach(cubit.toggleStamp);
      await tester.pump();
      expect(cubit.state.stampIds.length, LetterInput.maxStamps);

      // Tapping the 4th (unselected) stamp is refused with a message (AC-02).
      final fourth = find.byKey(const ValueKey('stamp-pick-s4'));
      await tester.ensureVisible(fourth);
      await tester.pump();
      await tester.tap(fourth, warnIfMissed: false);
      await tester.pump(); // let the SnackBar appear
      expect(cubit.state.stampIds.length, LetterInput.maxStamps);
      expect(find.textContaining('tối đa'), findsOneWidget);

      // Flush the SnackBar's auto-dismiss timer so no timer outlives the tree.
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
