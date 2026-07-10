import 'package:freezed_annotation/freezed_annotation.dart';

part 'album_dto.freezed.dart';
part 'album_dto.g.dart';

/// Wire model for an album, matching the Go backend `albumDTO` JSON.
@Freezed(copyWith: false, equal: false)
abstract class AlbumDto with _$AlbumDto {
  const factory AlbumDto({
    required String id,
    required String name,
    @JsonKey(name: 'stamp_ids') @Default([]) List<String> stampIds,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    required int rev,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _AlbumDto;

  factory AlbumDto.fromJson(Map<String, dynamic> json) =>
      _$AlbumDtoFromJson(json);
}
