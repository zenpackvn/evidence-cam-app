// Coverage for `product-spec/019-hop-thu-da-gui` (SM-021): the "Thư" tab is
// the sent box only — list of sent links with status, empty state with the
// compose CTA (F04-S07d).
import 'package:architecture/architecture.dart';
import 'package:feature_letters/feature_letters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLetters implements LettersRepository {
  Result<List<SentLetter>> sentResult = const Ok([]);

  @override
  Future<Result<List<SentLetter>>> sent() async => sentResult;

  @override
  Future<Result<Letter>> create(LetterInput input) async =>
      const Err(UnknownFailure());

  @override
  Future<Result<LetterLink>> createLink(
    String letterId, {
    String? platform,
  }) async => const Err(UnknownFailure());
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
      final cubit = SentLettersCubit(repo);
      await cubit.load();
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.letters, hasLength(1));
    });

    test('TC-19 lỗi mạng → trạng thái lỗi, không kẹt loading', () async {
      final repo = _FakeLetters()
        ..sentResult = const Err(UnknownFailure('mất mạng'));
      final cubit = SentLettersCubit(repo);
      await cubit.load();
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.letters, isEmpty);
      expect(cubit.state.error, isNotNull);
    });
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
            SentLetter.fromLink(
              _link(
                id: 'a',
                platform: 'zalo',
                openedBy: 'u9',
                openedAt: DateTime(2026, 7, 11),
              ),
            ),
            SentLetter.fromLink(
              _link(id: 'b', expiresAt: DateTime(2099, 1, 1)),
            ),
            SentLetter.fromLink(
              _link(id: 'c', expiresAt: DateTime(2020, 1, 1)),
            ),
          ],
        ),
      );

      expect(find.text('Đã mở'), findsOneWidget);
      expect(find.text('Chưa mở'), findsOneWidget);
      expect(find.text('Hết hạn'), findsOneWidget);
      expect(find.text('Thư gửi qua zalo'), findsOneWidget);
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
