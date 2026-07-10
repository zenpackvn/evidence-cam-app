import 'package:freezed_annotation/freezed_annotation.dart';

part 'link_dto.freezed.dart';
part 'link_dto.g.dart';

/// Wire model for a letter link, matching the Go backend `linkDTO` JSON.
@Freezed(copyWith: false, equal: false)
abstract class LinkDto with _$LinkDto {
  const factory LinkDto({
    required String id,
    @JsonKey(name: 'letter_id') required String letterId,
    @Default('') String platform,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    @JsonKey(name: 'opened_by') String? openedBy,
    @JsonKey(name: 'opened_at') DateTime? openedAt,
  }) = _LinkDto;

  factory LinkDto.fromJson(Map<String, dynamic> json) =>
      _$LinkDtoFromJson(json);
}
