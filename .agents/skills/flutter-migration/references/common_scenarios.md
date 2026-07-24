# Common Migration Scenarios

## "We use Riverpod, not BLoC"

The wrapper rule and composition-root rule are state-management agnostic. You can wrap dependencies behind interfaces and inject them into Riverpod providers the same way:

```dart
// Riverpod + wrapper rule works fine:
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(apiClient: ref.read(apiClientProvider));
});

// The interface and impl are identical to the BLoC version.
// Only the DI wiring differs.
```

Keep your existing Riverpod. Add wrappers around third-party packages. Don't adopt `get_it` unless you want to.

## "We use Provider, not BLoC"

Same principle — wrap dependencies, keep Provider:

```dart
MultiProvider(
  providers: [
    Provider<PostRepository>(
      create: (_) => PostRepositoryImpl(apiClient: getIt()),
    ),
    ChangeNotifierProvider(
      create: (context) => PostListNotifier(
        repository: context.read<PostRepository>(),
      ),
    ),
  ],
)
```

## "We don't use get_it"

You don't need `get_it` specifically. The composition-root rule means: **all service wiring happens in one place, not scattered across the app**. You can achieve this with:

- `get_it` (our default)
- Riverpod providers in one file
- Manual factory functions in a `ServiceContainer` class
- `injectable` + `get_it` with code generation

The wrapper rule is completely DI-framework-agnostic.

## "We have a monorepo with multiple packages"

Wrap at the package boundary. Each package has its own interfaces:

```
packages/
  core/          ← shared interfaces (AppLogger, SecureStorage, etc.)
  network/       ← DioClient impl, depends on core
  feature_auth/  ← depends on core (interfaces), NOT on network directly
  app/           ← composition root, wires everything together
```

Only the `app` package's composition root imports concrete implementations.

## "We already have some wrappers but they're inconsistent"

Audit them against the wrapper rule checklist:

- [ ] Interface exists in a separate file from the implementation
- [ ] Only the `*_impl.dart` file imports the third-party package
- [ ] Registered in the composition root, not scattered
- [ ] Consumed via constructor injection, not service location in business logic
- [ ] Has a fake/mock for testing

Fix any gaps incrementally.

## "We have 200+ files — this will take forever"

It won't if you do it incrementally. Realistic timeline:

| Phase | Effort | PRs |
|---|---|---|
| Phase 0: Audit | 1 hour | 0 (document only) |
| Phase 1: Foundation | 1–2 weeks | 4–6 |
| Phase 2: Features (per feature) | 2–4 hours each | 1 each |
| Phase 3: Harden | 1 week | 2–4 |

Phase 1 is the bulk of the work. After that, each feature is a focused, reviewable PR.
