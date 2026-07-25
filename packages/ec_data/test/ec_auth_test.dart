import 'package:ec_data/ec_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeEcAuth', () {
    test('signs in via Google and exposes a token', () async {
      final auth = FakeEcAuth();
      expect(auth.currentUser, isNull);
      final user = await auth.signInWithGoogle();
      expect(user.uid, isNotEmpty);
      expect(auth.currentUser, isNotNull);
      expect(await auth.idToken(), isNotNull);
    });

    test('email register keeps the given name, sign-out clears', () async {
      final auth = FakeEcAuth();
      final user = await auth.registerWithEmail(
        email: 'a@b.co',
        password: 'secret6',
        name: 'Anh Ba',
      );
      expect(user.email, 'a@b.co');
      expect(user.displayName, 'Anh Ba');

      await auth.signOut();
      expect(auth.currentUser, isNull);
      expect(await auth.idToken(), isNull);
    });
  });
}
