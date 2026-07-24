# BaseEntity / Identifiable

`BaseEntity` — common fields for domain objects with a server-assigned ID and timestamps.

`Identifiable` — minimal base for entities that only need an ID (no timestamps).

## File

`lib/src/core/base/base_entity.dart`

```dart
import 'package:equatable/equatable.dart';

/// Base entity with common fields shared by most domain objects.
///
/// Extend this for entities that come from an API or database
/// and have a server-assigned ID and timestamps.
///
/// For value objects without an ID (e.g., Address, Money),
/// extend [Equatable] directly instead.
abstract class BaseEntity extends Equatable {
  const BaseEntity({
    required this.id,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id];
}

/// Minimal base for entities that only need identity, not timestamps.
abstract class Identifiable extends Equatable {
  const Identifiable({required this.id});
  final String id;

  @override
  List<Object?> get props => [id];
}
```

## Usage

```dart
import '../../../core/base/base_entity.dart';

class User extends BaseEntity {
  const User({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final String? avatarUrl;

  @override
  List<Object?> get props => [...super.props, name, email, avatarUrl];
}
```

```dart
// Lightweight entity — ID only, no timestamps
class Tag extends Identifiable {
  const Tag({required super.id, required this.name});
  final String name;

  @override
  List<Object?> get props => [...super.props, name];
}
```

## Rules

- Any entity with an API/database ID and timestamps extends `BaseEntity`.
- Value objects (Address, Money) extend `Equatable` directly — no ID needed.
- Lightweight tags/categories with ID but no timestamps use `Identifiable`.
- Subclasses always include `[...super.props, ...]` in their own `props`.
- Maximum one level of inheritance beyond base (`User extends BaseEntity`, not `PremiumUser extends User extends BaseEntity`). Beyond that, use composition.
