# Feature — DI Module and Page

DI module registration and page widget for a feature slice.

## `lib/src/features/home/di/home_module.dart`

```dart
import 'package:get_it/get_it.dart';
import '../../../core/logging/app_logger.dart';
import '../data/home_repository_impl.dart';
import '../domain/home_repository.dart';
import '../presentation/cubit/home_cubit.dart';

void registerHomeModule(GetIt getIt) {
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(logger: getIt<AppLogger>()),
  );
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      repository: getIt<HomeRepository>(),
      logger: getIt<AppLogger>(),
    ),
  );
}
```

## `lib/src/features/home/presentation/pages/home_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/common/app_list_tile.dart';
import '../../../../core/widgets/common/app_top_bar.dart';
import '../../../../core/widgets/loading/screen_loading.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) => getIt<HomeCubit>()..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Home', showBack: false),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => switch (state) {
          HomeInitial() || HomeLoading() => const ScreenLoading(),
          HomeEmpty() => const Center(child: Text('No greetings')),
          HomeError(:final failure) =>
            Center(child: Text(failure.message)),
          HomeLoaded(:final greetings) => ListView(
              children: [for (final g in greetings) AppListTile(title: g)],
            ),
        },
      ),
    );
  }
}
```

## Rules

- **Repository is `registerLazySingleton`** — one instance per app lifetime, shared across cubits that need the same data.
- **Cubit is `registerFactory`** — fresh instance per screen visit, no state leakage between navigations.
- **`registerHomeModule` is called from `configureDependencies()`** in `service_locator.dart` — the composition root is the only place that calls module functions.
- **`BlocProvider` at the page boundary** — `getIt<HomeCubit>()` is resolved only in `HomePage.build`, never deeper in the widget tree.
- **`..load()` on create** — triggers the initial fetch immediately when the page is pushed.
- Only `home_module.dart` imports `HomeRepositoryImpl` — all other files import the `HomeRepository` interface.
