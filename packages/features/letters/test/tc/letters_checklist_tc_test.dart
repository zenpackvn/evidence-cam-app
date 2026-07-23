// Unit/widget coverage for `product-spec/010..014` test-cases (template list,
// composing, attaching stamps, preview, sending). TC ids in test names map to
// the docs; full journeys remain E2E per the docs' classification.
import 'package:architecture/architecture.dart';
import 'package:feature_letters/feature_letters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

class _FakeLetters implements LettersRepository {
  _FakeLetters({this.failCreate = false, this.failLink = false});

  @override
  Future<void> clearLocalCache() async {}

  @override
  Future<Result<List<Letter>>> letters() async => const Ok([]);

  final bool failCreate;
  final bool failLink;
  String? lastPlatform;

  @override
  Future<Result<Letter>> create(LetterInput input) async {
    if (failCreate) return const Err(UnknownFailure());
    return Ok(
      Letter(
        id: 'L1',
        content: input.content,
        stampIds: input.stampIds,
        createdAt: DateTime(2026, 7, 12),
      ),
    );
  }

  @override
  Future<Result<LetterLink>> createLink(
    String letterId, {
    String? platform,
  }) async {
    lastPlatform = platform;
    if (failLink) return const Err(UnknownFailure());
    return Ok(
      LetterLink(
        id: 'tok123',
        letterId: letterId,
        platform: platform,
        createdAt: DateTime(2026, 7, 12),
        expiresAt: DateTime(2026, 7, 19),
      ),
    );
  }

  @override
  Future<Result<List<SentLetter>>> sent() async => const Ok([]);

  @override
  Future<LetterContent?> cachedContent(String letterId) async => null;

  @override
  Future<CachedLetter?> cachedMeta(String letterId) async => null;
}

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('vi'),
  home: child,
);

void main() {
  // ── 010 · chọn template ──────────────────────────────────────────────────
  group('Template catalog (TC-10-001..)', () {
    test('TC-10-001: có template Free dùng được (F03-S01)', () {
      expect(letterTemplates, isNotEmpty);
      expect(letterTemplates.any((t) => !t.premium), isTrue);
    });

    test('TC-10-004: có mục Premium (F03-S01 secPrem)', () {
      expect(letterTemplates.where((t) => t.premium), isNotEmpty);
    });

    test('templateById rơi về classic khi id lạ (chống crash sent-box)', () {
      expect(templateById('does-not-exist').id, 'classic');
    });
  });

  // ── 011 · soạn nội dung ──────────────────────────────────────────────────
  group('ComposerCubit editing (TC-11-005..010)', () {
    test('TC-11-006: không thể nhập quá giới hạn 500 ký tự', () {
      final cubit = ComposerCubit(_FakeLetters());
      cubit.setText('a' * 600);
      expect(cubit.state.charCount, letterCharLimit);
      expect(cubit.state.content.text.length, 500);
    });

    test('TC-11-005: charCount phản ánh đúng để UI cảnh báo gần giới hạn', () {
      final cubit = ComposerCubit(_FakeLetters());
      cubit.setText('a' * 490);
      expect(cubit.state.charCount, 490);
    });

    test(
      'TC-11-007/008: đổi font áp cho toàn bộ nội dung (state đổi ngay)',
      () {
        final cubit = ComposerCubit(_FakeLetters());
        cubit.setText('xin chào');
        cubit.selectFont('Pacifico');
        expect(cubit.state.content.fontFamily, 'Pacifico');
        cubit.selectFont('Lora');
        expect(cubit.state.content.fontFamily, 'Lora');
        expect(cubit.state.content.text, 'xin chào');
      },
    );

    test('TC-11-009: đổi màu giấy — nội dung giữ nguyên', () {
      final cubit = ComposerCubit(_FakeLetters());
      cubit.setText('nội dung');
      cubit.selectPaper(0xFFF3E7D3);
      expect(cubit.state.content.paperColor, 0xFFF3E7D3);
      expect(cubit.state.content.text, 'nội dung');
    });

    test('TC-11-010: có ít nhất 5 lựa chọn màu giấy trong catalog', () {
      // Catalog templates carry 6 paper tints; the color tab adds more.
      final papers = letterTemplates.map((t) => t.paperColor).toSet();
      expect(papers.length, greaterThanOrEqualTo(5));
    });
  });

  // ── 012 · đính tem ───────────────────────────────────────────────────────
  group('ComposerCubit stamps (TC-12-001, TC-12-007)', () {
    test('TC-12-001: chọn tem thì đính vào thư; chọn lại thì gỡ', () {
      final cubit = ComposerCubit(_FakeLetters());
      cubit.toggleStamp('s1');
      expect(cubit.state.stampIds, ['s1']);
      cubit.toggleStamp('s1');
      expect(cubit.state.stampIds, isEmpty);
    });

    test('TC-12-007: đính tối đa 3 tem — lần thứ tư bị chặn', () {
      final cubit = ComposerCubit(_FakeLetters());
      ['s1', 's2', 's3', 's4'].forEach(cubit.toggleStamp);
      expect(cubit.state.stampIds, ['s1', 's2', 's3']);
      expect(LetterInput.maxStamps, 3);
    });
  });

  // ── 013 · xem trước thư ──────────────────────────────────────────────────
  group('LetterPreviewScreen (TC-13-xxx)', () {
    testWidgets('hiển thị mẫu thư + tem đã dán + người nhận (F03-S09)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          LetterPreviewScreen(
            content: const LetterContent(
              templateId: 'birthday',
              text: 'Chúc mừng sinh nhật!',
            ),
            stampName: 'Hoa mùa xuân',
            onEdit: () {},
            onSend: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Xem trước thư'), findsOneWidget);
      expect(find.text('Mẫu thư'), findsOneWidget);
      expect(find.text('Chúc mừng sinh nhật'), findsOneWidget);
      expect(find.text('Hoa mùa xuân'), findsOneWidget);
      expect(find.text('Chỉnh sửa'), findsOneWidget);
      expect(find.text('Gửi thư'), findsOneWidget);
    });

    testWidgets(
      'TC-13 empty-warning: thư trống → modal "vẫn gửi/quay lại" (F03-S10)',
      (tester) async {
        var sent = false;
        await tester.pumpWidget(
          _wrap(
            Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () async {
                      sent = await showEmptyLetterWarning(context);
                    },
                    child: const Text('go'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();

        expect(find.text('Thư chưa có nội dung, vẫn gửi?'), findsOneWidget);
        expect(find.text('Vẫn gửi'), findsOneWidget);
        expect(find.text('Quay lại'), findsOneWidget);

        await tester.tap(find.text('Quay lại'));
        await tester.pumpAndSettle();
        expect(sent, isFalse);

        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Vẫn gửi'));
        await tester.pumpAndSettle();
        expect(sent, isTrue);
      },
    );
  });

  // ── 014 · gửi thư ────────────────────────────────────────────────────────
  group('ComposerCubit send (TC-14-001..)', () {
    test(
      'TC-14-001: gửi thành công → phase sent + link 7 ngày + platform',
      () async {
        final repo = _FakeLetters();
        final cubit = ComposerCubit(repo);
        cubit.setText('lá thư đầu tiên');

        await cubit.send(platform: 'messenger');

        expect(cubit.state.phase, ComposerPhase.sent);
        expect(cubit.state.link, isNotNull);
        expect(repo.lastPlatform, 'messenger');
        expect(
          cubit.state.link!.expiresAt.difference(cubit.state.link!.createdAt),
          const Duration(days: 7),
        );
      },
    );

    test('thư trống không gửi được (canSend gate, TC-13 empty)', () async {
      final cubit = ComposerCubit(_FakeLetters());
      expect(cubit.state.canSend, isFalse);
      await cubit.send(platform: 'zalo');
      expect(cubit.state.phase, ComposerPhase.editing);
    });

    test('TC-14 lỗi mint link → phase error (không kẹt sending)', () async {
      final cubit = ComposerCubit(_FakeLetters(failLink: true));
      cubit.setText('x');
      await cubit.send(platform: 'zalo');
      expect(cubit.state.phase, ComposerPhase.error);
    });

    test('TC-14 lỗi tạo thư → phase error', () async {
      final cubit = ComposerCubit(_FakeLetters(failCreate: true));
      cubit.setText('x');
      await cubit.send();
      expect(cubit.state.phase, ComposerPhase.error);
    });
  });

  // ── LetterContent round-trip (nền cho sent-box/nhận thư) ────────────────
  group('LetterContent encode/decode', () {
    test('decode input hỏng rơi về thư classic rỗng, không crash', () {
      final broken = LetterContent.decode('not-json');
      expect(broken.templateId, 'classic');
      expect(broken.text, isEmpty);
      expect(LetterContent.decode('').templateId, 'classic');
    });
  });
}
