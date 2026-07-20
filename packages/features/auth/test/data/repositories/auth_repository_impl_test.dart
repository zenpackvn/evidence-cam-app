import 'package:architecture/architecture.dart';
import 'package:feature_auth/src/data/datasources/auth_local_data_source.dart';
import 'package:feature_auth/src/data/datasources/firebase_auth_data_source.dart';
import 'package:feature_auth/src/data/datasources/sm_user_data_source.dart';
import 'package:feature_auth/src/data/repositories/auth_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:test_utils/test_utils.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuthDataSource {}

class MockSmUser extends Mock implements SmUserDataSource {}

class MockLocal extends Mock implements AuthLocalDataSource {}

class FakeAuthUser extends Fake implements AuthUser {}

void main() {
  late MockFirebaseAuth firebase;
  late MockSmUser smUser;
  late MockLocal local;
  late AuthTokenProvider tokenProvider;
  late AuthRepositoryImpl repository;

  const testUser = AuthUser(id: 'user-1', username: 'alice');

  setUpAll(() => registerFallbackValue(FakeAuthUser()));

  setUp(() {
    firebase = MockFirebaseAuth();
    smUser = MockSmUser();
    local = MockLocal();
    tokenProvider = AuthTokenProvider();
    when(() => firebase.idToken()).thenAnswer((_) async => 'idtok');
    when(() => local.cacheUser(any())).thenAnswer((_) async {});
    when(() => local.clearSession()).thenAnswer((_) async {});
    repository = AuthRepositoryImpl(firebase, smUser, local, tokenProvider);
  });

  test('constructing binds the network token provider to Firebase', () {
    expect(tokenProvider.isBound, isTrue);
  });

  group('signIn', () {
    test('signs in, loads profile, caches user', () async {
      when(
        () => firebase.signInWithEmail('a@b.com', 'pw'),
      ).thenAnswer((_) async => _FakeCredential());
      when(smUser.me).thenAnswer((_) async => testUser);

      final result = await repository.signIn(
        username: 'a@b.com',
        password: 'pw',
      );

      expect(result, isA<Ok<AuthUser>>());
      expect((result as Ok<AuthUser>).value, testUser);
      verify(() => local.cacheUser(testUser)).called(1);
    });

    test('maps invalid-credential to InvalidCredentialsFailure', () async {
      when(() => firebase.signInWithEmail(any(), any())).thenThrow(
        FirebaseAuthException(code: 'invalid-credential'),
      );

      final result = await repository.signIn(
        username: 'a@b.com',
        password: 'x',
      );

      expect(result, isA<Err<AuthUser>>());
      expect(
        (result as Err<AuthUser>).failure,
        isA<InvalidCredentialsFailure>(),
      );
    });
  });

  group('restoreSession', () {
    test('returns Err when no Firebase user', () async {
      when(local.load).thenAnswer((_) async {});
      when(() => firebase.currentUser).thenReturn(null);

      final result = await repository.restoreSession();

      expect(result, isA<Err<AuthUser>>());
      verify(local.clearSession).called(1);
    });

    test(
      'falls back to cached user when profile fetch fails offline',
      () async {
        when(local.load).thenAnswer((_) async {});
        when(() => firebase.currentUser).thenReturn(_FakeUser());
        when(smUser.me).thenThrow(Exception('offline'));
        when(() => local.currentUser).thenReturn(testUser);

        final result = await repository.restoreSession();

        expect((result as Ok<AuthUser>).value, testUser);
      },
    );
  });
}

class _FakeCredential extends Fake implements UserCredential {}

class _FakeUser extends Fake implements User {}
