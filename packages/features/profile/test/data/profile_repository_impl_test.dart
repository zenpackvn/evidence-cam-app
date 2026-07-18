// Tests for the profile repository (SM-024): the wire mapping and the PATCH
// body semantics that let an omitted field differ from a cleared one.

import 'package:architecture/architecture.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:feature_profile/src/data/datasources/profile_remote_data_source.dart';
import 'package:feature_profile/src/data/models/profile_dto.dart';
import 'package:feature_profile/src/data/repositories/profile_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

/// Captures the body it is sent and replays a scripted response or error.
class _FakeRemote implements ProfileRemoteDataSource {
  ProfileDto dto = const ProfileDto(id: 'u1', username: 'alice');
  DioException? error;
  Map<String, dynamic>? lastBody;

  @override
  Future<ProfileDto> me() async {
    if (error != null) throw error!;
    return dto;
  }

  @override
  Future<ProfileDto> update(Map<String, dynamic> body) async {
    lastBody = body;
    if (error != null) throw error!;
    return dto;
  }
}

/// A DioException carrying the backend's `{code, message}` error envelope.
DioException _httpError(int status, {String? code, String? message}) {
  final request = RequestOptions(path: '/api/sm/me');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<Map<String, dynamic>>(
      requestOptions: request,
      statusCode: status,
      data: {'code': ?code, 'message': ?message},
    ),
  );
}

void main() {
  late _FakeRemote remote;
  late ProfileRepositoryImpl repo;

  setUp(() {
    remote = _FakeRemote();
    repo = ProfileRepositoryImpl(remote);
  });

  UserProfile unwrap(Result<UserProfile> result) => switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => fail('expected Ok, got ${failure.message}'),
  };

  Failure failureOf(Result<UserProfile> result) => switch (result) {
    Ok() => fail('expected Err, got Ok'),
    Err(:final failure) => failure,
  };

  group('me', () {
    test('maps the wire profile onto the domain entity', () async {
      remote.dto = const ProfileDto(
        id: 'u1',
        username: 'alice',
        displayName: 'Alice',
        dateOfBirth: DateOfBirthDto(day: 3, month: 4, year: 1990),
        usernameChangesLeft: 1,
        plan: 'premium',
        stampsCreated: 12,
        lettersSent: 3,
      );

      final profile = unwrap(await repo.me());

      expect(profile.id, 'u1');
      expect(profile.username, 'alice');
      expect(profile.displayName, 'Alice');
      expect(profile.birthDate, const BirthDate(day: 3, month: 4, year: 1990));
      expect(profile.usernameChangesLeft, 1);
      expect(profile.canChangeUsername, isTrue);
      expect(profile.isPremium, isTrue);
      expect(profile.stampsCreated, 12);
      expect(profile.lettersSent, 3);
    });

    test('BR-06: a null birthday on the wire becomes no birthday', () async {
      remote.dto = const ProfileDto(id: 'u1', username: 'alice');

      expect(unwrap(await repo.me()).birthDate, isNull);
    });

    test('BR-06: a birthday with no year keeps day and month', () async {
      remote.dto = const ProfileDto(
        id: 'u1',
        username: 'alice',
        dateOfBirth: DateOfBirthDto(day: 3, month: 4),
      );

      expect(
        unwrap(await repo.me()).birthDate,
        const BirthDate(day: 3, month: 4),
      );
    });

    test('BR-03: no changes left means the username is locked', () async {
      remote.dto = const ProfileDto(id: 'u1', username: 'alice');

      expect(unwrap(await repo.me()).canChangeUsername, isFalse);
    });
  });

  group('update body', () {
    test('sends only the fields the edit carries', () async {
      await repo.update(const ProfileEdit(displayName: 'Alice'));

      expect(remote.lastBody, {'display_name': 'Alice'});
    });

    test('AC-07: a clear is an explicit null, not an omission', () async {
      await repo.update(const ProfileEdit(clearBirthDate: true));

      expect(remote.lastBody, {'date_of_birth': null});
      expect(remote.lastBody!.containsKey('date_of_birth'), isTrue);
    });

    test('an untouched birthday is left out of the body entirely', () async {
      await repo.update(const ProfileEdit(displayName: 'Alice'));

      expect(remote.lastBody!.containsKey('date_of_birth'), isFalse);
    });

    test('SM-024: sends the new avatar url when set', () async {
      await repo.update(
        const ProfileEdit(
          avatarUrl: 'https://cdn.stampmail.com/avatars/u1/a.png',
        ),
      );

      expect(remote.lastBody, {
        'avatar_url': 'https://cdn.stampmail.com/avatars/u1/a.png',
      });
    });

    test(
      'an empty avatar url is sent (clears the avatar), not omitted',
      () async {
        await repo.update(const ProfileEdit(avatarUrl: ''));

        expect(remote.lastBody, {'avatar_url': ''});
        expect(remote.lastBody!.containsKey('avatar_url'), isTrue);
      },
    );

    test('an untouched avatar is left out of the body entirely', () async {
      await repo.update(const ProfileEdit(displayName: 'Alice'));

      expect(remote.lastBody!.containsKey('avatar_url'), isFalse);
    });

    test('BR-06: a birthday without a year sends a null year', () async {
      await repo.update(
        const ProfileEdit(birthDate: BirthDate(day: 3, month: 4)),
      );

      expect(remote.lastBody, {
        'date_of_birth': {'day': 3, 'month': 4, 'year': null},
      });
    });

    test('sends the full edit when every field changed', () async {
      await repo.update(
        const ProfileEdit(
          displayName: 'Alice',
          username: 'alice2',
          birthDate: BirthDate(day: 3, month: 4, year: 1990),
        ),
      );

      expect(remote.lastBody, {
        'display_name': 'Alice',
        'username': 'alice2',
        'date_of_birth': {'day': 3, 'month': 4, 'year': 1990},
      });
    });
  });

  group('update failures', () {
    test(
      'AC-04: 403 username_change_limit becomes a permission failure',
      () async {
        remote.error = _httpError(
          403,
          code: 'username_change_limit',
          message: 'Bạn đã hết lượt đổi tên người dùng.',
        );

        final failure = failureOf(await repo.update(const ProfileEdit()));

        expect(failure, isA<PermissionFailure>());
        expect(failure.message, 'Bạn đã hết lượt đổi tên người dùng.');
      },
    );

    test(
      '§5: 409 becomes a validation failure carrying the server message',
      () async {
        remote.error = _httpError(
          409,
          code: 'username_taken',
          message: 'Tên người dùng đã tồn tại',
        );

        final failure = failureOf(await repo.update(const ProfileEdit()));

        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Tên người dùng đã tồn tại');
      },
    );

    test('400 becomes a validation failure', () async {
      remote.error = _httpError(
        400,
        code: 'invalid_input',
        message: 'Tên hiển thị tối đa 30 ký tự',
      );

      final failure = failureOf(await repo.update(const ProfileEdit()));

      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Tên hiển thị tối đa 30 ký tự');
    });

    test('404 becomes a not-found failure', () async {
      remote.error = _httpError(404, code: 'not_found');

      expect(
        failureOf(await repo.update(const ProfileEdit())),
        isA<NotFoundFailure>(),
      );
    });

    test('AC-11: a connection error reports the offline message', () async {
      remote.error = DioException(
        requestOptions: RequestOptions(path: '/api/sm/me'),
        type: DioExceptionType.connectionError,
      );

      final failure = failureOf(await repo.update(const ProfileEdit()));

      expect(failure.message, offlineSaveMessage);
    });

    test('AC-11: a timeout counts as offline too', () async {
      remote.error = DioException(
        requestOptions: RequestOptions(path: '/api/sm/me'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        failureOf(await repo.update(const ProfileEdit())).message,
        offlineSaveMessage,
      );
    });
  });
}
