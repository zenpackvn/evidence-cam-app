# Network Anti-Patterns

## 1. Catching `DioException` in the UI layer instead of mapping to `Failure` at the boundary

**DON'T**

```dart
// In a Cubit or Widget
try {
  final response = await dio.get('/users');
  emit(Loaded(response.data));
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    emit(Error('Unauthorized'));
  }
}
```

**DO**

```dart
// Repository maps to Failure; Cubit only knows about Failure
try {
  final users = await userRepository.getUsers();
  emit(Loaded(users));
} on FailureException catch (e) {
  emit(Error(e.failure.message));
}
```

---

## 2. Hardcoding base URLs instead of using env config

**DON'T**

```dart
final dio = Dio(BaseOptions(baseUrl: 'https://api.prod.example.com'));
```

**DO**

```dart
final dio = Dio(BaseOptions(baseUrl: config.apiBaseUrl));
// config comes from EnvConfig / AppConfig injected via DI
```

---

## 3. Creating new `Dio` instances per request instead of sharing a configured client

**DON'T**

```dart
Future<UserDto> fetchUser(String id) async {
  final dio = Dio(); // new instance every call — no interceptors, no timeouts
  final response = await dio.get('https://api.example.com/users/$id');
  return UserDto.fromJson(response.data);
}
```

**DO**

```dart
class UserRemoteDataSource {
  UserRemoteDataSource(this._apiClient); // Retrofit client from DI
  final ApiClient _apiClient;

  Future<UserDto> fetchUser(int id) => _apiClient.getUser(id);
  // Retrofit returns UserDto directly — no manual fromJson needed
}
```

---

## 4. Leaking raw `Map<String, dynamic>` into domain / presentation

**DON'T**

```dart
class UserRepository {
  Future<Map<String, dynamic>> getUser(String id) async {
    final response = await _dio.get('/users/$id');
    return response.data as Map<String, dynamic>; // raw map escapes data layer
  }
}
```

**DO**

```dart
class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._dataSource);
  final UserRemoteDataSource _dataSource;

  @override
  Future<User> getUser(int id) async {
    final dto = await _dataSource.fetchUser(id); // DTO from Retrofit
    return dto.toEntity(); // domain entity, no transport details
  }
}
```

---

## 5. Not cancelling requests when the widget / bloc is disposed

**DON'T**

```dart
class SearchCubit extends Cubit<SearchState> {
  Future<void> search(String query) async {
    final results = await _repo.search(query); // previous request still in-flight
    emit(Loaded(results));
  }
}
```

**DO**

```dart
class SearchCubit extends Cubit<SearchState> {
  CancelToken? _cancelToken;

  Future<void> search(String query) async {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    try {
      final results = await _repo.search(query, cancelToken: _cancelToken!);
      emit(Loaded(results));
    } on FailureException catch (e) {
      emit(Error(e.failure.message));
    }
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel();
    return super.close();
  }
}
```

---

## 6. Ignoring certificate pinning in production

**DON'T**

```dart
// Shipping to prod with no certificate validation
final dio = Dio();

// Hardcoding pins in the interceptor — not configurable per flavor
static const _pinnedSha256 = <String>{'AAAA...='};
```

**DO**

```dart
// SecurityInterceptor is instance-based, registered in DI, injected into buildDio
// Pins configured per flavor in EnvConfig (enableSslPinning + sslPins)
// Bypasses when enableSslPinning is false or sslPins is empty
security.apply(dio);
```

See `flutter-security` skill for full `SecurityInterceptor` implementation.
