// Coverage for `product-spec/019-hop-thu-da-gui` (SM-021): the "Thư" tab is
// the sent box only — list of sent links with status, empty state with the
// compose CTA (F04-S07d).
import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:feature_letters/feature_letters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Only [listLocal] is exercised by the cubit; the rest is stubbed away.
class _FakeStamps implements StampsRepository {
  @override
  Future<Result<List<Stamp>>> listLocal() async => const Ok([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLetters implements LettersRepository {
  @override
  Future<void> clearLocalCache() async {}

  Result<List<SentLetter>> sentResult = const Ok([]);
  bool createLinkOk = true;
  final createdLinksFor = <String>[];

  @override
  Future<Result<List<SentLetter>>> sent() async => sentResult;

  @override
  Future<LetterContent?> cachedContent(String letterId) async => null;

  @override
  Future<CachedLetter?> cachedMeta(String letterId) async => null;

  @override
  Future<Result<List<Letter>>> letters() async => const Ok([]);

  @override
  Future<Result<Letter>> create(LetterInput input) async =>
      const Err(UnknownFailure());

  @override
  Future<Result<LetterLink>> createLink(
    String letterId, {
    String? platform,
  }) async {
    createdLinksFor.add(letterId);
    return createLinkOk
        ? Ok(_link(id: 'new', platform: platform))
        : const Err(UnknownFailure());
  }
}

LetterLink _link({
  String id = 'lk1',
  String? platform,
  DateTime? openedAt,
  String? openedBy,
  DateTime? expiresAt,
}) => LetterLink(
  id: id,
  letterId: 'l-$id',
  platform: platform,
  createdAt: DateTime(2026, 7, 10),
  expiresAt: expiresAt ?? DateTime(2026, 7, 17),
  openedBy: openedBy,
  openedAt: openedAt,
);

void main() {
  group('SentLettersCubit (TC-19-xxx)', () {
    test('TC-19: tải danh sách thành công → letters', () async {
      final repo = _FakeLetters()
        ..sentResult = Ok([SentLetter.fromLink(_link())]);
      final cubit = SentLettersCubit(repo, _FakeStamps());
      await cubit.load();
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.letters, hasLength(1));
    });

    test('TC-19 lỗi mạng → trạng thái lỗi, không kẹt loading', () async {
      final repo = _FakeLetters()
        ..sentResult = const Err(UnknownFailure('mất mạng'));
      final cubit = SentLettersCubit(repo, _FakeStamps());
      await cubit.load();
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.letters, isEmpty);
      expect(cubit.state.error, isNotNull);
    });

    test(
      'recreateLink mints a new link for an expired letter (BR-04)',
      () async {
        final expired = SentLetter.fromLink(
          _link(expiresAt: DateTime(2020), openedAt: null),
        );
        final repo = _FakeLetters()..sentResult = Ok([expired]);
        final cubit = SentLettersCubit(repo, _FakeStamps());
        await cubit.load();

        final ok = await cubit.recreateLink(expired);
        expect(ok, isTrue);
        expect(repo.createdLinksFor, [expired.link.letterId]);
      },
    );

    test(
      'recreateLink is blocked for an already-opened letter (BR-05)',
      () async {
        final opened = SentLetter.fromLink(
          _link(openedAt: DateTime(2026, 7, 11), openedBy: 'u2'),
        );
        final repo = _FakeLetters()..sentResult = Ok([opened]);
        final cubit = SentLettersCubit(repo, _FakeStamps());
        await cubit.load();

        final ok = await cubit.recreateLink(opened);
        expect(ok, isFalse);
        expect(repo.createdLinksFor, isEmpty);
      },
    );
  });

  group('SentLettersScreen widget (TC-19)', () {
    Future<void> pump(WidgetTester tester, Widget child) async {
      await tester.pumpWidget(MaterialApp(home: child));
      await tester.pump();
    }

    testWidgets('TC-19: trạng thái link hiển thị đúng (đã mở / chưa mở / hết '
        'hạn)', (tester) async {
      await pump(
        tester,
        SentLettersScreen(
          letters: [
            SentLetterView(
              sent: SentLetter.fromLink(
                _link(
                  id: 'a',
                  platform: 'zalo',
                  openedBy: 'u9',
                  openedAt: DateTime(2026, 7, 11),
                ),
              ),
              title: 'Thư sinh nhật',
              icon: '🎂',
            ),
            SentLetterView(
              sent: SentLetter.fromLink(
                _link(id: 'b', expiresAt: DateTime(2099, 1, 1)),
              ),
              title: 'Thư cảm ơn',
              icon: '💐',
            ),
            SentLetterView(
              sent: SentLetter.fromLink(
                _link(id: 'c', expiresAt: DateTime(2020, 1, 1)),
              ),
              title: 'Thư hết hạn',
              icon: '💌',
            ),
          ],
        ),
      );

      expect(find.text('Đã mở'), findsOneWidget);
      expect(find.text('Chưa mở'), findsOneWidget);
      expect(find.text('Hết hạn'), findsOneWidget);
      // The row now shows the letter's title (like the Home card), not
      // "Thư gửi qua …".
      expect(find.text('Thư sinh nhật'), findsOneWidget);
    });

    testWidgets('TC-19 (trống): empty state + CTA tạo thư', (tester) async {
      var composeTapped = false;
      await pump(
        tester,
        SentLettersScreen(onCompose: () => composeTapped = true),
      );

      expect(find.text('Bạn chưa gửi thư nào'), findsOneWidget);
      await tester.ensureVisible(find.text('Tạo thư đầu tiên'));
      await tester.tap(find.text('Tạo thư đầu tiên'), warnIfMissed: false);
      expect(composeTapped, isTrue);
    });
  });
}
