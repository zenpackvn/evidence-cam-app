# Forms — DI Registration

## `lib/src/features/registration/di/registration_module.dart`

```dart
import 'package:get_it/get_it.dart';

import '../domain/registration_repository.dart';
import '../data/registration_repository_impl.dart';
import '../presentation/registration_cubit.dart';

void registerRegistrationModule(GetIt di) {
  di.registerLazySingleton<RegistrationRepository>(
    () => RegistrationRepositoryImpl(apiClient: di()),
  );

  // Factory — never singleton for cubits.
  di.registerFactory<RegistrationCubit>(
    () => RegistrationCubit(registrationRepository: di()),
  );
}
```

**Rule: Form cubits are always `registerFactory`, never singletons.** Each form instance gets a fresh cubit with clean initial state. A singleton cubit would carry stale form state between visits to the form screen.
