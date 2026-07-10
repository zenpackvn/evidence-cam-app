import 'package:freezed_annotation/freezed_annotation.dart';

part 'entitlement_dto.freezed.dart';
part 'entitlement_dto.g.dart';

/// Wire model for the entitlement, matching the Go backend `entitlementDTO`.
@Freezed(copyWith: false, equal: false)
abstract class EntitlementDto with _$EntitlementDto {
  const factory EntitlementDto({
    @JsonKey(name: 'is_premium') @Default(false) bool isPremium,
    @JsonKey(name: 'product_id') @Default('') String productId,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
  }) = _EntitlementDto;

  factory EntitlementDto.fromJson(Map<String, dynamic> json) =>
      _$EntitlementDtoFromJson(json);
}
