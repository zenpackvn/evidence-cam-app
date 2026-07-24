# DI Module & Route Wiring

## `di/post_module.dart`

```dart
import 'package:get_it/get_it.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';
import '../data/post_repository_impl.dart';
import '../data/sources/post_remote_source.dart';
import '../domain/repositories/post_repository.dart';
import '../domain/usecases/get_post_detail_usecase.dart';
import '../presentation/cubit/post_detail_cubit.dart';
import '../presentation/cubit/post_list_cubit.dart';

void registerPostModule(GetIt getIt) {
  // Data sources
  getIt.registerLazySingleton<PostRemoteSource>(
    () => PostRemoteSource(getIt<ApiClient>()),
  );

  // Repository (registered as the abstract interface)
  getIt.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteSource: getIt<PostRemoteSource>(),
      logger: getIt<AppLogger>(),
    ),
  );

  // Use cases
  getIt.registerFactory<GetPostDetailUseCase>(
    () => GetPostDetailUseCase(getIt<PostRepository>()),
  );

  // Cubits — always factory, never singleton
  getIt.registerFactory<PostListCubit>(
    () => PostListCubit(getIt<PostRepository>()),
  );
  getIt.registerFactory<PostDetailCubit>(
    () => PostDetailCubit(getIt<GetPostDetailUseCase>()),
  );
}
```

Call from the composition root:

```dart
// In lib/src/core/di/service_locator.dart:
import '../../features/post/di/post_module.dart';

Future<void> configureDependencies(Env env) async {
  // ... core registrations ...
  registerPostModule(getIt);
}
```

## Route Wiring

```dart
// In lib/src/app/router/app_router.dart:
GoRoute(
  path: '/posts',
  builder: (context, state) => const PostListPage(),
  routes: [
    GoRoute(
      path: ':id',
      builder: (context, state) {
        final postId = int.parse(state.pathParameters['id']!);
        return PostDetailPage(postId: postId);
      },
    ),
  ],
),
```

## Rules

- Cubits are **always `registerFactory`**, never `registerLazySingleton`. State leaks across screens if registered as singletons.
- Repository is registered as the **abstract interface** (`PostRepository`), not the impl (`PostRepositoryImpl`).
- Feature DI module is called from `configureDependencies()` — never self-registers.
- Nothing outside the DI module imports `*_impl.dart` classes.
