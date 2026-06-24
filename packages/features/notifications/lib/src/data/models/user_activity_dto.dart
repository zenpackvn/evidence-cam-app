import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_activity_dto.freezed.dart';
part 'user_activity_dto.g.dart';

@Freezed(copyWith: false, equal: false)
abstract class UserActivityDto with _$UserActivityDto {
  const factory UserActivityDto({
    required String id,
    required String description,
    required String type,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _UserActivityDto;

  factory UserActivityDto.fromJson(Map<String, dynamic> json) =>
      _$UserActivityDtoFromJson(json);
}

/// One cursor-paginated page of the activity feed. [nextCursor] is null on the
/// last page; clients pass it back as the next `?cursor`.
@Freezed(copyWith: false, equal: false)
abstract class UserActivityPageDto with _$UserActivityPageDto {
  const factory UserActivityPageDto({
    required List<UserActivityDto> items,
    @JsonKey(name: 'next_cursor') String? nextCursor,
  }) = _UserActivityPageDto;

  factory UserActivityPageDto.fromJson(Map<String, dynamic> json) =>
      _$UserActivityPageDtoFromJson(json);
}
