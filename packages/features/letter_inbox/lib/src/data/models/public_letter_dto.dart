import 'package:freezed_annotation/freezed_annotation.dart';

part 'public_letter_dto.freezed.dart';
part 'public_letter_dto.g.dart';

/// A stamp in the public letter payload — image URL only (the web/anonymous
/// reader can't call the authed stamps API).
@Freezed(copyWith: false, equal: false)
abstract class PublicStampDto with _$PublicStampDto {
  const factory PublicStampDto({
    required String id,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'thumb_url') @Default('') String thumbUrl,
  }) = _PublicStampDto;

  factory PublicStampDto.fromJson(Map<String, dynamic> json) =>
      _$PublicStampDtoFromJson(json);
}

/// The letter payload served at /public/letter/{id}, matching the Go backend
/// `publicLetterDTO`.
@Freezed(copyWith: false, equal: false)
abstract class PublicLetterDto with _$PublicLetterDto {
  const factory PublicLetterDto({
    required String id,
    @JsonKey(name: 'content_json') @Default('') String contentJson,
    @JsonKey(name: 'sender_name') @Default('') String senderName,
    @JsonKey(name: 'sender_uid') @Default('') String senderUid,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default([]) List<PublicStampDto> stamps,
  }) = _PublicLetterDto;

  factory PublicLetterDto.fromJson(Map<String, dynamic> json) =>
      _$PublicLetterDtoFromJson(json);
}
