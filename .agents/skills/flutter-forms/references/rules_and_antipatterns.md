# Forms — Rules and Anti-Patterns

## Rules

1. **Form state in cubit, not widget** — `TextEditingController` and `FocusNode` live in the widget; validation state and submission logic live in the cubit.
2. **Pure validators** — All validation functions are pure (no async, no DI). Compose them with `composeValidators`. Async validation (email availability) is a separate cubit method.
3. **Validate on unfocus** — All `AppTextField`, `AppPasswordField`, and `AppTextArea` use `AutovalidateMode.onUnfocus`. This means: no error shown while the user is typing for the first time; error appears (and re-validates) every time the field loses focus. Never use `AutovalidateMode.always` (validates on every keystroke, distracting) or `AutovalidateMode.disabled` (requires manual trigger).
4. **Touched-before-error** — For cubit-owned field state (`FormFieldState`), mirror the same rule: only show `error` when `isTouched` is true. Mark a field touched when it loses focus, or mark all fields touched on submit.
5. **Validate step before advancing** — Multi-step forms must validate the current step before allowing `nextStep()`. Back navigation is always free.
6. **Server error mapping** — Map API field errors to `FormFieldState.error` by field name. Clear server errors when the user edits the field.
7. **Sealed states** — Form state is a sealed class. `FormData` for editing, `FormSuccess` for completion. No booleans-as-state-machines.
8. **Factory cubits** — Form cubits are registered as `registerFactory`, never singletons. Each form instance gets a fresh cubit.
9. **Validation keys, not strings** — Error messages are localization keys (`'validation.required'`), not user-facing strings. Translate in the widget layer using the localization template.
10. **Dispose controllers** — Every `TextEditingController` and `FocusNode` must be disposed in the widget's `dispose()`.
11. **No third-party form libraries** — Flutter's `Form` + `TextEditingController` + cubit state is sufficient. No `formz`, `reactive_forms`, or similar packages.

---

## Anti-Patterns

### DON'T — Put validation logic in the widget

```dart
// BAD: validation scattered in build method
TextField(
  onChanged: (v) {
    if (v.isEmpty) setState(() => error = 'Required');
    else if (!v.contains('@')) setState(() => error = 'Invalid email');
  },
)
```

### DO — Validate in the cubit via pure functions

```dart
// GOOD: cubit owns validation
void emailChanged(String value) {
  final error = _emailValidator(value);
  emit(state.copyWith(email: state.email.copyWith(value: value, error: () => error)));
}
```

---

### DON'T — Show errors immediately on pristine fields

```dart
// BAD: user sees errors before typing anything
errorText: state.email.error, // shows on first render
```

### DO — Only show errors after touch

```dart
// GOOD: respect touched state
errorText: state.email.shouldShowError ? state.email.error : null,
```

---

### DON'T — Use a GlobalKey<FormState> for validation

```dart
// BAD: Flutter's FormState.validate() bypasses cubit
final _formKey = GlobalKey<FormState>();
if (_formKey.currentState!.validate()) { ... }
```

### DO — Drive validation from cubit state

```dart
// GOOD: cubit is the single source of truth
cubit.submit(); // validates internally, emits new state
```

---

### DON'T — Allow skipping steps in a wizard

```dart
// BAD: jump to any step without validation
onStepTapped: (step) => cubit.goToStep(step), // no guards
```

### DO — Validate intermediate steps before allowing forward navigation

```dart
// GOOD: goToStep validates all steps between current and target
cubit.goToStep(step); // validates steps [current..step-1] before advancing
```
