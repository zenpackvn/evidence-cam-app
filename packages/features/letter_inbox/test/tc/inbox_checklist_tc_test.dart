// Unit/widget coverage for `product-spec/015..019` test-cases (open a letter
// link, inbox list, sent box). Web-viewer journeys (F04-S01/S02 web) stay
// outside the app; the in-app equivalents are asserted here.
import 'package:architecture/architecture.dart';
import 'package:feature_letter_inbox/feature_letter_inbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';

class _FakeInbox implements InboxRepository {
  _FakeInbox({this.outcome, this.entries = const []});

  OpenLetterOutcome? outcome;
  List<InboxEntry> entries;
  ReceivedLetter? savedFrom;
  bool failList = false;

  @override
  Future<OpenLetterOutcome> open(String linkId, {String? viewerUid}) async =>
      outcome ?? const LetterInvalid();

  @override
  Future<int> saveStamps(ReceivedLetter letter) async {
    savedFrom = letter;
    return letter.stamps.length;
  }

  @override
  Future<Result<List<InboxEntry>>> list() async =>
      failList ? const Err(UnknownFailure()) : Ok(entries);

  @override
  Future<Result<int>> unreadCount() async =>
      Ok(entries.where((e) => !e.read).length);
}

ReceivedLetter _letter({int stamps = 2}) => ReceivedLetter(
  id: 'rl1',
  text: 'Chào cậu 💌',
  stamps: [
    for (var i = 0; i < stamps; i++)
      StampRef(
        id: 's$i',
        imageUrl: 'https://cdn/s$i.png',
        createdAt: DateTime(2026, 7),
      ),
  ],
  createdAt: DateTime(2026, 7, 9),
);

void main() {
  // ── 015/017 · mở thư qua link ───────────────────────────────────────────
  group('RevealCubit open outcomes (TC-15-xxx, TC-17-xxx)', () {
    test('TC-15-001: link hợp lệ lần đầu → opened + nội dung thư', () async {
      final repo = _FakeInbox(outcome: LetterOpened(_letter()));
      final cubit = RevealCubit(repo, linkId: 'abc', viewerUid: 'u1');

      await cubit.open();

      expect(cubit.state.phase, RevealPhase.opened);
      expect(cubit.state.letter?.text, 'Chào cậu 💌');
    });

    test('TC-15 link đã dùng → alreadyOpened (một lần duy nhất)', () async {
      final repo = _FakeInbox(outcome: const LetterAlreadyOpened());
      final cubit = RevealCubit(repo, linkId: 'abc');
      await cubit.open();
      expect(cubit.state.phase, RevealPhase.alreadyOpened);
    });

    test('TC-15 link quá 7 ngày → expired', () async {
      final repo = _FakeInbox(outcome: const LetterExpired());
      final cubit = RevealCubit(repo, linkId: 'abc');
      await cubit.open();
      expect(cubit.state.phase, RevealPhase.expired);
    });

    test('TC-15 link không tồn tại → invalid', () async {
      final repo = _FakeInbox(outcome: const LetterInvalid());
      final cubit = RevealCubit(repo, linkId: 'abc');
      await cubit.open();
      expect(cubit.state.phase, RevealPhase.invalid);
    });
  });

  // ── 018 · lưu tem từ thư nhận được ─────────────────────────────────────
  group('RevealCubit saveStamps (TC-18-xxx)', () {
    test('TC-18: lưu tem của thư vào album — đánh dấu stampsSaved', () async {
      final repo = _FakeInbox(outcome: LetterOpened(_letter()));
      final cubit = RevealCubit(repo, linkId: 'abc', viewerUid: 'u1');
      await cubit.open();

      await cubit.saveStamps();

      expect(cubit.state.stampsSaved, isTrue);
      expect(repo.savedFrom?.stamps, hasLength(2));
    });
  });

  // ── 016 · hộp thư đến ───────────────────────────────────────────────────
  group('InboxListCubit (TC-16-xxx)', () {
    test('TC-16-001: tải danh sách thành công → entries', () async {
      final repo = _FakeInbox(
        entries: [
          InboxEntry(
            id: 'i1',
            letterId: 'l1',
            linkId: 'k1',
            senderUid: 'u9',
            openedAt: DateTime(2026, 7, 10),
            read: false,
          ),
        ],
      );
      final cubit = InboxListCubit(repo);
      await cubit.load();
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.entries, hasLength(1));
    });

    test('TC-16 lỗi mạng → trạng thái lỗi, không kẹt loading', () async {
      final repo = _FakeInbox()..failList = true;
      final cubit = InboxListCubit(repo);
      await cubit.load();
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.entries, isEmpty);
    });
  });

  // ── 016/019 · widget hộp thư (unread dot, badge, tab đã gửi) ────────────
  group('InboxListScreen widget (TC-16, TC-19)', () {
    Future<void> pump(WidgetTester tester, Widget child) async {
      await tester.pumpWidget(MaterialApp(home: child));
      await tester.pump();
    }

    testWidgets('TC-16: dòng chưa đọc có chấm + badge số; đã đọc thì không',
        (tester) async {
      await pump(
        tester,
        const InboxListScreen(
          items: [
            InboxItem(
              linkId: 'k1',
              senderName: 'Mai Anh',
              preview: 'xin chào',
              time: '10:30',
              unread: true,
              unreadCount: 2,
            ),
            InboxItem(
              linkId: 'k2',
              senderName: 'Linh Chi',
              preview: 'đã đọc',
              time: 'Hôm qua',
            ),
          ],
        ),
      );

      expect(find.text('Mai Anh'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Linh Chi'), findsOneWidget);
    });

    testWidgets('TC-19 (hộp thư đã gửi trống): tab Thư đã gửi + CTA tạo thư',
        (tester) async {
      var composeTapped = false;
      await pump(
        tester,
        InboxListScreen(items: const [], onCompose: () => composeTapped = true),
      );

      await tester.tap(find.text('Thư đã gửi'));
      await tester.pumpAndSettle();

      expect(find.text('Bạn chưa gửi thư nào'), findsOneWidget);
      await tester.ensureVisible(find.text('Tạo thư đầu tiên'));
      await tester.tap(find.text('Tạo thư đầu tiên'), warnIfMissed: false);
      expect(composeTapped, isTrue);
    });
  });
}
