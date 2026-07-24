# Forms — Async Validation and State Restoration

## Async validation (e.g., email availability check)

```dart
/// In the cubit — debounced async check.
Timer? _emailDebounce;

void emailChanged(String value) {
  // Sync validation first.
  _updateStringField(/* ... */);

  // Then async check.
  _emailDebounce?.cancel();
  _emailDebounce = Timer(const Duration(milliseconds: 500), () {
    _checkEmailAvailability(value);
  });
}

Future<void> _checkEmailAvailability(String email) async {
  final current = state;
  if (current is! RegistrationForm) return;
  if (current.email.error != null) return; // Skip if sync-invalid.

  try {
    final available = await registrationRepository.isEmailAvailable(email);
    if (!available) {
      final form = current.copyWith(
        email: current.email.copyWith(
          error: () => 'registration.email_taken',
        ),
      );
      emit(form);
    }
  } on Exception {
    // Network error — don't block the user, server will validate on submit.
  }
}

@override
Future<void> close() {
  _emailDebounce?.cancel();
  return super.close();
}
```

**Rules:**
- Run sync validation first; only kick off the async check if the field passes sync validation.
- Cancel the debounce timer in `close()` to avoid emit-after-close errors.
- Network errors in async validation should be swallowed silently — the server validates on submit.

---

## Form state restoration (HydratedCubit)

Combine with [state-restoration template](../../flutter-state-restoration/references/template.md) for process death survival:

```dart
/// Use HydratedCubit for automatic form persistence.
class RegistrationCubit extends HydratedCubit<RegistrationState>
    with FormMixin<RegistrationState> {

  @override
  RegistrationState fromJson(Map<String, dynamic> json) {
    return RegistrationForm(
      currentStep: json['step'] as int? ?? 0,
      firstName: FormFieldState<String>(value: json['firstName'] as String?),
      lastName: FormFieldState<String>(value: json['lastName'] as String?),
      email: FormFieldState<String>(value: json['email'] as String?),
      phone: FormFieldState<String>(value: json['phone'] as String?),
      street: FormFieldState<String>(value: json['street'] as String?),
      city: FormFieldState<String>(value: json['city'] as String?),
      zipCode: FormFieldState<String>(value: json['zipCode'] as String?),
      country: FormFieldState<String>(value: json['country'] as String?),
    );
  }

  @override
  Map<String, dynamic> toJson(RegistrationState state) {
    if (state is! RegistrationForm) return {};
    return {
      'step': state.currentStep,
      'firstName': state.firstName.value,
      'lastName': state.lastName.value,
      'email': state.email.value,
      'phone': state.phone.value,
      'street': state.street.value,
      'city': state.city.value,
      'zipCode': state.zipCode.value,
      'country': state.country.value,
    };
  }
}
```
