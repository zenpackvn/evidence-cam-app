// Widget tests for the SM-024 "Sửa hồ sơ" form: that each error renders under
// the field it belongs to (§5), the username locks once spent (AC-04), and the
// birthday can be cleared (AC-07).

import 'dart:async';

import 'package:architecture/architecture.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.profile);

  final UserProfile profile;
  Result<UserProfile>? nextUpdate;
  ProfileEdit? lastEdit;

  @override
  Future<Result<UserProfile>> me() async => Ok(profile);

  @override
  Future<Result<UserProfile>> update(ProfileEdit edit) async {
    lastEdit = edit;
    return nextUpdate ?? Ok(profile);
  }
}

void main() {
  const alice = UserProfile(
    id: 'u1',
    username: 'alice',
    displayName: 'Alice',
    usernameChangesLeft: 1,
  );

  Future<EditProfileCubit> pumpForm(
    WidgetTester tester,
    _FakeProfileRepository repo,
  ) async {
    final cubit = EditProfileCubit(repo);
    unawaited(cubit.load());
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<EditProfileCubit>.value(
          value: cubit,
          child: const EditProfileBody(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('shows the current profile in the form', (tester) async {
    await pumpForm(tester, _FakeProfileRepository(alice));

    expect(find.text('Sửa hồ sơ'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('alice'), findsOneWidget);
  });

  testWidgets('§5: a too-long display name errors under the name field', (
    tester,
  ) async {
    await pumpForm(tester, _FakeProfileRepository(alice));

    await tester.enterText(
      find.byKey(const Key('editProfile_displayName')),
      'a' * 31,
    );
    await tester.pump();

    expect(find.text('Tên hiển thị tối đa 30 ký tự'), findsOneWidget);
  });

  testWidgets('AC-04: with no changes left the username field is disabled', (
    tester,
  ) async {
    const locked = UserProfile(
      id: 'u1',
      username: 'alice',
      usernameChangesLeft: 0,
    );
    await pumpForm(tester, _FakeProfileRepository(locked));

    expect(find.text('Bạn đã hết lượt đổi tên người dùng.'), findsOneWidget);
    final field = tester.widget<TextFormField>(
      find.descendant(
        of: find.byKey(const Key('editProfile_username')),
        matching: find.byType(TextFormField),
      ),
    );
    expect(field.enabled, isFalse);
  });

  testWidgets('a user with a change left is told so', (tester) async {
    await pumpForm(tester, _FakeProfileRepository(alice));

    expect(
      find.text('Bạn chỉ được đổi tên người dùng thêm 1 lần.'),
      findsOneWidget,
    );
  });

  testWidgets('an invalid birthday errors under the birthday field', (
    tester,
  ) async {
    await pumpForm(tester, _FakeProfileRepository(alice));

    await tester.enterText(find.byKey(const Key('editProfile_birthDay')), '31');
    await tester.pump();
    await tester.enterText(find.byKey(const Key('editProfile_birthMonth')), '4');
    await tester.pump();

    expect(
      find.byKey(const Key('editProfile_birthDateError')),
      findsOneWidget,
    );
    expect(find.text('Ngày sinh không hợp lệ'), findsOneWidget);
  });

  testWidgets('AC-07: the clear action empties the birthday and saves it', (
    tester,
  ) async {
    const withBirthday = UserProfile(
      id: 'u1',
      username: 'alice',
      birthDate: BirthDate(day: 3, month: 4, year: 1990),
      usernameChangesLeft: 1,
    );
    final repo = _FakeProfileRepository(withBirthday);
    await pumpForm(tester, repo);

    await tester.tap(find.byKey(const Key('editProfile_clearBirthDate')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('editProfile_save')));
    await tester.pump();

    expect(repo.lastEdit?.clearBirthDate, isTrue);
  });

  testWidgets('AC-11: an offline save shows the banner and keeps the input', (
    tester,
  ) async {
    final repo = _FakeProfileRepository(alice)
      ..nextUpdate = const Err(UnknownFailure(offlineSaveMessage));
    await pumpForm(tester, repo);

    await tester.enterText(
      find.byKey(const Key('editProfile_displayName')),
      'Alice II',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('editProfile_save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('editProfile_saveError')), findsOneWidget);
    expect(find.text(offlineSaveMessage), findsOneWidget);
    // The typed value is still on screen to retry with.
    expect(find.text('Alice II'), findsOneWidget);
  });

  testWidgets('§5: the load error offers a retry', (tester) async {
    final cubit = EditProfileCubit(_FailingRepository());
    unawaited(cubit.load());
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<EditProfileCubit>.value(
          value: cubit,
          child: const EditProfileBody(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Không tải được hồ sơ.'), findsOneWidget);
  });
}

class _FailingRepository implements ProfileRepository {
  @override
  Future<Result<UserProfile>> me() async =>
      const Err(UnknownFailure('Không tải được hồ sơ.'));

  @override
  Future<Result<UserProfile>> update(ProfileEdit edit) async =>
      const Err(UnknownFailure('Không tải được hồ sơ.'));
}
