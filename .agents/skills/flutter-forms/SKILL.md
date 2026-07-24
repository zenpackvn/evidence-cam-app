---
name: flutter-forms
description: Use this skill when building Flutter forms — form validation, multi-step wizard, FormFieldState, form controllers, input validation, composeValidators, pure validators, async validation, server-side error mapping, form state persistence, form restoration, required field validation, email validation, password validation, or any user input form.
---

# Flutter Forms

Full reference: [`template.md`](references/template.md)

## Key rules

- `FormFieldState<T>` is the value object for a single field — holds `value`, `isDirty`, `isTouched`, `error`. It is immutable and `const`-constructible.
- Validators are **pure functions**: `String? Function(T? value)`. No side effects.
- Compose validators with `composeValidators([required, minLength(8), ...])` — returns the first non-null error.
- Validators return localized strings — look up keys from `LocalizationService`, never hardcode error text.
- Multi-step wizard: each step is a separate `TaskFormStep` enum value. The cubit owns the step index. Each step validates only its own fields before allowing `nextStep()`.
- Form cubit uses `HydratedCubit` to survive process death — `fromJson`/`toJson` persists form state. `TaskFormError` (non-recoverable) returns `null` from `toJson` to avoid restoring an error state.
- Server errors: map API error response to `FormFieldState.copyWith(error: ...)` — display inline under the field.
- No `GlobalKey<FormState>` — validation is handled in the cubit, not via Flutter's Form widget.

## Files

```
lib/src/core/forms/
  form_field_state.dart     ← immutable value object per field
  form_validator.dart       ← pure validator functions + composeValidators
lib/src/features/<feature>/
  domain/entities/          ← form entity (immutable result)
  presentation/cubit/
    <feature>_form_cubit.dart   ← HydratedCubit, step management, validation
    <feature>_form_state.dart   ← sealed states (Editing, Submitted, Error)
```

## Co-load with

- `flutter-base-classes` — BaseCubit, sealed states
- `flutter-localization` — validator error strings must be localized
- `flutter-state-restoration` — `HydratedCubit` for form persistence
- `flutter-common-widgets` — `AppTextField` for the UI fields
