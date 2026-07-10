import 'package:freezed_annotation/freezed_annotation.dart';

part 'album_request.freezed.dart';
part 'album_request.g.dart';

/// Wire payload for both create (POST) and update (PUT). The optional `id` is
/// only used by POST so an offline-minted client UUID becomes the server's
/// canonical id; PUT ignores it (path id wins).
@Freezed(copyWith: false, equal: false)
abstract class AlbumRequest with _$AlbumRequest {
  const factory AlbumRequest({
    String? id,
    required String name,
    @JsonKey(name: 'stamp_ids') @Default([]) List<String> stampIds,
  }) = _AlbumRequest;

  factory AlbumRequest.fromJson(Map<String, dynamic> json) =>
      _$AlbumRequestFromJson(json);
}
