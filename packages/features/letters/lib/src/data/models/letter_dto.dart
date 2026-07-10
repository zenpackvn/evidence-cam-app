import 'package:freezed_annotation/freezed_annotation.dart';

part 'letter_dto.freezed.dart';
part 'letter_dto.g.dart';

/// Wire model for a letter, matching the Go backend `letterDTO` JSON.
@Freezed(copyWith: false, equal: false)
abstract class LetterDto with _$LetterDto {
  const factory LetterDto({
    required String id,
    @JsonKey(name: 'content_json') @Default('') String contentJson,
    @JsonKey(name: 'stamp_ids') @Default([]) List<String> stampIds,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default(0) int rev,
  }) = _LetterDto;

  factory LetterDto.fromJson(Map<String, dynamic> json) =>
      _$LetterDtoFromJson(json);
}
