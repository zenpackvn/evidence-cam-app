import 'package:config/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // With no `--dart-define`s supplied (as in a plain `flutter test` run),
  // EnvConfig must fall back to its dev defaults. This guards against
  // accidental changes to those compile-time defaults.
  group('EnvConfig defaults', () {
    const env = EnvConfig();

    test('defaults to the dev flavor', () {
      expect(env.flavor, 'dev');
      expect(env.isDev, isTrue);
      expect(env.isStaging, isFalse);
      expect(env.isProd, isFalse);
    });

    test('defaults the base URL to the production API', () {
      // A build with no env file must still reach a real backend — the old
      // localhost default silently shipped an app that could only talk to the
      // machine it was built on.
      expect(env.apiBaseUrl, 'https://api.zenpack.vn');
    });

    test('defaults the API timeout to 10 seconds', () {
      expect(env.apiTimeout, const Duration(seconds: 10));
    });
  });
}
