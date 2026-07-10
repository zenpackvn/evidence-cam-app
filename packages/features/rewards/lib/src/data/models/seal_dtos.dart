import 'package:freezed_annotation/freezed_annotation.dart';

part 'seal_dtos.freezed.dart';
part 'seal_dtos.g.dart';

@Freezed(copyWith: false, equal: false)
abstract class SealEntryDto with _$SealEntryDto {
  const factory SealEntryDto({
    required int amount,
    required String reason,
    @JsonKey(name: 'ref_id') @Default('') String refId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _SealEntryDto;

  factory SealEntryDto.fromJson(Map<String, dynamic> json) =>
      _$SealEntryDtoFromJson(json);
}

@Freezed(copyWith: false, equal: false)
abstract class SealBalanceDto with _$SealBalanceDto {
  const factory SealBalanceDto({
    required int balance,
    @Default([]) List<SealEntryDto> history,
  }) = _SealBalanceDto;

  factory SealBalanceDto.fromJson(Map<String, dynamic> json) =>
      _$SealBalanceDtoFromJson(json);
}

@Freezed(copyWith: false, equal: false)
abstract class ShareResultDto with _$ShareResultDto {
  const factory ShareResultDto({
    @Default(false) bool awarded,
    @JsonKey(name: 'new_balance') @Default(0) int newBalance,
  }) = _ShareResultDto;

  factory ShareResultDto.fromJson(Map<String, dynamic> json) =>
      _$ShareResultDtoFromJson(json);
}

/// Response for both 200 (unlocked) and 402 (insufficient) spend outcomes.
@Freezed(copyWith: false, equal: false)
abstract class SpendResultDto with _$SpendResultDto {
  const factory SpendResultDto({
    @Default(false) bool unlocked,
    @JsonKey(name: 'new_balance') @Default(0) int newBalance,
    @Default(0) int shortfall,
  }) = _SpendResultDto;

  factory SpendResultDto.fromJson(Map<String, dynamic> json) =>
      _$SpendResultDtoFromJson(json);
}

@Freezed(copyWith: false, equal: false)
abstract class SpendRequest with _$SpendRequest {
  const factory SpendRequest({
    @JsonKey(name: 'item_type') required String itemType,
    @JsonKey(name: 'item_id') required String itemId,
  }) = _SpendRequest;

  factory SpendRequest.fromJson(Map<String, dynamic> json) =>
      _$SpendRequestFromJson(json);
}
