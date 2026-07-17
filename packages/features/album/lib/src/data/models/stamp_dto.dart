import 'package:freezed_annotation/freezed_annotation.dart';

part 'stamp_dto.freezed.dart';
part 'stamp_dto.g.dart';

/// Wire model for a stamp, matching the Go backend `stampDTO` JSON.
@Freezed(copyWith: false, equal: false)
abstract class StampDto with _$StampDto {
  const factory StampDto({
    required String id,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'thumb_url') @Default('') String thumbUrl,
    @Default('') String name,
    required String source,
    @JsonKey(name: 'sender_name') @Default('') String senderName,
    @JsonKey(name: 'sender_uid') @Default('') String senderUid,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    required int rev,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _StampDto;

  factory StampDto.fromJson(Map<String, dynamic> json) =>
      _$StampDtoFromJson(json);
}
