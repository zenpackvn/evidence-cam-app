# Domain Layer

Zero imports from `data/`, `presentation/`, or any third-party package (except `equatable` for entities). Contains entities, abstract repository contracts, and use cases.

## `domain/entities/post.dart`

```dart
import 'package:equatable/equatable.dart';

class Post extends Equatable {
  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.authorName,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final String authorName;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, title, body, authorName, createdAt];
}
```

## `domain/entities/comment.dart`

```dart
import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.body,
    required this.authorName,
  });

  final int id;
  final String body;
  final String authorName;

  @override
  List<Object?> get props => [id, body, authorName];
}
```

## `domain/repositories/post_repository.dart`

Abstract interface — no implementation details. Data layer provides the implementation; domain only defines the contract.

```dart
import '../entities/comment.dart';
import '../entities/post.dart';

abstract interface class PostRepository {
  Future<({List<Post> posts, bool hasMore})> getPosts({
    required int page,
    int limit = 20,
  });
  Future<Post> getPost(int id);
  Future<List<Comment>> getComments(int postId);
}
```

## `domain/usecases/get_post_detail_usecase.dart`

Use cases are **required** — cubits depend on use cases, never on repositories directly. Even simple pass-through use cases keep the architecture consistent and give business rules a natural home as the feature evolves.

```dart
import '../../../../core/base/use_case.dart';
import '../entities/comment.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPostDetailUseCase extends UseCase<({Post post, List<Comment> comments}), int> {
  const GetPostDetailUseCase(this._repository);
  final PostRepository _repository;

  @override
  Future<({Post post, List<Comment> comments})> call(int postId) async {
    final results = await Future.wait([
      _repository.getPost(postId),
      _repository.getComments(postId),
    ]);
    return (
      post: results[0] as Post,
      comments: results[1] as List<Comment>,
    );
  }
}
```

## Use Case Naming Convention

| | Convention |
|--|--|
| File | `<action>_<entity>_use_case.dart` |
| Class | `<Action><Entity>UseCase` (always `UseCase` suffix) |
| Base | Extends `UseCase<T, Params>` or `StreamUseCase<T, Params>` |
| No params | Use `NoParams` |
| Multiple params | Use a record typedef: `typedef Params = ({String a, int b})` |

## Rules

- Domain has **zero** imports from `data/` or `presentation/`.
- Entities depend only on `equatable`.
- Repository contracts are `abstract interface class` — no implementation.
- Every feature must have at least one use case. Cubits import use cases, never repositories.
