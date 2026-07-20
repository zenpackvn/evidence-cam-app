import 'package:feature_letter_inbox/feature_letter_inbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';

class _FakeInboxRepository implements InboxRepository {
  _FakeInboxRepository(this.outcome);

  final OpenLetterOutcome outcome;

  @override
  Future<OpenLetterOutcome> open(String linkId, {String? viewerUid}) async =>
      outcome;
}

ReceivedLetter _letter({String senderName = ''}) => ReceivedLetter(
  id: 'L1',
  text: 'Chào bạn',
  senderName: senderName,
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

  test(
    'opened letter carries the sender name for the reply prefill (SM-020 BR-01)',
    () async {
      final cubit = RevealCubit(
        _FakeInboxRepository(LetterOpened(_letter(senderName: 'An'))),
        linkId: 'tok',
      );
      await cubit.open();
      expect(cubit.state.letter?.senderName, 'An');
      addTearDown(cubit.close);
    },
  );

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

  test('InboxRepository exposes no save-stamp capability (SM-017 BR-05)', () {
    // The interface must not carry a way to persist received stamps; the reveal
    // flow only opens and reads. This is a compile-time guard: RevealCubit's
    // surface is just open(), and InboxRepository is open()-only.
    final cubit = RevealCubit(
      _FakeInboxRepository(LetterOpened(_letter())),
      linkId: 'tok',
    );
    expect(cubit.open, isA<Function>());
    addTearDown(cubit.close);
  });
}
