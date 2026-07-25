import 'package:flutter_starter_template/data/ec_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeEcAuth', () {
    late FakeEcAuth auth;
    setUp(() => auth = FakeEcAuth());

    test('updatePassword rejects wrong current then rotates the password',
        () async {
      await auth.signInWithEmail('a@b.com', 'old12345');

      await expectLater(
        auth.updatePassword(currentPassword: 'nope', newPassword: 'new12345'),
        throwsA(isA<EcAuthException>()),
      );

      await auth.updatePassword(
        currentPassword: 'old12345',
        newPassword: 'new12345',
      );

      // Old password no longer valid after rotation.
      await expectLater(
        auth.updatePassword(currentPassword: 'old12345', newPassword: 'x'),
        throwsA(isA<EcAuthException>()),
      );
    });

    test('link/unlink toggles providers and blocks removing the last',
        () async {
      await auth.signInWithGoogle(); // providers: [google.com]
      expect(auth.currentUser!.hasProvider(EcAuthProvider.google), isTrue);

      await auth.linkProvider(EcAuthProvider.apple);
      expect(auth.currentUser!.hasProvider(EcAuthProvider.apple), isTrue);

      await auth.unlinkProvider(EcAuthProvider.google);
      expect(auth.currentUser!.hasProvider(EcAuthProvider.google), isFalse);

      // Only apple remains — cannot unlink the last credential.
      await expectLater(
        auth.unlinkProvider(EcAuthProvider.apple),
        throwsA(isA<EcAuthException>()),
      );
    });

    test('updateProfile updates name/phone; deleteAccount clears the user',
        () async {
      await auth.signInWithEmail('a@b.com', 'pw123456');

      await auth.updateProfile(name: 'Bảo', phone: '0900000000');
      expect(auth.currentUser!.displayName, 'Bảo');
      expect(auth.currentUser!.phone, '0900000000');

      await auth.deleteAccount();
      expect(auth.currentUser, isNull);
    });

    test('user listenable notifies on sign-in and sign-out', () async {
      var notifications = 0;
      auth.user.addListener(() => notifications++);

      await auth.signInWithEmail('a@b.com', 'pw123456');
      await auth.signOut();

      expect(notifications, greaterThanOrEqualTo(2));
    });
  });
}
