# AppNavigator — Interface and Implementation

## `lib/src/app/router/app_navigator.dart`

The **app-owned interface**. Feature code depends on this — never on `package:go_router`.

```dart
/// App-owned navigation interface.
/// Feature code calls this instead of go_router extensions directly.
abstract interface class AppNavigator {
  /// Replace the current stack (tab switches, auth redirects).
  void go(String path, {Object? extra});

  /// Push onto the stack (detail pages, modals).
  void push(String path, {Object? extra});

  /// Pop the top route. Returns [result] to the previous route if provided.
  void pop<T extends Object?>([T? result]);

  /// Whether the navigator can pop the current route.
  bool canPop();

  // ── Typed convenience methods ──

  void goHome();
  void goSignIn();
  void goPostList();
  void pushPostDetail(int postId, {Object? extra});
  void goProfile();
  void goSettings();
}
```

## `lib/src/app/router/app_navigator_impl.dart`

The **only file** that bridges feature navigation calls to `package:go_router`. Registered in DI.

```dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'app_navigator.dart';
import 'route_names.dart';

class AppNavigatorImpl implements AppNavigator {
  const AppNavigatorImpl(this._context);
  final BuildContext _context;

  @override
  void go(String path, {Object? extra}) => _context.go(path, extra: extra);

  @override
  void push(String path, {Object? extra}) => _context.push(path, extra: extra);

  @override
  void pop<T extends Object?>([T? result]) => _context.pop(result);

  @override
  bool canPop() => _context.canPop();

  // ── Typed convenience methods ──

  @override
  void goHome() => _context.go(RoutePaths.home);

  @override
  void goSignIn() => _context.go(RoutePaths.signIn);

  @override
  void goPostList() => _context.go(RoutePaths.postList);

  @override
  void pushPostDetail(int postId, {Object? extra}) =>
      _context.push('/posts/$postId', extra: extra);

  @override
  void goProfile() => _context.go(RoutePaths.profile);

  @override
  void goSettings() => _context.go(RoutePaths.settings);
}

/// Call from widgets: `navigator(context).pushPostDetail(42)`
AppNavigator navigator(BuildContext context) => AppNavigatorImpl(context);
```

## DI Registration

```dart
// AppNavigator is NOT registered as a singleton.
// It needs a BuildContext, so it's created at the call site.

// Option 1: Factory method in pages/widgets (recommended)
AppNavigator navigator(BuildContext context) => AppNavigatorImpl(context);

// Option 2: Register as factory with FactoryParam
getIt.registerFactoryParam<AppNavigator, BuildContext, void>(
  (context, _) => AppNavigatorImpl(context),
);
// Usage: getIt<AppNavigator>(param1: context)
```

## Navigation Usage in Feature Code

Feature code imports `AppNavigator` (the interface) and `navigator()` helper — **never** `package:go_router`.

### In a widget

```dart
import '../../../app/router/app_navigator.dart';
import '../../../app/router/app_navigator_impl.dart'; // for navigator() helper

// Navigate to detail
navigator(context).pushPostDetail(post.id);

// Go back
navigator(context).pop();

// Tab switch
navigator(context).goHome();
```

### In a BlocListener

```dart
BlocListener<SignInCubit, SignInState>(
  listenWhen: (prev, curr) => curr is SignInSuccess,
  listener: (context, state) {
    navigator(context).goHome();
  },
  child: const _SignInView(),
)
```

### Pass extra data

```dart
// Sender — feature code
navigator(context).pushPostDetail(post.id, extra: post);

// Receiver — in app_router.dart (router layer, not feature code)
GoRoute(
  name: RouteNames.postDetail,
  path: ':id',
  builder: (context, state) {
    final post = state.extra as Post?;
    final postId = int.parse(state.pathParameters['id']!);
    return PostDetailPage(postId: postId, initialPost: post);
  },
),
```

### Query parameters

```dart
// Sender
navigator(context).push('/posts?category=tech&sort=latest');

// Receiver — in app_router.dart
GoRoute(
  path: RoutePaths.postList,
  builder: (context, state) {
    final category = state.uri.queryParameters['category'];
    final sort = state.uri.queryParameters['sort'] ?? 'latest';
    return PostListPage(category: category, sort: sort);
  },
),
```

## Test Fake

```dart
class FakeNavigator implements AppNavigator {
  final List<String> calls = [];

  @override
  void go(String path, {Object? extra}) => calls.add('go:$path');

  @override
  void push(String path, {Object? extra}) => calls.add('push:$path');

  @override
  void pop<T extends Object?>([T? result]) => calls.add('pop');

  @override
  bool canPop() => calls.isNotEmpty;

  @override
  void goHome() => calls.add('goHome');

  @override
  void goSignIn() => calls.add('goSignIn');

  @override
  void goPostList() => calls.add('goPostList');

  @override
  void pushPostDetail(int postId, {Object? extra}) =>
      calls.add('pushPostDetail:$postId');

  @override
  void goProfile() => calls.add('goProfile');

  @override
  void goSettings() => calls.add('goSettings');
}
```
