# Anti-Patterns — DI

## 1. Calling `getIt<T>()` inside a bloc/cubit constructor or `build()` method

**DON'T do this** — it hides dependencies, makes testing painful, and couples business logic to the service locator.

```dart
// WRONG
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial()) {
    _repo = getIt<ProfileRepository>(); // hidden dependency
  }
  late final ProfileRepository _repo;
}
```

```dart
// RIGHT — inject via constructor
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repo) : super(ProfileInitial());
  final ProfileRepository _repo;
}

// Resolution happens once, at the composition boundary:
// BlocProvider(create: (_) => getIt<ProfileCubit>())
```

## 2. Registering blocs/cubits as singletons

**DON'T do this** — state leaks across screens; a cubit still holds the previous screen's data when navigated back.

```dart
// WRONG
getIt.registerLazySingleton<HomeCubit>(
  () => HomeCubit(getIt<HomeRepository>()),
);
```

```dart
// RIGHT — blocs and cubits are always factories
getIt.registerFactory<HomeCubit>(
  () => HomeCubit(getIt<HomeRepository>()),
);
```

## 3. Importing third-party packages directly instead of through wrappers

**DON'T do this** — it scatters vendor coupling across the codebase, making swaps, fakes, and upgrades expensive.

```dart
// WRONG — feature code imports the package directly
import 'package:logger/logger.dart';

class OrderRepository {
  final Logger _logger = Logger(); // direct third-party usage
}
```

```dart
// RIGHT — depend on the app-owned interface
import '../core/logging/app_logger.dart';

class OrderRepository {
  OrderRepository(this._logger);
  final AppLogger _logger;
}
```

## 4. Scattered registrations outside the composition root

**DON'T do this** — it makes the dependency graph invisible; you can never tell what is registered, in what order, or with what lifetime.

```dart
// WRONG — registration buried inside a widget or feature file
class SettingsPage extends StatelessWidget {
  SettingsPage() {
    // side-effect in a constructor
    getIt.registerLazySingleton<SettingsRepo>(() => SettingsRepoImpl());
  }
}
```

```dart
// RIGHT — all registrations flow from configureDependencies()
// lib/src/core/di/service_locator.dart
Future<void> configureDependencies(Env env) async {
  // ...infrastructure...
  registerSettingsModule(getIt);
}
```

## 5. Using service locator as a global variable instead of constructor injection

**DON'T do this** — it turns every class into a service-locator consumer, defeating the point of DI and making unit tests require a full container reset.

```dart
// WRONG — repository reaches into the locator at will
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<User> signIn(String email, String password) async {
    final client = getIt<ApiClient>();   // service location
    final storage = getIt<SecureStorage>(); // service location
    // ...
  }
}
```

```dart
// RIGHT — dependencies declared up front
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.client, required this.storage});
  final ApiClient client;
  final SecureStorage storage;

  @override
  Future<User> signIn(String email, String password) async {
    // uses this.client and this.storage directly
  }
}
```

**Same rule applies to inner page widgets** — the *outer* page widget (the one the router creates) is allowed to call `getIt` because it IS the composition root for its sub-tree. Inner widgets must receive dependencies via constructor.

```dart
// WRONG — inner widget calls getIt inside a callback
class _SignInViewState extends State<_SignInView> {
  void _onStateChanged(BuildContext context, SignInState state) {
    if (state is SignInError) {
      getIt<AppDialog>().showNotification(...); // ← service location in inner widget
    }
  }
}
```

```dart
// RIGHT — outer page resolves, inner widget receives via constructor
class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInCubit>(
      create: (_) => getIt<SignInCubit>(),
      child: _SignInView(dialog: getIt<AppDialog>()), // ← resolved at composition root
    );
  }
}

class _SignInView extends StatefulWidget {
  const _SignInView({required this.dialog});
  final AppDialog dialog;
  // ... uses this.dialog directly, never getIt
}
```

## 6. Circular dependencies between DI modules

**DON'T do this** — it creates initialization deadlocks or fragile ordering requirements that break silently when modules change.

```dart
// WRONG — auth module needs profile, profile module needs auth
void registerAuthModule(GetIt getIt) {
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(profile: getIt<ProfileRepository>()), // needs profile
  );
}
void registerProfileModule(GetIt getIt) {
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(auth: getIt<AuthRepository>()), // needs auth
  );
}
```

```dart
// RIGHT — break the cycle with a shared abstraction or event bus
void registerSessionModule(GetIt getIt) {
  getIt.registerLazySingleton<SessionStore>(() => SessionStoreImpl());
}
void registerAuthModule(GetIt getIt) {
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(session: getIt<SessionStore>()),
  );
}
void registerProfileModule(GetIt getIt) {
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(session: getIt<SessionStore>()),
  );
}
```

## Review signals

Flag in code review:

- `import 'package:logger/` or `import 'package:dio/` outside `lib/src/core/**`.
- `getIt<T>()` inside a widget `build()`, bloc, cubit, use case, or repository.
- `GetIt.I.register...` outside `lib/src/core/di/` or `lib/src/features/*/di/`.
- Bloc or cubit registered as `registerLazySingleton` (should be `registerFactory`).
- A new third-party plugin introduced without an app-owned wrapper interface.
- Tests that depend on the production DI graph without `getIt.reset()` and explicit fake registration.
