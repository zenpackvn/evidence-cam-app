// The `content_json` contract (SM-013 BR-02/BR-09, D1.5 app↔web parity).
//
// These are the rules the web viewer and every future reader depend on, so they
// are asserted at the domain level, without an editor:
//   • a rich body round-trips through encode/decode intact;
//   • `text` is always written, so a reader that ignores `delta` still shows
//     the words (backward compatibility, forwards);
//   • a letter with no `delta` (written before rich text) still decodes and
//     renders (backward compatibility, backwards);
//   • the 500-char limit (BR-04) counts plain text, not markup.
import 'dart:convert';

import 'package:feature_letters/feature_letters.dart';
import 'package:flutter_test/flutter_test.dart';

/// "Xin chào" + a bold, coral " bạn", closed by a centered paragraph.
DeltaOps _richBody() => [
  <String, dynamic>{'insert': 'Xin chào'},
  <String, dynamic>{
    'insert': ' bạn',
    'attributes': <String, dynamic>{'bold': true, 'color': '#F35B43'},
  },
  <String, dynamic>{
    'insert': '\n',
    'attributes': <String, dynamic>{'align': 'center'},
  },
];

void main() {
  group('Delta helpers (SM-013)', () {
    test('plain text round-trips through a Delta', () {
      final ops = deltaFromPlainText('dòng một\ndòng hai');
      expect(plainTextFromDelta(ops), 'dòng một\ndòng hai');
    });

    test('an empty body is still a valid Delta document', () {
      // Quill rejects a document that does not end in a newline.
      expect(deltaFromPlainText(''), [
        {'insert': '\n'},
      ]);
      expect(plainTextFromDelta(deltaFromPlainText('')), '');
    });

    test('plain text length ignores the document-closing newline', () {
      expect(plainTextFromDelta(_richBody()), 'Xin chào bạn');
    });

    test('clipDelta trims to the limit and keeps surviving formatting', () {
      final ops = clipDelta(_richBody(), 9);

      expect(plainTextFromDelta(ops), 'Xin chào ');
      // The bold/coral run is cut to what fits but keeps its attributes.
      expect(ops[1]['insert'], ' ');
      expect((ops[1]['attributes']! as Map)['bold'], isTrue);
      expect(plainTextFromDelta(ops).length, 9);
    });

    test('clipDelta leaves a body within the limit untouched', () {
      final ops = _richBody();
      expect(clipDelta(ops, letterCharLimit), same(ops));
    });

    test('a malformed or non-document delta is rejected, not thrown', () {
      expect(deltaFromJson(null), isNull);
      expect(deltaFromJson('nonsense'), isNull);
      expect(deltaFromJson(const <Object>[]), isNull);
      // retain/delete ops are a change set, not a letter body.
      expect(
        deltaFromJson(const [
          {'retain': 3},
        ]),
        isNull,
      );
    });
  });

  group('LetterContent rich body (BR-02 / BR-09)', () {
    test('a rich body survives encode → decode intact', () {
      final content = const LetterContent(
        templateId: 'classic',
        text: '',
      ).withBody(_richBody());

      final decoded = LetterContent.decode(content.encode());

      expect(decoded.text, 'Xin chào bạn');
      expect(decoded.delta, isNotNull);
      final run = decoded.delta![1];
      expect(run['insert'], ' bạn');
      expect((run['attributes']! as Map)['bold'], isTrue);
      expect((run['attributes']! as Map)['color'], '#F35B43');
      expect(
        (decoded.delta![2]['attributes']! as Map)['align'],
        'center',
      );
    });

    test('withBody keeps text as the plain projection of the delta', () {
      final content = const LetterContent(
        templateId: 'classic',
        text: 'cũ',
      ).withBody(_richBody());

      expect(content.text, plainTextFromDelta(content.delta!));
    });

    test('encoded JSON always carries plain text for readers without Delta '
        '(web viewer fallback, D1.5)', () {
      final content = const LetterContent(
        templateId: 'classic',
        text: '',
      ).withBody(_richBody());

      final json = jsonDecode(content.encode()) as Map<String, dynamic>;

      expect(json['text'], 'Xin chào bạn');
      expect(json['delta'], isA<List<dynamic>>());
    });

    test('a letter written before rich text (plain text, no delta) still '
        'decodes and renders', () {
      // Exactly what the old model wrote.
      const legacy = '{"template_id":"kraft","text":"thư cũ","ruled":true}';

      final decoded = LetterContent.decode(legacy);

      expect(decoded.delta, isNull, reason: 'no formatting was ever recorded');
      expect(decoded.text, 'thư cũ');
      expect(decoded.ruled, isTrue, reason: 'BR-08 must not regress');
      expect(decoded.templateId, 'kraft');
      // …and it still opens in the rich editor.
      expect(plainTextFromDelta(decoded.richDelta), 'thư cũ');
    });

    test('a letter whose delta is corrupt falls back to its text rather than '
        'failing to open', () {
      const broken =
          '{"template_id":"classic","text":"vẫn đọc được","delta":"garbage"}';

      final decoded = LetterContent.decode(broken);

      expect(decoded.delta, isNull);
      expect(plainTextFromDelta(decoded.richDelta), 'vẫn đọc được');
    });

    test('no delta is written for a letter that has no formatting', () {
      const plain = LetterContent(templateId: 'classic', text: 'chào');
      expect(jsonDecode(plain.encode()), isNot(contains('delta')));
    });

    test('the 500-char limit counts plain text, not markup (BR-04)', () {
      // 600 characters spread over two formatted runs.
      final long = <Map<String, dynamic>>[
        {'insert': 'a' * 300},
        {
          'insert': 'b' * 300,
          'attributes': <String, dynamic>{'bold': true},
        },
        {'insert': '\n'},
      ];

      final content = const LetterContent(
        templateId: 'classic',
        text: '',
      ).withBody(long);

      expect(content.text.length, letterCharLimit);
      expect(plainTextFromDelta(content.delta!).length, letterCharLimit);
    });

    test('the non-body fields survive a body edit (BR-03/BR-06/BR-08)', () {
      final content = const LetterContent(
        templateId: 'kraft',
        text: '',
        paperColor: 0xFFF3E7D3,
        fontFamily: 'Caveat',
        ruled: true,
      ).withBody(_richBody());

      final decoded = LetterContent.decode(content.encode());

      expect(decoded.templateId, 'kraft');
      expect(decoded.paperColor, 0xFFF3E7D3);
      expect(decoded.fontFamily, 'Caveat');
      expect(decoded.ruled, isTrue);
    });
  });
}
