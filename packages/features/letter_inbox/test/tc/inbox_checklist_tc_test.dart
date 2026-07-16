// Unit coverage for `product-spec/015..018` test-cases (open a letter link,
// save its stamps). Web-viewer journeys (F04-S01/S02 web) stay outside the
// app; the in-app equivalents are asserted here. There is no inbox — received
// letters are never stored (SM-017 BR-10).
import 'package:feature_letter_inbox/feature_letter_inbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';

class _FakeInbox implements InboxRepository {
  _FakeInbox({this.outcome});

  OpenLetterOutcome? outcome;
  ReceivedLetter? savedFrom;

  @override
  Future<OpenLetterOutcome> open(String linkId, {String? viewerUid}) async =>
      outcome ?? const LetterInvalid();

  @override
  Future<int> saveStamps(ReceivedLetter letter) async {
    savedFrom = letter;
    return letter.stamps.length;
  }
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
}
