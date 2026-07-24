# Bloc Tests and Widget Tests

## Bloc Tests

### `test/features/home/home_cubit_test.dart`

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/src/core/error/failure.dart';
import 'package:app/src/features/home/domain/home_repository.dart';
import 'package:app/src/features/home/presentation/cubit/home_cubit.dart';
import 'package:app/src/features/home/presentation/cubit/home_state.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository repo;

  setUp(() {
    repo = MockHomeRepository();
  });

  group('HomeCubit', () {
    blocTest<HomeCubit, HomeState>(
      'emits [Loading, Loaded] on success',
      setUp: () {
        when(() => repo.fetchGreetings()).thenAnswer((_) async => ['hi']);
      },
      build: () => HomeCubit(repo),
      act: (c) => c.load(),
      expect: () => [const HomeLoading(), const HomeLoaded(['hi'])],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [Loading, Error] on FailureException',
      setUp: () {
        when(() => repo.fetchGreetings())
            .thenThrow(const FailureException(NetworkFailure()));
      },
      build: () => HomeCubit(repo),
      act: (c) => c.load(),
      expect: () => [
        const HomeLoading(),
        const HomeError(NetworkFailure()),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [Loading, Empty] when list is empty',
      setUp: () {
        when(() => repo.fetchGreetings()).thenAnswer((_) async => []);
      },
      build: () => HomeCubit(repo),
      act: (c) => c.load(),
      expect: () => [const HomeLoading(), const HomeEmpty()],
    );
  });
}
```

> **Key fix:** `mocktail` requires `when(() => repo.method())` — not `when(repo.method)`. The closure syntax is mandatory.

### Bloc test with verify

```dart
blocTest<PostCubit, PostState>(
  'deletePost calls repository and emits deleted',
  setUp: () {
    when(() => repo.deletePost(any())).thenAnswer((_) async {});
  },
  build: () => PostCubit(repo),
  act: (c) => c.deletePost(42),
  expect: () => [const PostDeleting(), const PostDeleted()],
  verify: (_) {
    verify(() => repo.deletePost(42)).called(1);
  },
);
```

### Bloc test with seed (initial state)

```dart
blocTest<PostListCubit, PostListState>(
  'loadMore appends to existing posts',
  setUp: () {
    when(() => repo.fetchPosts(page: 2, limit: 20))
        .thenAnswer((_) async => [Post(id: 21, title: 'New')]);
  },
  build: () => PostListCubit(repo),
  seed: () => PostListLoaded(
    posts: List.generate(20, (i) => Post(id: i, title: 'Post $i')),
    hasMore: true,
    page: 1,
  ),
  act: (c) => c.loadMore(),
  expect: () => [
    isA<PostListLoaded>()
        .having((s) => s.posts.length, 'posts.length', 21)
        .having((s) => s.page, 'page', 2),
  ],
);
```

---

## Widget Tests

### `test/features/home/home_page_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/src/features/home/presentation/cubit/home_cubit.dart';
import 'package:app/src/features/home/presentation/cubit/home_state.dart';
import 'package:app/src/features/home/presentation/pages/home_page.dart';
import '../../helpers/pump_app.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

void main() {
  late MockHomeCubit cubit;

  setUp(() {
    cubit = MockHomeCubit();
  });

  Widget buildSubject() {
    return BlocProvider<HomeCubit>.value(
      value: cubit,
      child: const HomePage(),
    );
  }

  group('HomePage', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      when(() => cubit.state).thenReturn(const HomeLoading());
      await tester.pumpApp(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows content when loaded', (tester) async {
      when(() => cubit.state).thenReturn(const HomeLoaded(['Hello']));
      await tester.pumpApp(buildSubject());

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('shows error message when error', (tester) async {
      when(() => cubit.state).thenReturn(
        const HomeError(NetworkFailure()),
      );
      await tester.pumpApp(buildSubject());

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows retry button on error state', (tester) async {
      when(() => cubit.state).thenReturn(
        const HomeError(NetworkFailure()),
      );
      await tester.pumpApp(buildSubject());

      final retryButton = find.text('Retry');
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      verify(() => cubit.load()).called(1);
    });

    testWidgets('shows empty state when empty', (tester) async {
      when(() => cubit.state).thenReturn(const HomeEmpty());
      await tester.pumpApp(buildSubject());

      expect(find.text('No items found'), findsOneWidget);
    });
  });
}
```

### Widget test patterns

#### Testing navigation

```dart
testWidgets('navigates to detail on tap', (tester) async {
  final navigator = FakeNavigator();
  when(() => cubit.state).thenReturn(
    PostListLoaded(posts: [Post(id: 1, title: 'Test')], hasMore: false),
  );

  await tester.pumpApp(buildSubject());
  await tester.tap(find.text('Test'));

  expect(navigator.calls, contains('pushPostDetail:1'));
});
```

#### Testing form validation

```dart
testWidgets('shows error when email is empty', (tester) async {
  await tester.pumpApp(const SignInForm());

  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle();

  expect(find.text('Email is required'), findsOneWidget);
});

testWidgets('calls cubit.login on valid submit', (tester) async {
  await tester.pumpApp(
    BlocProvider.value(value: cubit, child: const SignInForm()),
  );

  await tester.enterText(find.byKey(const Key('email')), 'test@example.com');
  await tester.enterText(find.byKey(const Key('password')), 'password123');
  await tester.tap(find.text('Sign In'));

  verify(() => cubit.login('test@example.com', 'password123')).called(1);
});
```

#### Testing BlocListener side effects

```dart
testWidgets('shows toast on success', (tester) async {
  final dialog = FakeDialog();
  getIt.registerSingleton<AppDialog>(dialog);

  whenListen(
    cubit,
    Stream.fromIterable([const SaveSuccess()]),
    initialState: const SaveInitial(),
  );

  await tester.pumpApp(buildSubject());
  await tester.pump();

  expect(dialog.calls, contains('toast:Saved successfully'));
});
```

---

## Repository Tests

### `test/features/post/post_repository_test.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/src/core/error/failure.dart';
import 'package:app/src/core/network/api_client.dart';
import 'package:app/src/features/post/data/post_repository_impl.dart';
import 'package:app/src/features/post/domain/post_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient api;
  late PostRepository repo;

  setUp(() {
    api = MockApiClient();
    repo = PostRepositoryImpl(api: api);
  });

  group('PostRepository', () {
    test('fetchPosts maps DTOs to entities on success', () async {
      when(() => api.getPosts(page: 1, limit: 20)).thenAnswer(
        (_) async => [{'id': 1, 'title': 'Hello'}],
      );

      final posts = await repo.fetchPosts(page: 1, limit: 20);

      expect(posts, hasLength(1));
      expect(posts.first.title, 'Hello');
    });

    test('fetchPosts maps DioException to NetworkFailure', () async {
      when(() => api.getPosts(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(
        () => repo.fetchPosts(page: 1, limit: 20),
        throwsA(isA<FailureException>().having(
          (e) => e.failure,
          'failure',
          isA<NetworkFailure>(),
        )),
      );
    });
  });
}
```

> **Pattern:** Mock the `ApiClient` (app-owned wrapper), not `Dio` directly. The repository is responsible for DTO-to-entity mapping and error translation — test both paths.
