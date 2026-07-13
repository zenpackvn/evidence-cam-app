import 'package:freezed_annotation/freezed_annotation.dart';

part 'inbox_entry_dto.freezed.dart';
part 'inbox_entry_dto.g.dart';

/// One row of `GET /api/sm/inbox` (A17): a letter this user has received,
/// matching the Go backend's inbox DTO.
@Freezed(copyWith: false, equal: false)
abstract class InboxEntryDto with _$InboxEntryDto {
  const factory InboxEntryDto({
    required String id,
    @JsonKey(name: 'letter_id') required String letterId,
    @JsonKey(name: 'link_id') required String linkId,
    @JsonKey(name: 'sender_uid') @Default('') String senderUid,
    @JsonKey(name: 'opened_at') required DateTime openedAt,
    @Default(false) bool read,
  }) = _InboxEntryDto;

  factory InboxEntryDto.fromJson(Map<String, dynamic> json) =>
      _$InboxEntryDtoFromJson(json);
}

/// Payload of `GET /api/sm/inbox/count`.
@Freezed(copyWith: false, equal: false)
abstract class InboxCountDto with _$InboxCountDto {
  const factory InboxCountDto({@Default(0) int unread}) = _InboxCountDto;

  factory InboxCountDto.fromJson(Map<String, dynamic> json) =>
      _$InboxCountDtoFromJson(json);
}
