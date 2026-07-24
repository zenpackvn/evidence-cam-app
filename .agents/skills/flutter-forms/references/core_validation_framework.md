# Forms — Core Validation Framework

Pure validation functions and field state model. No side effects, no third-party form libraries.

## `lib/src/core/forms/form_validator.dart`

```dart
/// Pure validation functions — no side effects, no dependencies.
/// Returns null when valid, error message key when invalid.
typedef Validator<T> = String? Function(T? value);

/// Compose multiple validators into one. Runs in order, returns first error.
Validator<T> composeValidators<T>(List<Validator<T>> validators) {
  return (value) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  };
}

// ── Built-in validators ──────────────────────────────────────────────

Validator<String> isRequired({String key = 'validation.required'}) {
  return (value) => (value == null || value.trim().isEmpty) ? key : null;
}

Validator<String> minLength(int min, {String key = 'validation.min_length'}) {
  return (value) => (value != null && value.length < min) ? key : null;
}

Validator<String> maxLength(int max, {String key = 'validation.max_length'}) {
  return (value) => (value != null && value.length > max) ? key : null;
}

Validator<String> pattern(RegExp regex, {String key = 'validation.invalid_format'}) {
  return (value) => (value != null && !regex.hasMatch(value)) ? key : null;
}

Validator<String> email({String key = 'validation.invalid_email'}) {
  final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return pattern(regex, key: key);
}

Validator<String> match(String Function() otherValue, {String key = 'validation.no_match'}) {
  return (value) => (value != otherValue()) ? key : null;
}

Validator<String> phoneNumber({String key = 'validation.invalid_phone'}) {
  final regex = RegExp(r'^\+?[\d\s\-()]{7,15}$');
  return pattern(regex, key: key);
}
```

---

## `lib/src/core/forms/form_field_state.dart`

```dart
/// Immutable state for a single form field.
/// Tracks value, validation error, and dirty/touched flags.
class FormFieldState<T> {
  const FormFieldState({
    this.value,
    this.error,
    this.isDirty = false,
    this.isTouched = false,
  });

  final T? value;

  /// Localization key for the error, or null if valid.
  final String? error;

  /// True after the user has changed the value.
  final bool isDirty;

  /// True after the field has lost focus at least once.
  final bool isTouched;

  bool get isValid => error == null;

  /// Show error only after the user has interacted.
  bool get shouldShowError => isTouched && error != null;

  FormFieldState<T> copyWith({
    T? value,
    String? Function()? error,
    bool? isDirty,
    bool? isTouched,
  }) {
    return FormFieldState<T>(
      value: value ?? this.value,
      error: error != null ? error() : this.error,
      isDirty: isDirty ?? this.isDirty,
      isTouched: isTouched ?? this.isTouched,
    );
  }
}
```

---

## `lib/src/core/forms/form_mixin.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

/// Mixin for cubits that manage form state.
/// Provides field update, validation, and submission lifecycle.
mixin FormMixin<S> on Cubit<S> {
  /// Validate all fields. Override in concrete cubit.
  S validateAll(S state);

  /// Whether all fields in the current state are valid. Override in concrete cubit.
  bool isFormValid(S state);

  /// Debounce duration for field-level validation.
  Duration get validationDebounce => const Duration(milliseconds: 300);
}
```

---

## Rules

- **Pure validators** — All validation functions are pure (no async, no DI). Compose them with `composeValidators`. Async validation is a separate cubit method.
- **Validation keys, not strings** — Error messages are localization keys (`'validation.required'`), not user-facing strings. Translate in the widget layer.
- **Touched-before-error** — Only show `error` when `isTouched` is true. Mark a field touched when it loses focus, or mark all fields touched on submit.
