# Test Override Pattern

Tests reset `getIt` between cases and register fakes.

## Basic override

```dart
setUp(() async {
  await getIt.reset();
  getIt.registerSingleton<AppLogger>(_FakeLogger());
  getIt.registerSingleton<ProfileRepository>(_FakeProfileRepository());
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt<ProfileRepository>()),
  );
});
```

For bloc tests, prefer passing fakes directly into the constructor instead of resolving from `getIt`, so the test exercises the bloc in isolation. See [template-tests.md](template-tests.md) for full examples.
