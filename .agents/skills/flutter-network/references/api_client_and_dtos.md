# ApiClient & DTO Patterns

Retrofit-based API client and JSON serialization rules.

## `lib/src/core/network/api_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../features/post/data/dtos/post_dto.dart';
import '../../features/post/data/dtos/comment_dto.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET('/posts')
  Future<List<PostDto>> getPosts({
    @Query('_page') int page = 1,
    @Query('_limit') int limit = 20,
  });

  @GET('/posts/{id}')
  Future<PostDto> getPost(@Path('id') int id);

  @GET('/posts/{postId}/comments')
  Future<List<CommentDto>> getComments(@Path('postId') int postId);

  @POST('/posts')
  Future<PostDto> createPost(@Body() Map<String, dynamic> body);

  @PUT('/posts/{id}')
  Future<PostDto> updatePost(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/posts/{id}')
  Future<void> deletePost(@Path('id') int id);
}
```

After defining endpoints, run:

```
dart run build_runner build --delete-conflicting-outputs
```

## Critical Retrofit rules

- Endpoints MUST return DTO types (e.g. `Future<PostDto>`), **never** `Map<String, dynamic>` or `dynamic`. Retrofit codegen calls `DTO.fromJson()` automatically — returning raw maps produces broken generated code (`Map.fromJson` does not exist).
- DTOs MUST use `@JsonSerializable()` with codegen (`part 'xxx.g.dart'`, `_$XxxFromJson`, `_$XxxToJson`). Never write manual `fromJson`/`toJson`.

## JSON Serialization rules

- **Always use `@JsonSerializable()` codegen for DTOs** — never write manual `fromJson`/`toJson`. Every DTO must have `part 'xxx.g.dart'` and use `_$XxxFromJson`/`_$XxxToJson`.
- Keep JSON parsing in DTOs only — never in widgets, blocs, cubits, or use cases.
- Retrofit `ApiClient` returns DTO types; data sources receive DTOs directly (no manual deserialization).
- Map DTOs to domain entities at the repository boundary via `dto.toEntity()`.
- Never pass raw `Map<String, dynamic>` beyond the data layer.
- Use `@JsonKey(name: 'snake_case')` for field renames, defaults, enum handling, and nullable quirks.
- Regenerate serializers after changing annotations or model fields.
- Test parsing edge cases: missing keys, nulls, enum mismatches, numeric coercion.
