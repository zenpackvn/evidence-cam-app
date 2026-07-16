import 'package:feature_letter_inbox/feature_letter_inbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';

class _FakeInboxRepository implements InboxRepository {
  _FakeInboxRepository(this.outcome);

  final OpenLetterOutcome outcome;
  int saved = 0;

  @override
  Future<OpenLetterOutcome> open(String linkId, {String? viewerUid}) async =>
      outcome;

  @override
  Future<int> saveStamps(ReceivedLetter letter) async =>
      saved = letter.stamps.length;
}

ReceivedLetter _letter() => ReceivedLetter(
  id: 'L1',
  text: 'Chào bạn',
  stamps: [
    StampRef(
      id: 's1',
      imageUrl: 'https://cdn/s1.png',
      createdAt: DateTime(2026, 7, 11),
    ),
  ],
  createdAt: DateTime(2026, 7, 11),
);

void main() {
  test('open on a fresh link reveals the letter', () async {
    final cubit = RevealCubit(
      _FakeInboxRepository(LetterOpened(_letter())),
      linkId: 'tok',
    );
    await cubit.open();
    expect(cubit.state.phase, RevealPhase.opened);
    expect(cubit.state.letter?.text, 'Chào bạn');
    addTearDown(cubit.close);
  });

  test('already-opened link lands on that terminal state', () async {
    final cubit = RevealCubit(
      _FakeInboxRepository(const LetterAlreadyOpened()),
      linkId: 'tok',
    );
    await cubit.open();
    expect(cubit.state.phase, RevealPhase.alreadyOpened);
    addTearDown(cubit.close);
  });

  test('expired and invalid map to their phases', () async {
    final expired = RevealCubit(
      _FakeInboxRepository(const LetterExpired()),
      linkId: 'a',
    );
    await expired.open();
    expect(expired.state.phase, RevealPhase.expired);
    addTearDown(expired.close);

    final invalid = RevealCubit(
      _FakeInboxRepository(const LetterInvalid()),
      linkId: 'b',
    );
    await invalid.open();
    expect(invalid.state.phase, RevealPhase.invalid);
    addTearDown(invalid.close);
  });

  test('open is idempotent (a second call is a no-op)', () async {
    final repo = _FakeInboxRepository(LetterOpened(_letter()));
    final cubit = RevealCubit(repo, linkId: 'tok');
    await cubit.open();
    await cubit.open(); // ignored — not in intro phase
    expect(cubit.state.phase, RevealPhase.opened);
    addTearDown(cubit.close);
  });

  test('saveStamps saves once and flips the flag', () async {
    final repo = _FakeInboxRepository(LetterOpened(_letter()));
    final cubit = RevealCubit(repo, linkId: 'tok');
    await cubit.open();
    await cubit.saveStamps();
    expect(cubit.state.stampsSaved, isTrue);
    expect(repo.saved, 1);
    await cubit.saveStamps(); // no double-save
    expect(repo.saved, 1);
    addTearDown(cubit.close);
  });
}
