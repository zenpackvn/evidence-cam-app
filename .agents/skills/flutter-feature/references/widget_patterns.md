# Feature — Widget Architecture and Form Patterns

## Widget Architecture

- Extract non-trivial UI into widget classes instead of large private builder methods.
- Propagate `const` wherever natural — `const` constructors enable Flutter to skip widget rebuilds.
- Keep rebuild scope tight by moving state-dependent UI into smaller widgets or `BlocSelector`.
- Reuse shared UI primitives (`AppButton`, `AppCard`, `AppTextField`) before creating new ones.
- Split the page into a top-level `BlocProvider` entry widget and a private `_View` widget — the `_View` never accesses `getIt` directly.

## Forms and Validation

- Keep simple form state local unless async coordination or business rules justify a cubit.
- Separate sync validation, async availability checks (username taken), and submission state into distinct operations.
- Map server validation errors into field-level state — emit a cubit state that carries `Map<String, String> fieldErrors`.
- Disable duplicate submissions while a request is in flight — `LoadingButton(isLoading: state is SubmittingState)`.
- Scope text controllers, focus nodes, and input formatters to the `StatefulWidget` that owns them; dispose all in `dispose()`.
