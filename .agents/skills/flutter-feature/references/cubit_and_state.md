# Feature — Cubit and Sealed State

Sealed state class and cubit for a feature slice.

## `lib/src/features/home/presentation/cubit/home_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';

sealed class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => const [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeEmpty extends HomeState {
  const HomeEmpty();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.greetings);
  final List<String> greetings;
  @override
  List<Object?> get props => [greetings];
}

class HomeError extends HomeState {
  const HomeError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
```

## `lib/src/features/home/presentation/cubit/home_cubit.dart`

```dart
import '../../../../core/base/base_cubit.dart';
import '../../../../core/base/base_state.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/home_repository.dart';

class HomeCubit extends BaseCubit<List<String>> {
  HomeCubit({
    required HomeRepository repository,
    required AppLogger logger,
  })  : _repository = repository,
        super(logger: logger);

  final HomeRepository _repository;

  @override
  Future<List<String>> fetchData() => _repository.fetchGreetings();
}
```

## Rules

- **Sealed state, not booleans** — all state variants are explicit sealed subclasses extending `Equatable`. Never use `bool isLoading` or nullable fields as state flags.
- **All fields in `props`** — every subclass that carries data must override `props` and list all fields. Missing `props` breaks `BlocBuilder` change detection.
- **Cubit depends on the repository interface**, never the concrete impl. The DI module resolves the impl — see [di_and_page.md](di_and_page.md).
- **`BaseCubit<T>` for fetch flows** — override `fetchData()` only. `BaseCubit` handles the load/refresh lifecycle and `safeEmit` guard. See [flutter-base-classes](../flutter-base-classes/references/base_cubit.md) for full API.
- Cubit methods are named after **user actions** (`load`, `refresh`, `submit`), not data types.
