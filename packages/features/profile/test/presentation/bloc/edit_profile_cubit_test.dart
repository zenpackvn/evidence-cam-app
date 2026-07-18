// Tests for the "Sửa hồ sơ" form logic (SM-024 BR-02, BR-03, BR-06 and
// AC-02/03/04/06/07/11).

import 'dart:typed_data';

import 'package:architecture/architecture.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:feature_profile/src/data/datasources/avatar_uploader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

/// Records the edit it is asked to apply and answers with a scripted result,
/// so the tests can assert both what the form sends and how it reacts.
class _FakeProfileRepository implements ProfileRepository {
  UserProfile profile = const UserProfile(
    id: 'u1',
    username: 'alice',
    usernameChangesLeft: 1,
  );
  bool meFails = false;

  /// The next update result; defaults to echoing the stored profile.
  Result<UserProfile>? nextUpdate;

  ProfileEdit? lastEdit;
  int updateCalls = 0;

  @override
  Future<Result<UserProfile>> me() async => meFails
      ? const Err(UnknownFailure('Không tải được hồ sơ.'))
      : Ok(profile);

  @override
  Future<Result<UserProfile>> update(ProfileEdit edit) async {
    lastEdit = edit;
    updateCalls++;
    return nextUpdate ?? Ok(profile);
  }
}

/// Records the bytes it is handed and returns a scripted URL, or throws.
class _FakeAvatarUploader implements AvatarUploader {
  String url = 'https://cdn.stampmail.com/avatars/u1/new.png';
  Exception? error;
  Uint8List? lastBytes;

  @override
  Future<String> upload(Uint8List bytes) async {
    lastBytes = bytes;
    if (error != null) throw error!;
    return url;
  }
}

DioException _dioError() => DioException(
  requestOptions: RequestOptions(path: '/api/sm/uploads/presign'),
  type: DioExceptionType.connectionError,
);

void main() {
  late _FakeProfileRepository repo;
  late _FakeAvatarUploader uploader;

  setUp(() {
    repo = _FakeProfileRepository();
    uploader = _FakeAvatarUploader();
  });

  EditProfileCubit build() => EditProfileCubit(repo, uploader);

  group('load', () {
    test('fills the form from the loaded profile', () async {
      repo.profile = const UserProfile(
        id: 'u1',
        username: 'alice',
        displayName: 'Alice',
        birthDate: BirthDate(day: 3, month: 4, year: 1990),
        usernameChangesLeft: 1,
      );
      final cubit = build();

      await cubit.load();

      expect(cubit.state.status, EditProfileStatus.ready);
      expect(cubit.state.displayName, 'Alice');
      expect(cubit.state.username, 'alice');
      expect(cubit.state.day, '3');
      expect(cubit.state.month, '4');
      expect(cubit.state.year, '1990');
    });

    test('a profile with no birthday leaves the date fields empty', () async {
      final cubit = build();

      await cubit.load();

      expect(cubit.state.day, isEmpty);
      expect(cubit.state.month, isEmpty);
      expect(cubit.state.year, isEmpty);
    });

    test(
      '§5: a load failure is reported so the screen can offer a retry',
      () async {
        repo.meFails = true;
        final cubit = build();

        await cubit.load();

        expect(cubit.state.status, EditProfileStatus.loadFailure);
        expect(cubit.state.saveError, 'Không tải được hồ sơ.');
      },
    );
  });

  group('display name (BR-02)', () {
    test('AC-02: a valid name is saved', () async {
      final cubit = build()..start(repo.profile);

      cubit.displayNameChanged('Alice Nguyễn');
      await cubit.save();

      expect(cubit.state.displayNameError, isNull);
      expect(repo.lastEdit?.displayName, 'Alice Nguyễn');
      expect(cubit.state.status, EditProfileStatus.saved);
    });

    test(
      '§5: too long flags the name field as you type and blocks the save',
      () async {
        final cubit = build()..start(repo.profile);

        cubit.displayNameChanged('a' * 31);
        expect(cubit.state.displayNameError, isNotNull);

        await cubit.save();

        expect(repo.updateCalls, 0, reason: 'an invalid name must not be sent');
        expect(cubit.state.displayNameError, isNotNull);
        // The offending text stays on screen for the user to fix.
        expect(cubit.state.displayName, 'a' * 31);
      },
    );

    test('the error clears once the name is short enough again', () async {
      final cubit = build()..start(repo.profile);

      cubit.displayNameChanged('a' * 31);
      cubit.displayNameChanged('Alice');

      expect(cubit.state.displayNameError, isNull);
    });
  });

  group('username (BR-03)', () {
    test(
      'AC-03: the change is sent and the exhausted allowance is announced',
      () async {
        repo.nextUpdate = const Ok(
          UserProfile(id: 'u1', username: 'alice2', usernameChangesLeft: 0),
        );
        final cubit = build()..start(repo.profile);

        cubit.usernameChanged('alice2');
        await cubit.save();

        expect(repo.lastEdit?.username, 'alice2');
        expect(cubit.state.status, EditProfileStatus.saved);
        expect(cubit.state.usernameJustExhausted, isTrue);
      },
    );

    test('an untouched username is not sent, so it spends no change', () async {
      final cubit = build()..start(repo.profile);

      cubit.displayNameChanged('Alice');
      await cubit.save();

      expect(repo.lastEdit?.username, isNull);
    });

    test(
      'AC-04: with no allowance left the change is refused locally',
      () async {
        const locked = UserProfile(
          id: 'u1',
          username: 'alice',
          usernameChangesLeft: 0,
        );
        final cubit = build()..start(locked);

        cubit.usernameChanged('alice2');
        await cubit.save();

        expect(cubit.state.canChangeUsername, isFalse);
        expect(cubit.state.usernameError, isNotNull);
        expect(repo.updateCalls, 0);
      },
    );

    test('AC-04: a server refusal lands on the username field', () async {
      repo.nextUpdate = const Err(
        PermissionFailure('Bạn đã hết lượt đổi tên người dùng.'),
      );
      final cubit = build()..start(repo.profile);

      cubit.usernameChanged('alice2');
      await cubit.save();

      expect(cubit.state.usernameError, 'Bạn đã hết lượt đổi tên người dùng.');
      expect(cubit.state.saveError, isNull);
      expect(cubit.state.status, EditProfileStatus.ready);
    });

    test('§5: a taken username lands on the username field', () async {
      repo.nextUpdate = const Err(
        ValidationFailure('Tên người dùng đã tồn tại'),
      );
      final cubit = build()..start(repo.profile);

      cubit.usernameChanged('bob');
      await cubit.save();

      expect(cubit.state.usernameError, 'Tên người dùng đã tồn tại');
      expect(cubit.state.saveError, isNull);
      // AC-11's sibling rule: the input the user typed is still there.
      expect(cubit.state.username, 'bob');
    });
  });

  group('birthday (BR-06)', () {
    test('AC-06: day and month save, with the year optional', () async {
      final cubit = build()..start(repo.profile);

      cubit
        ..dayChanged('3')
        ..monthChanged('4');
      await cubit.save();

      expect(cubit.state.birthDateError, isNull);
      expect(repo.lastEdit?.birthDate, const BirthDate(day: 3, month: 4));
      expect(repo.lastEdit?.clearBirthDate, isFalse);
    });

    test('AC-06: a full date including the year saves', () async {
      final cubit = build()..start(repo.profile);

      cubit
        ..dayChanged('3')
        ..monthChanged('4')
        ..yearChanged('1990');
      await cubit.save();

      expect(
        repo.lastEdit?.birthDate,
        const BirthDate(day: 3, month: 4, year: 1990),
      );
    });

    test(
      'an impossible date flags the birthday field and blocks the save',
      () async {
        final cubit = build()..start(repo.profile);

        cubit
          ..dayChanged('31')
          ..monthChanged('4');

        expect(cubit.state.birthDateError, 'Ngày sinh không hợp lệ');

        await cubit.save();
        expect(repo.updateCalls, 0);
      },
    );

    test('a day without a month is flagged', () async {
      final cubit = build()..start(repo.profile);

      cubit.dayChanged('3');

      expect(cubit.state.birthDateError, 'Vui lòng nhập cả ngày và tháng sinh');
    });

    test('AC-07: clearing a stored birthday sends the clear', () async {
      const withBirthday = UserProfile(
        id: 'u1',
        username: 'alice',
        birthDate: BirthDate(day: 3, month: 4, year: 1990),
        usernameChangesLeft: 1,
      );
      final cubit = build()..start(withBirthday);

      cubit.birthDateCleared();
      expect(cubit.state.day, isEmpty);
      expect(cubit.state.birthDateError, isNull);

      await cubit.save();

      expect(repo.lastEdit?.clearBirthDate, isTrue);
      expect(repo.lastEdit?.birthDate, isNull);
    });

    test('a profile that never had a birthday sends no clear', () async {
      final cubit = build()..start(repo.profile);

      cubit.displayNameChanged('Alice');
      await cubit.save();

      expect(repo.lastEdit?.clearBirthDate, isFalse);
    });
  });

  group('offline (BR-09)', () {
    test(
      'AC-11: the save is reported and every typed value survives',
      () async {
        repo.nextUpdate = const Err(UnknownFailure(offlineSaveMessage));
        final cubit = build()..start(repo.profile);

        cubit
          ..displayNameChanged('Alice')
          ..dayChanged('3')
          ..monthChanged('4');
        await cubit.save();

        expect(cubit.state.saveError, offlineSaveMessage);
        expect(cubit.state.status, EditProfileStatus.ready);
        expect(cubit.state.displayName, 'Alice');
        expect(cubit.state.day, '3');
        expect(cubit.state.month, '4');
      },
    );
  });

  group('changeAvatar (SM-024)', () {
    final bytes = Uint8List.fromList([1, 2, 3]);

    test('uploads the bytes, saves the url, and updates the profile', () async {
      uploader.url = 'https://cdn.stampmail.com/avatars/u1/new.png';
      repo.nextUpdate = const Ok(
        UserProfile(
          id: 'u1',
          username: 'alice',
          avatarUrl: 'https://cdn.stampmail.com/avatars/u1/new.png',
        ),
      );
      final cubit = build()..start(repo.profile);

      await cubit.changeAvatar(bytes);

      expect(uploader.lastBytes, bytes);
      expect(
        repo.lastEdit!.avatarUrl,
        'https://cdn.stampmail.com/avatars/u1/new.png',
      );
      expect(
        cubit.state.profile!.avatarUrl,
        'https://cdn.stampmail.com/avatars/u1/new.png',
      );
      expect(cubit.state.isSavingAvatar, isFalse);
    });

    test('leaves the form fields the user is editing untouched', () async {
      final cubit = build()
        ..start(repo.profile)
        ..displayNameChanged('Half-typed name');

      await cubit.changeAvatar(bytes);

      // The avatar commit must not wipe the in-progress display name.
      expect(cubit.state.displayName, 'Half-typed name');
    });

    test('surfaces an upload failure as a save error', () async {
      uploader.error = _dioError();
      final cubit = build()..start(repo.profile);

      await cubit.changeAvatar(bytes);

      expect(cubit.state.saveError, isNotNull);
      expect(cubit.state.isSavingAvatar, isFalse);
      // The upload never reached the profile save.
      expect(repo.updateCalls, 0);
    });

    test('surfaces a save failure and does not change the avatar', () async {
      repo.nextUpdate = const Err(UnknownFailure('server down'));
      final cubit = build()..start(repo.profile);

      await cubit.changeAvatar(bytes);

      expect(cubit.state.saveError, 'server down');
      expect(cubit.state.profile!.avatarUrl, '');
    });

    test('ignores a second change while one is in flight', () async {
      final cubit = build()..start(repo.profile);

      await Future.wait([cubit.changeAvatar(bytes), cubit.changeAvatar(bytes)]);

      // The guard let only one upload through.
      expect(repo.updateCalls, 1);
    });
  });
}
