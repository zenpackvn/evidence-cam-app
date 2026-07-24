import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

void main() {
  group('redactSensitive', () {
    test('redacts a Bearer token in an Authorization header line', () {
      expect(
        redactSensitive('authorization: Bearer eyJhbGciOiJIUzI1NiJ9.abc.def'),
        'authorization: Bearer [REDACTED]',
      );
    });

    test('is case-insensitive on the Authorization header', () {
      expect(
        redactSensitive('Authorization: bearer SECRETTOKEN'),
        'Authorization: bearer [REDACTED]',
      );
    });

    test('redacts quoted JSON credential fields but keeps the key', () {
      expect(
        redactSensitive('{"password": "hunter2", "email": "a@b.com"}'),
        '{"password": "[REDACTED]", "email": "a@b.com"}',
      );
    });

    test('redacts access_token and refresh_token values', () {
      final out = redactSensitive(
        '{"access_token":"aaa.bbb.ccc","refresh_token":"r.e.f"}',
      );
      expect(out.contains('aaa.bbb.ccc'), isFalse);
      expect(out.contains('r.e.f'), isFalse);
      expect(out, contains('"access_token":"[REDACTED]"'));
      expect(out, contains('"refresh_token":"[REDACTED]"'));
    });

    test('leaves non-sensitive content untouched', () {
      const line = '{"id": 42, "title": "hello world"}';
      expect(redactSensitive(line), line);
    });
  });
}
