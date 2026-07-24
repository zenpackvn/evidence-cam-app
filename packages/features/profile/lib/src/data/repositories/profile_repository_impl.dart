import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';
import 'package:shared_contracts/shared_contracts.dart';

import '../../domain/entities/birth_date.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_dto.dart';

/// Reads and edits the owner's profile over the REST API (SM-024).
///
/// Online-only by design: BR-09 forbids saving while offline, so a connection
/// error carries [offlineSaveMessage], which the form shows without discarding
/// the user's input (AC-11).
@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<Result<UserProfile>> me() async {
    try {
      return Ok(_withLocalHeader(_toProfile(await _remote.me())));
    } on DioException catch (e) {
      return Err(_mapError(e));
    }
  }

  /// Overlays the locally-saved name/avatar ([ProfileHeaderStore]) onto the
  /// server profile so an edit the backend couldn't store yet (PATCH 405) still
  /// shows after a re-login on this device; seeds the store on the first read.
  UserProfile _withLocalHeader(UserProfile server) {
    final header = ProfileHeaderStore.instance.value;
    if (header == null) {
      ProfileHeaderStore.instance.update(
        server.id,
        ProfileHeader(
          displayName: server.displayName,
          avatarUrl: server.avatarUrl,
        ),
      );
      return server;
    }
    return server.copyWith(
      displayName: (header.displayName?.trim().isNotEmpty ?? false)
          ? header.displayName!.trim()
          : null,
      avatarUrl: (header.avatarUrl?.isNotEmpty ?? false)
          ? header.avatarUrl
          : null,
    );
  }

  @override
  Future<Result<UserProfile>> update(ProfileEdit edit) async {
    try {
      return Ok(_toProfile(await _remote.update(_body(edit))));
    } on DioException catch (e) {
      return Err(_mapError(e));
    }
  }

  /// Builds the PATCH body. Only the fields the user actually edited are sent;
  /// clearing the birthday is an explicit null (AC-07), which is why an omitted
  /// field and a cleared one cannot share a representation.
  Map<String, dynamic> _body(ProfileEdit edit) {
    final body = <String, dynamic>{};
    if (edit.displayName != null) body['display_name'] = edit.displayName;
    if (edit.username != null) body['username'] = edit.username;
    // Sent as-is, including "" — the backend treats an empty string as "clear
    // the avatar", so an omitted field (null) and a cleared one differ.
    if (edit.avatarUrl != null) body['avatar_url'] = edit.avatarUrl;
    if (edit.clearBirthDate) {
      body['date_of_birth'] = null;
    } else if (edit.birthDate != null) {
      final d = edit.birthDate!;
      body['date_of_birth'] = <String, dynamic>{
        'day': d.day,
        'month': d.month,
        'year': d.year,
      };
    }
    return body;
  }

  UserProfile _toProfile(ProfileDto dto) => UserProfile(
    id: dto.id,
    username: dto.username,
    displayName: dto.displayName,
    birthDate: _toBirthDate(dto.dateOfBirth),
    usernameChangesLeft: dto.usernameChangesLeft,
    avatarUrl: dto.avatarUrl,
    isPremium: dto.plan == 'premium',
    stampsCreated: dto.stampsCreated,
    lettersSent: dto.lettersSent,
  );

  BirthDate? _toBirthDate(DateOfBirthDto? dto) {
    // The server sends null when unset; day/month are stored together, so a
    // zero in either means there is no birthday to show (BR-06).
    if (dto == null || dto.day == 0 || dto.month == 0) return null;
    return BirthDate(day: dto.day, month: dto.month, year: dto.year);
  }

  Failure _mapError(DioException e) {
    final status = e.response?.statusCode;
    final code = _field(e.response?.data, 'code');
    final message = _field(e.response?.data, 'message');

    // BR-09 / AC-11: no connection — the save never happened.
    if (_isOffline(e)) return const UnknownFailure(offlineSaveMessage);
    // BR-03 / AC-04: the username allowance is spent. Only a username change
    // produces a 403, which is what lets the form put it on that field.
    if (status == 403 && code == 'username_change_limit') {
      return PermissionFailure(
        message ?? 'Bạn đã hết lượt đổi tên người dùng.',
      );
    }
    // §5: the name belongs to someone else.
    if (status == 409) {
      return ValidationFailure(message ?? 'Tên người dùng đã tồn tại');
    }
    if (status == 400) {
      return ValidationFailure(message ?? 'Thông tin không hợp lệ.');
    }
    if (status == 404) {
      return NotFoundFailure(message ?? 'Không tìm thấy hồ sơ.');
    }
    return UnknownFailure(message ?? e.message ?? 'Không lưu được hồ sơ.');
  }

  bool _isOffline(DioException e) => switch (e.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => true,
    _ => false,
  };

  String? _field(Object? body, String key) {
    if (body is Map<String, dynamic>) {
      final value = body[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}
