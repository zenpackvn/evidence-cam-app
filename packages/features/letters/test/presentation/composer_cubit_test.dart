import 'package:architecture/architecture.dart';
import 'package:feature_letters/feature_letters.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLettersRepository implements LettersRepository {
  _FakeLettersRepository({this.failLink = false});

  @override
  Future<Result<List<Letter>>> letters() async => const Ok([]);

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
  Future<Result<LetterLink>> createLink(
    String letterId, {
    String? platform,
  }) async {
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

  @override
  Future<LetterContent?> cachedContent(String letterId) async => null;

  @override
  Future<CachedLetter?> cachedMeta(String letterId) async => null;
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

  test(
    'setRuled toggles ruled lines, keeping text (SM-013 BR-08/AC-07..08)',
    () {
      final cubit = ComposerCubit(_FakeLettersRepository());
      cubit.setText('dòng một\ndòng hai');
      expect(cubit.state.content.ruled, isFalse); // default = plain paper

      cubit.setRuled(ruled: true); // AC-07: bật kẻ dòng
      expect(cubit.state.content.ruled, isTrue);
      expect(cubit.state.content.text, 'dòng một\ndòng hai'); // giữ nội dung

      cubit.setRuled(ruled: false); // AC-08: tắt kẻ dòng
      expect(cubit.state.content.ruled, isFalse);
      expect(cubit.state.content.text, 'dòng một\ndòng hai');
      addTearDown(cubit.close);
    },
  );

  test('ruled flag round-trips through content_json so the recipient sees it '
      '(SM-013 BR-08)', () {
    const ruled = LetterContent(templateId: 'classic', text: 'x', ruled: true);
    expect(LetterContent.decode(ruled.encode()).ruled, isTrue);
    // Off is the default and stays omitted/false on decode.
    const plain = LetterContent(templateId: 'classic', text: 'x');
    expect(LetterContent.decode(plain.encode()).ruled, isFalse);
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
    expect(repo.lastInput?.replyToUid, isNull);
    addTearDown(cubit.close);
  });

  test(
    'a reply threads replyToUid into the created letter (SM-026 D12)',
    () async {
      final repo = _FakeLettersRepository();
      final cubit = ComposerCubit(repo, replyToUid: 'original-uid');
      cubit.setText('Cảm ơn bạn');
      await cubit.send(platform: 'zalo');
      expect(repo.lastInput?.replyToUid, 'original-uid');
      addTearDown(cubit.close);
    },
  );

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
    expect(
      link.shareUrl('https://stampmail.app/letter'),
      'https://stampmail.app/letter/abc',
    );
  });
}
