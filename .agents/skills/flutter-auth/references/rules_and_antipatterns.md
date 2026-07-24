# Auth — Rules & Anti-Patterns

## Rules

1. **Token refresh must handle race conditions** — multiple concurrent 401 responses trigger a single refresh. `QueuedInterceptor` + `Completer` guarantee this.
2. **Never store tokens in `SharedPreferences`** — use `SecureStorage` only (Keychain on iOS, EncryptedSharedPreferences on Android).
3. **`AuthCubit` is a singleton** (global auth state, lives for app lifetime). **`SignInCubit` is a factory** (new instance per screen visit).
4. **Biometric auth is opt-in** — always call `isAvailable()` before showing the option. Never assume hardware support.
5. **On refresh failure, force logout** — clear tokens, emit `unauthenticated`, router guard redirects to sign-in.
6. **Never expose raw JWT tokens to the presentation layer** — cubits and pages interact with `AuthService` methods, not tokens directly.
7. **Only `auth_service_impl.dart`** coordinates token storage and API calls. Only **`biometric_service_impl.dart`** imports `package:local_auth`. The wrapper rule applies.
8. **`AuthInterceptor` skips refresh for the refresh endpoint itself** — prevents infinite 401 → refresh → 401 loops.
9. **Seed auth status at startup** — call `checkInitialAuthStatus()` in `configureDependencies()` before `runApp` so the router guard has a known state on first frame.

---

## Anti-Patterns

### 1. Storing tokens in SharedPreferences instead of SecureStorage

**DON'T** — SharedPreferences stores values in plaintext XML/plist, readable by any process with device access:

```dart
// BAD: tokens stored in plaintext
final prefs = await SharedPreferences.getInstance();
await prefs.setString('access_token', token);
```

**DO** — Use SecureStorage (Keychain on iOS, EncryptedSharedPreferences on Android):

```dart
// GOOD: tokens stored in platform-encrypted storage
await _secureStorage.write('access_token', token);
```

---

### 2. Not handling concurrent token refresh (race condition)

**DON'T** — Every 401 triggers its own refresh, causing duplicate refresh calls and token invalidation:

```dart
// BAD: multiple concurrent 401s each call refreshToken independently
@override
Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
  if (err.response?.statusCode == 401) {
    await _authService.refreshToken(); // N concurrent 401s = N refresh calls
    final response = await _dio.fetch(err.requestOptions);
    handler.resolve(response);
  }
}
```

**DO** — Use a `Completer` so concurrent 401s share a single refresh:

```dart
// GOOD: first 401 starts the refresh; subsequent 401s await the same future
Completer<bool>? _refreshCompleter;

Future<bool> _tryRefresh() async {
  if (_refreshCompleter != null) return _refreshCompleter!.future;

  _refreshCompleter = Completer<bool>();
  try {
    await _authService.refreshToken();
    _refreshCompleter!.complete(true);
    return true;
  } catch (_) {
    _refreshCompleter!.complete(false);
    return false;
  } finally {
    _refreshCompleter = null;
  }
}
```

---

### 3. Checking auth state in widgets instead of using a router guard

**DON'T** — Scatter auth checks across individual pages; easy to forget, inconsistent behavior:

```dart
// BAD: every page manually checks auth
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state is AuthUnauthenticated) {
      return const SignInPage(); // ad-hoc redirect
    }
    return const ProfileView();
  }
}
```

**DO** — Centralise auth gating in the router guard; pages never think about auth:

```dart
// GOOD: single redirect function in GoRouter handles all auth gating
static String? _guard(BuildContext context, GoRouterState state) {
  final authState = getIt<AuthCubit>().state;
  final isOnSignIn = state.matchedLocation == RoutePaths.signIn;

  if (authState is AuthUnauthenticated && !isOnSignIn) return RoutePaths.signIn;
  if (authState is AuthAuthenticated && isOnSignIn) return RoutePaths.home;
  return null;
}
```

---

### 4. Hardcoding token expiry checks instead of using interceptor

**DON'T** — Manually check token validity before every API call in feature code:

```dart
// BAD: expiry logic duplicated in every repository method
Future<List<Post>> getPosts() async {
  final token = await _tokenManager.getAccessToken();
  final isExpired = _checkIfExpired(token); // duplicated everywhere
  if (isExpired) {
    await _authService.refreshToken();
  }
  return _apiClient.getPosts();
}
```

**DO** — Let `AuthInterceptor` handle expiry transparently; feature code just calls the API:

```dart
// GOOD: interceptor auto-refreshes on 401; repositories are unaware of tokens
Future<List<Post>> getPosts() async {
  return _apiClient.getPosts(); // interceptor handles auth headers + refresh
}
```
