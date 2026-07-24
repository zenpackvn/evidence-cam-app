# BLoC/Cubit State Restoration

Flutter's `RestorationMixin` is widget-level. BLoC/Cubit state lives outside the widget tree. Two approaches:

## Approach 1: Hydrated BLoC (Recommended for Simple State)

Use `hydrated_bloc` — persists cubit state to disk automatically. Survives both process death and full app restarts.

```yaml
# pubspec.yaml
dependencies:
  hydrated_bloc: 9.1.5
  path_provider: 2.1.4
```

```dart
// lib/src/app/bootstrap/app_bootstrap.dart

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> bootstrap(Env env) async {
  // Initialize HydratedBloc storage BEFORE configureDependencies.
  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  HydratedBloc.storage = storage;

  await configureDependencies(env);
  // ... rest of bootstrap
}
```

```dart
// lib/src/features/settings/cubit/settings_cubit.dart
//
// Extend BaseHydratedCubit — never import hydrated_bloc directly in
// feature cubits. The wrapper lives in core/base/base_hydrated_cubit.dart.

import '../../../../core/base/base_hydrated_cubit.dart';

class SettingsCubit extends BaseHydratedCubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void toggleDarkMode() {
    safeEmit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  void setLocale(String languageCode) {
    safeEmit(state.copyWith(languageCode: languageCode));
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    try {
      return SettingsState(
        isDarkMode: json['isDarkMode'] as bool? ?? false,
        languageCode: json['languageCode'] as String? ?? 'en',
      );
    } on Object catch (e, s) {
      // Corrupt or outdated JSON — reset to defaults rather than crash.
      logger.warn('SettingsCubit: corrupt restoration data', error: e, stackTrace: s);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return {
      'isDarkMode': state.isDarkMode,
      'languageCode': state.languageCode,
    };
  }
}
```

```dart
// lib/src/features/settings/cubit/settings_state.dart

import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.isDarkMode = false,
    this.languageCode = 'en',
  });

  final bool isDarkMode;
  final String languageCode;

  SettingsState copyWith({bool? isDarkMode, String? languageCode}) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [isDarkMode, languageCode];
}
```

## Approach 2: Manual Cubit Restoration (For Complex State)

For cubits where you want selective restoration — e.g., restore filter selection but re-fetch data.

```dart
// lib/src/core/restoration/restorable_cubit_state.dart

import '../storage/key_value_store.dart';

/// Mixin for cubits that need to persist and restore selected fields.
mixin RestorableCubitState {
  KeyValueStore get storage;
  String get restorationKey;

  /// Save a map of restorable fields to KeyValueStore.
  Future<void> saveRestorableState(Map<String, String> fields) async {
    for (final entry in fields.entries) {
      await storage.setString('${restorationKey}_${entry.key}', entry.value);
    }
  }

  /// Read a previously saved field.
  Future<String?> readRestorableField(String field) async {
    return storage.getString('${restorationKey}_$field');
  }

  /// Clear all saved restoration state.
  Future<void> clearRestorableState(List<String> fields) async {
    for (final field in fields) {
      await storage.remove('${restorationKey}_$field');
    }
  }
}
```

```dart
// lib/src/features/posts/cubit/post_list_cubit.dart

class PostListCubit extends Cubit<PostListState>
    with RestorableCubitState {
  PostListCubit({
    required this.storage,
    required PostRepository repository,
  })  : _repository = repository,
        super(const PostListInitial());

  final PostRepository _repository;

  @override
  final KeyValueStore storage;

  @override
  String get restorationKey => 'post_list';

  Future<void> init() async {
    // Restore filter from previous session.
    final savedCategory = await readRestorableField('category');
    final category = savedCategory ?? 'all';

    emit(PostListLoading(category: category));

    try {
      final posts = await _repository.getPosts(category: category);
      emit(PostListLoaded(posts: posts, category: category));
    } on FailureException catch (e) {
      emit(PostListError(failure: e.failure, category: category));
    }
  }

  Future<void> changeCategory(String category) async {
    await saveRestorableState({'category': category});

    emit(PostListLoading(category: category));
    try {
      final posts = await _repository.getPosts(category: category);
      emit(PostListLoaded(posts: posts, category: category));
    } on FailureException catch (e) {
      emit(PostListError(failure: e.failure, category: category));
    }
  }
}
```

## What to Restore vs What to Re-Fetch

| Restore (persists across process death) | Re-fetch (reload on restore) |
|---|---|
| Form field text | API data (may be stale) |
| Scroll offset | Real-time data (chat, prices) |
| Tab/page index | Auth state (verify token still valid) |
| Filter/sort selection | Push notification badges |
| Search query text | Computed/derived state |
| Toggle states (dark mode, language) | Timestamps, counters |
| Pending user intent (deep link path) | Any data with a TTL |

**Rule of thumb**: Restore user input and navigation state. Re-fetch server data.
