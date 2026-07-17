import 'package:freezed_annotation/freezed_annotation.dart';

part 'stamp_request.freezed.dart';
part 'stamp_request.g.dart';

/// Wire payload for POST /api/sm/stamps. The optional `id` lets an
/// offline-minted client UUID become the server's canonical id.
@Freezed(copyWith: false, equal: false)
abstract class StampRequest with _$StampRequest {
  const factory StampRequest({
    String? id,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'thumb_url') @Default('') String thumbUrl,
    @Default('') String name,
    required String source,
    @JsonKey(name: 'sender_name') @Default('') String senderName,
    @JsonKey(name: 'sender_uid') @Default('') String senderUid,
  }) = _StampRequest;

  factory StampRequest.fromJson(Map<String, dynamic> json) =>
      _$StampRequestFromJson(json);
}

/// Wire payload for PATCH /api/sm/stamps/{id} — rename only (SM-022 BR-08).
@Freezed(copyWith: false, equal: false)
abstract class StampRenameRequest with _$StampRenameRequest {
  const factory StampRenameRequest({@Default('') String name}) =
      _StampRenameRequest;

  factory StampRenameRequest.fromJson(Map<String, dynamic> json) =>
      _$StampRenameRequestFromJson(json);
}
