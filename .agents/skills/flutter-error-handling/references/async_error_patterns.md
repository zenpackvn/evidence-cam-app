# Async Error Patterns

## DON'T — Fire-and-forget without error handling

```dart
// BAD: if fetchData() throws, it becomes a zone error
// with no context about what triggered it.
void initState() {
  super.initState();
  fetchData(); // unawaited!
}
```

## DO — Await or handle errors explicitly

```dart
// GOOD: errors are caught and handled in the cubit
Future<void> loadData() async {
  emit(const PostsLoading());
  try {
    final posts = await _repository.getPosts();
    emit(PostsLoaded(posts));
  } on FailureException catch (e) {
    emit(PostsError(e.failure));
  }
}
```

## DON'T — Swallow errors silently

```dart
// BAD: error is lost — no logging, no reporting
try {
  await dangerousOperation();
} catch (_) {
  // silently ignored
}
```

## DO — Log and report even if you recover

```dart
// GOOD: error is handled but still visible for debugging
try {
  await dangerousOperation();
} catch (e, s) {
  getIt<ErrorHandler>().handleError(e, s, reason: 'dangerousOperation fallback');
  // Recover gracefully
  return fallbackValue;
}
```

## DON'T — Catch errors in widgets and ignore the handler

```dart
// BAD: error is "handled" locally but never reported
try {
  await riskyOperation();
} catch (e) {
  setState(() => hasError = true);
}
```

## DO — Report through ErrorHandler even when recovering

```dart
// GOOD: error is visible in crash reports for debugging
try {
  await riskyOperation();
} catch (e, s) {
  getIt<ErrorHandler>().handleError(e, s, reason: 'riskyOperation in MyWidget');
  setState(() => hasError = true);
}
```
