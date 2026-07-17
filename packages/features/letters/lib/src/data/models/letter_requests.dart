import 'package:freezed_annotation/freezed_annotation.dart';

part 'letter_requests.freezed.dart';
part 'letter_requests.g.dart';

/// POST /api/sm/letters body. The optional `id` lets an offline-minted client
/// UUID become the server's canonical id.
@Freezed(copyWith: false, equal: false)
abstract class CreateLetterRequest with _$CreateLetterRequest {
  const factory CreateLetterRequest({
    String? id,
    @JsonKey(name: 'content_json') required String contentJson,
    @JsonKey(name: 'stamp_ids') @Default([]) List<String> stampIds,
    @JsonKey(name: 'reply_to_uid') @Default('') String replyToUid,
  }) = _CreateLetterRequest;

  factory CreateLetterRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateLetterRequestFromJson(json);
}

/// POST /api/sm/letters/{id}/links body.
@Freezed(copyWith: false, equal: false)
abstract class CreateLinkRequest with _$CreateLinkRequest {
  const factory CreateLinkRequest({@Default('') String platform}) =
      _CreateLinkRequest;

  factory CreateLinkRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateLinkRequestFromJson(json);
}
