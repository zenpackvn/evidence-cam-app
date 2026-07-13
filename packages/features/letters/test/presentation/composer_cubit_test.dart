import 'package:architecture/architecture.dart';
import 'package:feature_letters/feature_letters.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLettersRepository implements LettersRepository {
  _FakeLettersRepository({this.failLink = false});

  bool failLink;
  LetterInput? lastInput;

  @override
  Future<Result<Letter>> create(LetterInput input) async {
    lastInput = input;
    return Ok(
      Letter(
        id: 'L1',
        content: input.content,
        stampIds: input.stampIds,
        createdAt: DateTime(2026, 7, 11),
      ),
    );
  }

  @override
  Future<Result<LetterLink>> createLink(String letterId, {String? platform}) async {
    if (failLink) return const Err(UnknownFailure());
    return Ok(
      LetterLink(
        id: 'tok123',
        letterId: letterId,
        platform: platform,
        createdAt: DateTime(2026, 7, 11),
        expiresAt: DateTime(2026, 7, 18),
      ),
    );
  }

  @override
  Future<Result<List<SentLetter>>> sent() async => const Ok([]);
}

void main() {
  test('starts editing with the chosen template', () {
    final cubit = ComposerCubit(_FakeLettersRepository(), templateId: 'floral');
    expect(cubit.state.phase, ComposerPhase.editing);
    expect(cubit.state.content.templateId, 'floral');
    expect(cubit.state.canSend, isFalse); // empty text
    addTearDown(cubit.close);
  });

  test('setText clips to the 500-char limit', () {
    final cubit = ComposerCubit(_FakeLettersRepository());
    cubit.setText('a' * 600);
    expect(cubit.state.charCount, letterCharLimit);
    addTearDown(cubit.close);
  });

  test('canSend once there is non-empty text', () {
    final cubit = ComposerCubit(_FakeLettersRepository());
    cubit.setText('Gửi bạn thân mến');
    expect(cubit.state.canSend, isTrue);
    addTearDown(cubit.close);
  });

  test('toggleStamp caps at 3 (SM-014 BR-03)', () {
    final cubit = ComposerCubit(_FakeLettersRepository());
    cubit.toggleStamp('s1');
    cubit.toggleStamp('s2');
    cubit.toggleStamp('s3');
    cubit.toggleStamp('s4'); // over the cap — ignored
    expect(cubit.state.stampIds, ['s1', 's2', 's3']);
    cubit.toggleStamp('s2'); // toggling off
    expect(cubit.state.stampIds, ['s1', 's3']);
    addTearDown(cubit.close);
  });

  test('send creates letter + mints link and carries it (SM-016)', () async {
    final repo = _FakeLettersRepository();
    final cubit = ComposerCubit(repo);
    cubit.setText('Chào bạn');
    cubit.toggleStamp('s1');
    await cubit.send(platform: 'messenger');
    expect(cubit.state.phase, ComposerPhase.sent);
    expect(cubit.state.link?.id, 'tok123');
    expect(repo.lastInput?.stampIds, ['s1']);
    addTearDown(cubit.close);
  });

  test('send surfaces error when link minting fails', () async {
    final cubit = ComposerCubit(_FakeLettersRepository(failLink: true));
    cubit.setText('Chào bạn');
    await cubit.send();
    expect(cubit.state.phase, ComposerPhase.error);
    addTearDown(cubit.close);
  });

  test('shareUrl builds from the link id and base', () {
    final link = LetterLink(
      id: 'abc',
      letterId: 'L1',
      createdAt: DateTime(2026, 7, 11),
      expiresAt: DateTime(2026, 7, 18),
    );
    expect(link.shareUrl('https://stampmail.app/letter'),
        'https://stampmail.app/letter/abc');
  });
}
