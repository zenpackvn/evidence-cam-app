# BaseDto

Base DTO with common JSON fields and entity conversion contract. Every DTO must implement `toEntity()` to convert to its domain entity. DTOs handle JSON serialization; entities are clean domain objects.

## File

`lib/src/core/base/base_dto.dart`

```dart
/// Base DTO with common JSON fields and entity conversion contract.
///
/// Every DTO must implement [toEntity()] to convert to its domain entity.
/// DTOs handle JSON serialization; entities are clean domain objects.
abstract class BaseDto<E> {
  const BaseDto({
    required this.id,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Convert this DTO to its corresponding domain entity.
  E toEntity();
}
```

## Usage

```dart
import 'package:json_annotation/json_annotation.dart';

import '../../../core/base/base_dto.dart';
import '../../domain/entities/user.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto extends BaseDto<User> {
  const UserDto({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  final String name;
  final String email;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  @override
  User toEntity() => User(
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt,
        name: name,
        email: email,
        avatarUrl: avatarUrl,
      );
}
```

## Rules

- Every DTO must implement `toEntity()` — the generic type param is a compile-time guarantee.
- DTOs live in the `data/` layer; entities live in the `domain/` layer — no cross-layer imports.
- Use `@JsonSerializable()` + `build_runner` for JSON mapping — no manual `fromJson` parsing.
