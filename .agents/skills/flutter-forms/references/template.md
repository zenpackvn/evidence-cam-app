# Template — Forms

Multi-step forms, validation framework, and form state management. Form logic lives in cubits; validation is a pure function layer; no third-party form libraries required.

## Topic Files

| Topic | File |
|---|---|
| Folder structure | [folder_structure.md](folder_structure.md) |
| Core validation framework (`FormValidator`, `FormFieldState`, `FormMixin`) | [core_validation_framework.md](core_validation_framework.md) |
| Single-page form example (Login: state, cubit, page) | [single_page_form.md](single_page_form.md) |
| Multi-step wizard (Registration: state, validator, cubit, repository, pages) | [multi_step_form.md](multi_step_form.md) |
| Async validation + state restoration (HydratedCubit) | [async_validation_and_restoration.md](async_validation_and_restoration.md) |
| DI registration | [di_registration.md](di_registration.md) |
| Testing (validator unit tests, cubit bloc_test, step navigation) | [testing.md](testing.md) |
| Rules and anti-patterns | [rules_and_antipatterns.md](rules_and_antipatterns.md) |

## ⚠️ Common Mistakes

> These are the most frequent forms bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Validation logic inside the widget** | `setState` calls scattered in `onChanged` callbacks; validation duplicated across rebuild cycles | Move all validation into the cubit using pure `Validator<T>` functions and `composeValidators`; widget only reads `state.field.shouldShowError` |
| 2 | **Showing errors on pristine fields** | User opens the form and immediately sees red error text before typing anything | Only render `errorText` when `FormFieldState.shouldShowError` is true (i.e., `isTouched && error != null`); never bind directly to `state.field.error` |
| 3 | **Raw error strings instead of localization keys** | Hardcoded English messages like `'Email is required'` appear in the UI; breaks localization | Validators must return localization keys (e.g., `'validation.required'`); translate in the widget layer via `context.tr(state.field.error!)` |
| 4 | **Using `GlobalKey<FormState>` for validation** | `_formKey.currentState!.validate()` runs Flutter's built-in validators, bypassing the cubit's state machine entirely | Remove the `GlobalKey`; call `cubit.submit()` instead — the cubit validates all fields, marks them touched, and emits the appropriate state |
| 5 | **Form cubit registered as singleton** | Second open of the form shows stale values or previous submission errors from the prior session | Register form cubits with `registerFactory`, never `registerLazySingleton` — each form instance must get a fresh initial state |
| 6 | **Allowing step advancement without validation** | User skips required fields by tapping a later step in the wizard stepper | `nextStep()` must call the current step's validator and block forward navigation until valid; back navigation remains free unconditionally |
| 7 | **Not disposing `TextEditingController` and `FocusNode`** | Memory leak reported by `leak_tracker`; stale listeners fire after the widget is removed from the tree | Override `dispose()` in the `State` class and call `.dispose()` on every controller and focus node created in `initState` |
| 8 | **Server validation errors not mapped to field state** | API returns `{"errors": {"email": "already taken"}}` but the form shows a generic snackbar instead of a field-level message | In the cubit's catch block, parse the server error map and call `emit(state.copyWith(email: state.email.copyWith(error: () => serverMsg)))` per field; clear the field error when the user edits that field |

## Quick Summary

- **Form state in cubit, not widget** — `TextEditingController` / `FocusNode` in the widget; validation state and submission logic in the cubit.
- **Pure validators** — `composeValidators` wires built-in validators together; return localization keys, not raw strings. Async validation is a separate debounced cubit method.
- **Touched-before-error** — `FormFieldState.shouldShowError` is true only after `isTouched`. Mark touched on focus-lost or on submit attempt.
- **Validate step before advancing** — `nextStep()` blocks until the current step is valid. Back navigation is always free.
- **Sealed states** — `FormData` for editing, `FormSuccess` for completion. No boolean-as-state-machine.
- **Factory cubits always** — `registerFactory`, never singleton. Each form instance gets fresh initial state.
- **No third-party form libraries** — Flutter `Form` + `TextEditingController` + cubit is sufficient.

## Cross-references

- [template-feature-example.md](template-feature-example.md) — Cubit/state/repository pattern
- [template-state-restoration.md](template-state-restoration.md) — HydratedCubit for form persistence across process death
- [template-di.md](template-di.md) — Factory registration for form cubits
- [template-localization.md](template-localization.md) — Translate validation error keys to user-facing strings
- [template-common-widgets.md](template-common-widgets.md) — AppTextField, AppButton used in form pages
- [template-network.md](template-network.md) — Failure hierarchy for server-side validation errors
- [template-accessibility.md](template-accessibility.md) — Error announcements, focus management for form fields
