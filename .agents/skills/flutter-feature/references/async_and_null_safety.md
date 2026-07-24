# Feature — Async and Null Safety Patterns

## Async Patterns

- Run independent async operations concurrently with `Future.wait([...])` instead of awaiting sequentially.
- After any `await` inside a `StatefulWidget` method, check `mounted` before using `context` or calling `setState`.
- Keep async orchestration in cubits or services, not deep in widgets or repositories.
- Surface retryable failures clearly — emit an error state with a `retry` callback, not a silent empty state.
- Guard overlapping async work: if a user can trigger the same action twice, debounce or use a `_isLoading` flag in the cubit.
- Use `safeEmit()` (from `BaseCubit` / `SafeEmitMixin`) after every `await` — raw `emit()` after an `await` throws if the cubit was closed during the gap.

## Null Safety Patterns

- Avoid `!` unless the value is guaranteed by construction and the guarantee is obvious from nearby code.
- Prefer early returns, `?.`, `??`, and pattern matching to unwrap nullable values.
- Use `late` only when initialization is guaranteed before first read (e.g. `initState` → `build`).
- Prefer explicit empty and error states over nullable state that hides meaning — `HomeEmpty()` is clearer than `HomeLoaded(null)`.
- Use `required` constructor parameters instead of nullable ones whenever the parameter has no valid absent value.
