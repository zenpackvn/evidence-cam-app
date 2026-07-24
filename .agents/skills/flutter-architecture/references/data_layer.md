# Data Layer

Imports domain contracts. Only data-layer files import third-party serialization packages. Raw exceptions are caught here and thrown as `FailureException`.

## `data/models/post_dto.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/post.dart';

part 'post_dto.g.dart';

@JsonSerializable()
class PostDto {
  const PostDto({
    required this.id,
    required this.title,
    required this.body,
    required this.authorName,
    required this.createdAt,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) =>
      _$PostDtoFromJson(json);

  final int id;
  final String title;
  final String body;
  @JsonKey(name: 'author_name')
  final String authorName;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$PostDtoToJson(this);

  Post toEntity() => Post(
        id: id,
        title: title,
        body: body,
        authorName: authorName,
        createdAt: createdAt,
      );
}
```

## `data/models/comment_dto.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/comment.dart';

part 'comment_dto.g.dart';

@JsonSerializable()
class CommentDto {
  const CommentDto({
    required this.id,
    required this.body,
    required this.authorName,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) =>
      _$CommentDtoFromJson(json);

  final int id;
  final String body;
  @JsonKey(name: 'author_name')
  final String authorName;

  Map<String, dynamic> toJson() => _$CommentDtoToJson(this);

  Comment toEntity() => Comment(
        id: id,
        body: body,
        authorName: authorName,
      );
}
```

## `data/sources/post_remote_source.dart`

```dart
import '../../../core/network/api_client.dart';
import '../models/comment_dto.dart';
import '../models/post_dto.dart';

class PostRemoteSource {
  const PostRemoteSource(this._apiClient);
  final ApiClient _apiClient;

  Future<List<PostDto>> getPosts({required int page, int limit = 20}) =>
      _apiClient.getPosts(page: page, limit: limit);
  Future<PostDto> getPost(int id) => _apiClient.getPost(id);
  Future<List<CommentDto>> getComments(int postId) =>
      _apiClient.getComments(postId);
}
```

Add these endpoints to `ApiClient` (Retrofit):

```dart
// In lib/src/core/network/api_client.dart:
@GET('/posts')
Future<List<PostDto>> getPosts({
  @Query('page') required int page,
  @Query('limit') int limit = 20,
});

@GET('/posts/{id}')
Future<PostDto> getPost(@Path('id') int id);

@GET('/posts/{postId}/comments')
Future<List<CommentDto>> getComments(@Path('postId') int postId);
```

## `data/post_repository_impl.dart`

```dart
import '../../../core/error/failure.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/entities/comment.dart';
import '../domain/entities/post.dart';
import '../domain/repositories/post_repository.dart';
import 'sources/post_remote_source.dart';

class PostRepositoryImpl implements PostRepository {
  const PostRepositoryImpl({
    required this.remoteSource,
    required this.logger,
  });

  final PostRemoteSource remoteSource;
  final AppLogger logger;

  @override
  Future<({List<Post> posts, bool hasMore})> getPosts({
    required int page,
    int limit = 20,
  }) async {
    try {
      final dtos = await remoteSource.getPosts(page: page, limit: limit);
      return (
        posts: dtos.map((d) => d.toEntity()).toList(),
        hasMore: dtos.length >= limit,
      );
    } catch (e, s) {
      logger.error('getPosts(page=$page) failed', error: e, stackTrace: s);
      throw const FailureException(ServerFailure('Failed to load posts.'));
    }
  }

  @override
  Future<Post> getPost(int id) async {
    try {
      final dto = await remoteSource.getPost(id);
      return dto.toEntity();
    } catch (e, s) {
      logger.error('getPost($id) failed', error: e, stackTrace: s);
      throw const FailureException(ServerFailure('Failed to load post.'));
    }
  }

  @override
  Future<List<Comment>> getComments(int postId) async {
    try {
      final dtos = await remoteSource.getComments(postId);
      return dtos.map((d) => d.toEntity()).toList();
    } catch (e, s) {
      logger.error('getComments($postId) failed', error: e, stackTrace: s);
      throw const FailureException(ServerFailure('Failed to load comments.'));
    }
  }
}
```

> **Tip:** Use `BaseRepository.safeCall()` from [base_repository.md](../../flutter-base-classes/references/base_repository.md) to eliminate the repetitive try/catch blocks above.

## Rules

- DTOs stay in `data/`. `toEntity()` mapping lives on the DTO. Never leak DTOs or `Map<String, dynamic>` into domain or presentation.
- Repository impl catches raw exceptions and throws `FailureException` with a typed `Failure`.
- After adding or changing DTOs, regenerate: `dart run build_runner build --delete-conflicting-outputs`.
