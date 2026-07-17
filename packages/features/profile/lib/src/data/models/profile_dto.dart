import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_dto.freezed.dart';
part 'profile_dto.g.dart';

/// Wire model for the birthday, matching the Go backend `dateOfBirthDTO`
/// (SM-024 BR-06). `year` is nullable — the user may give only day and month.
@Freezed(copyWith: false, equal: false)
abstract class DateOfBirthDto with _$DateOfBirthDto {
  const factory DateOfBirthDto({
    @Default(0) int day,
    @Default(0) int month,
    int? year,
  }) = _DateOfBirthDto;

  factory DateOfBirthDto.fromJson(Map<String, dynamic> json) =>
      _$DateOfBirthDtoFromJson(json);
}

/// Wire model for `GET|PATCH /api/sm/me`, matching the Go backend `profileDTO`
/// (SM-024).
@Freezed(copyWith: false, equal: false)
abstract class ProfileDto with _$ProfileDto {
  const factory ProfileDto({
    required String id,
    @Default('') String username,
    @JsonKey(name: 'display_name') @Default('') String displayName,
    @JsonKey(name: 'date_of_birth') DateOfBirthDto? dateOfBirth,
    @JsonKey(name: 'username_changes_left') @Default(0) int usernameChangesLeft,
    @JsonKey(name: 'avatar_url') @Default('') String avatarUrl,
    @Default('free') String plan,
    @JsonKey(name: 'stamps_created') @Default(0) int stampsCreated,
    @JsonKey(name: 'letters_sent') @Default(0) int lettersSent,
  }) = _ProfileDto;

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);
}
