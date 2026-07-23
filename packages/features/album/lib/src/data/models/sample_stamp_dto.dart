import 'package:freezed_annotation/freezed_annotation.dart';

part 'sample_stamp_dto.freezed.dart';
part 'sample_stamp_dto.g.dart';

/// Wire model for a sample stamp, matching the Go backend `sampleStampDTO`.
@Freezed(copyWith: false, equal: false)
abstract class SampleStampDto with _$SampleStampDto {
  const factory SampleStampDto({
    required String id,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'thumb_url') @Default('') String thumbUrl,
    @Default('') String name,
    @Default('') String theme,
    @JsonKey(name: 'is_new') @Default(false) bool isNew,
  }) = _SampleStampDto;

  factory SampleStampDto.fromJson(Map<String, dynamic> json) =>
      _$SampleStampDtoFromJson(json);
}
