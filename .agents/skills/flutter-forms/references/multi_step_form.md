# Forms — Multi-Step Form (Wizard) — Registration

A complete 3-step registration wizard: state, validator, cubit, repository, and page widgets.

## `lib/src/features/registration/presentation/registration_state.dart`

```dart
import '../../../core/forms/form_field_state.dart';

sealed class RegistrationState {
  const RegistrationState();
}

class RegistrationForm extends RegistrationState {
  const RegistrationForm({
    this.currentStep = 0,
    this.totalSteps = 3,
    // Step 1: Personal info
    this.firstName = const FormFieldState<String>(),
    this.lastName = const FormFieldState<String>(),
    this.email = const FormFieldState<String>(),
    this.phone = const FormFieldState<String>(),
    // Step 2: Address
    this.street = const FormFieldState<String>(),
    this.city = const FormFieldState<String>(),
    this.zipCode = const FormFieldState<String>(),
    this.country = const FormFieldState<String>(),
    // Step 3: Review (no fields — just confirmation)
    this.agreedToTerms = const FormFieldState<bool>(value: false),
    // Meta
    this.isSubmitting = false,
    this.serverErrors = const {},
  });

  final int currentStep;
  final int totalSteps;

  // Step 1
  final FormFieldState<String> firstName;
  final FormFieldState<String> lastName;
  final FormFieldState<String> email;
  final FormFieldState<String> phone;

  // Step 2
  final FormFieldState<String> street;
  final FormFieldState<String> city;
  final FormFieldState<String> zipCode;
  final FormFieldState<String> country;

  // Step 3
  final FormFieldState<bool> agreedToTerms;

  final bool isSubmitting;

  /// Server errors keyed by field name.
  final Map<String, String> serverErrors;

  bool get isFirstStep => currentStep == 0;
  bool get isLastStep => currentStep == totalSteps - 1;
  double get progress => (currentStep + 1) / totalSteps;

  RegistrationForm copyWith({
    int? currentStep,
    FormFieldState<String>? firstName,
    FormFieldState<String>? lastName,
    FormFieldState<String>? email,
    FormFieldState<String>? phone,
    FormFieldState<String>? street,
    FormFieldState<String>? city,
    FormFieldState<String>? zipCode,
    FormFieldState<String>? country,
    FormFieldState<bool>? agreedToTerms,
    bool? isSubmitting,
    Map<String, String>? serverErrors,
  }) {
    return RegistrationForm(
      currentStep: currentStep ?? this.currentStep,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      serverErrors: serverErrors ?? this.serverErrors,
    );
  }
}

class RegistrationSuccess extends RegistrationState {
  const RegistrationSuccess();
}
```

---

## `lib/src/features/registration/domain/registration_validator.dart`

```dart
import '../../../core/forms/form_validator.dart';
import '../presentation/registration_state.dart';

/// Feature-specific validators for the registration form.
abstract final class RegistrationValidator {
  // ── Step 1 validators ──

  static final firstName = composeValidators<String>([
    isRequired(key: 'registration.first_name_required'),
    minLength(2, key: 'registration.first_name_too_short'),
  ]);

  static final lastName = composeValidators<String>([
    isRequired(key: 'registration.last_name_required'),
  ]);

  static final email = composeValidators<String>([
    isRequired(key: 'registration.email_required'),
    email(key: 'registration.email_invalid'),
  ]);

  static final phone = composeValidators<String>([
    isRequired(key: 'registration.phone_required'),
    phoneNumber(key: 'registration.phone_invalid'),
  ]);

  // ── Step 2 validators ──

  static final street = composeValidators<String>([
    isRequired(key: 'registration.street_required'),
  ]);

  static final city = composeValidators<String>([
    isRequired(key: 'registration.city_required'),
  ]);

  static final zipCode = composeValidators<String>([
    isRequired(key: 'registration.zip_required'),
    pattern(RegExp(r'^\d{5}(-\d{4})?$'), key: 'registration.zip_invalid'),
  ]);

  static final country = composeValidators<String>([
    isRequired(key: 'registration.country_required'),
  ]);

  // ── Step validation ──

  static bool isStepValid(RegistrationForm form, int step) {
    return switch (step) {
      0 => form.firstName.isValid &&
          form.lastName.isValid &&
          form.email.isValid &&
          form.phone.isValid,
      1 => form.street.isValid &&
          form.city.isValid &&
          form.zipCode.isValid &&
          form.country.isValid,
      2 => form.agreedToTerms.value == true,
      _ => false,
    };
  }
}
```

---

## `lib/src/features/registration/presentation/registration_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/forms/form_field_state.dart';
import '../../../core/forms/form_mixin.dart';
import '../domain/registration_validator.dart';
import '../../registration/domain/registration_repository.dart';
import 'registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState>
    with FormMixin<RegistrationState> {
  RegistrationCubit({required this.registrationRepository})
      : super(const RegistrationForm());

  final RegistrationRepository registrationRepository;

  // ── Step navigation ──

  void nextStep() {
    final current = state;
    if (current is! RegistrationForm || current.isLastStep) return;

    // Validate current step before advancing.
    final validated = _validateStep(current, current.currentStep);
    if (!RegistrationValidator.isStepValid(validated, current.currentStep)) {
      emit(validated);
      return;
    }
    emit(validated.copyWith(currentStep: current.currentStep + 1));
  }

  void previousStep() {
    final current = state;
    if (current is! RegistrationForm || current.isFirstStep) return;
    emit(current.copyWith(currentStep: current.currentStep - 1));
  }

  void goToStep(int step) {
    final current = state;
    if (current is! RegistrationForm) return;
    if (step < 0 || step >= current.totalSteps) return;

    // Only allow going back freely; going forward requires validation.
    if (step > current.currentStep) {
      // Validate all steps up to current before jumping forward.
      var form = current;
      for (var i = current.currentStep; i < step; i++) {
        form = _validateStep(form, i);
        if (!RegistrationValidator.isStepValid(form, i)) {
          emit(form.copyWith(currentStep: i));
          return;
        }
      }
      emit(form.copyWith(currentStep: step));
    } else {
      emit(current.copyWith(currentStep: step));
    }
  }

  // ── Step 1 field updates ──

  void firstNameChanged(String value) => _updateStringField(
        getValue: (f) => f.firstName,
        setValue: (f, field) => f.copyWith(firstName: field),
        validator: RegistrationValidator.firstName,
        value: value,
      );

  void lastNameChanged(String value) => _updateStringField(
        getValue: (f) => f.lastName,
        setValue: (f, field) => f.copyWith(lastName: field),
        validator: RegistrationValidator.lastName,
        value: value,
      );

  void emailChanged(String value) => _updateStringField(
        getValue: (f) => f.email,
        setValue: (f, field) => f.copyWith(email: field),
        validator: RegistrationValidator.email,
        value: value,
      );

  void phoneChanged(String value) => _updateStringField(
        getValue: (f) => f.phone,
        setValue: (f, field) => f.copyWith(phone: field),
        validator: RegistrationValidator.phoneNumber,
        value: value,
      );

  // ── Step 2 field updates ──

  void streetChanged(String value) => _updateStringField(
        getValue: (f) => f.street,
        setValue: (f, field) => f.copyWith(street: field),
        validator: RegistrationValidator.street,
        value: value,
      );

  void cityChanged(String value) => _updateStringField(
        getValue: (f) => f.city,
        setValue: (f, field) => f.copyWith(city: field),
        validator: RegistrationValidator.city,
        value: value,
      );

  void zipCodeChanged(String value) => _updateStringField(
        getValue: (f) => f.zipCode,
        setValue: (f, field) => f.copyWith(zipCode: field),
        validator: RegistrationValidator.zipCode,
        value: value,
      );

  void countryChanged(String value) => _updateStringField(
        getValue: (f) => f.country,
        setValue: (f, field) => f.copyWith(country: field),
        validator: RegistrationValidator.country,
        value: value,
      );

  // ── Step 3 ──

  void agreedToTermsChanged(bool value) {
    final current = state;
    if (current is! RegistrationForm) return;
    emit(current.copyWith(
      agreedToTerms: FormFieldState<bool>(
        value: value,
        isDirty: true,
        isTouched: true,
        error: value ? null : 'registration.must_agree',
      ),
    ));
  }

  // ── Focus lost (touch field) ──

  void fieldFocusLost(String fieldName) {
    final current = state;
    if (current is! RegistrationForm) return;

    final form = switch (fieldName) {
      'firstName' => current.copyWith(
          firstName: current.firstName.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.firstName(current.firstName.value),
          ),
        ),
      'lastName' => current.copyWith(
          lastName: current.lastName.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.lastName(current.lastName.value),
          ),
        ),
      'email' => current.copyWith(
          email: current.email.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.email(current.email.value),
          ),
        ),
      'phone' => current.copyWith(
          phone: current.phone.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.phoneNumber(current.phone.value),
          ),
        ),
      'street' => current.copyWith(
          street: current.street.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.street(current.street.value),
          ),
        ),
      'city' => current.copyWith(
          city: current.city.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.city(current.city.value),
          ),
        ),
      'zipCode' => current.copyWith(
          zipCode: current.zipCode.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.zipCode(current.zipCode.value),
          ),
        ),
      'country' => current.copyWith(
          country: current.country.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.country(current.country.value),
          ),
        ),
      _ => current,
    };
    emit(form);
  }

  // ── Submission ──

  Future<void> submit() async {
    var current = state;
    if (current is! RegistrationForm) return;

    // Validate all steps.
    current = _validateAllSteps(current);
    emit(current);

    for (var i = 0; i < current.totalSteps; i++) {
      if (!RegistrationValidator.isStepValid(current, i)) {
        emit(current.copyWith(currentStep: i));
        return;
      }
    }

    emit(current.copyWith(isSubmitting: true));

    try {
      await registrationRepository.register(
        firstName: current.firstName.value!,
        lastName: current.lastName.value!,
        email: current.email.value!,
        phone: current.phone.value!,
        street: current.street.value!,
        city: current.city.value!,
        zipCode: current.zipCode.value!,
        country: current.country.value!,
      );
      emit(const RegistrationSuccess());
    } on RegistrationFailure catch (e) {
      emit(current.copyWith(
        isSubmitting: false,
        serverErrors: e.fieldErrors,
      ));
    }
  }

  // ── Server error mapping ──

  /// Apply server-side field errors to the form state.
  void applyServerErrors(Map<String, String> errors) {
    final current = state;
    if (current is! RegistrationForm) return;

    var form = current.copyWith(serverErrors: errors);
    for (final entry in errors.entries) {
      form = switch (entry.key) {
        'email' => form.copyWith(
            email: form.email.copyWith(
              isTouched: true,
              error: () => entry.value,
            ),
          ),
        'phone' => form.copyWith(
            phone: form.phone.copyWith(
              isTouched: true,
              error: () => entry.value,
            ),
          ),
        _ => form,
      };
    }
    emit(form);
  }

  // ── Helpers ──

  void _updateStringField({
    required FormFieldState<String> Function(RegistrationForm) getValue,
    required RegistrationForm Function(RegistrationForm, FormFieldState<String>) setValue,
    required String? Function(String?) validator,
    required String value,
  }) {
    final current = state;
    if (current is! RegistrationForm) return;

    final existing = getValue(current);
    final field = existing.copyWith(
      value: value,
      isDirty: true,
      error: () => existing.isTouched ? validator(value) : null,
    );
    emit(setValue(current, field));
  }

  RegistrationForm _validateStep(RegistrationForm form, int step) {
    return switch (step) {
      0 => form.copyWith(
          firstName: form.firstName.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.firstName(form.firstName.value),
          ),
          lastName: form.lastName.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.lastName(form.lastName.value),
          ),
          email: form.email.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.email(form.email.value),
          ),
          phone: form.phone.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.phoneNumber(form.phone.value),
          ),
        ),
      1 => form.copyWith(
          street: form.street.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.street(form.street.value),
          ),
          city: form.city.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.city(form.city.value),
          ),
          zipCode: form.zipCode.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.zipCode(form.zipCode.value),
          ),
          country: form.country.copyWith(
            isTouched: true,
            error: () => RegistrationValidator.country(form.country.value),
          ),
        ),
      2 => form.copyWith(
          agreedToTerms: FormFieldState<bool>(
            value: form.agreedToTerms.value,
            isDirty: true,
            isTouched: true,
            error: form.agreedToTerms.value == true
                ? null
                : 'registration.must_agree',
          ),
        ),
      _ => form,
    };
  }

  RegistrationForm _validateAllSteps(RegistrationForm form) {
    var result = form;
    for (var i = 0; i < form.totalSteps; i++) {
      result = _validateStep(result, i);
    }
    return result;
  }

  // ── FormMixin ──

  @override
  RegistrationState validateAll(RegistrationState state) {
    if (state is! RegistrationForm) return state;
    return _validateAllSteps(state);
  }

  @override
  bool isFormValid(RegistrationState state) {
    if (state is! RegistrationForm) return false;
    for (var i = 0; i < state.totalSteps; i++) {
      if (!RegistrationValidator.isStepValid(state, i)) return false;
    }
    return true;
  }
}
```

---

## `lib/src/features/registration/domain/registration_repository.dart`

```dart
abstract interface class RegistrationRepository {
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String street,
    required String city,
    required String zipCode,
    required String country,
  });
}

class RegistrationFailure implements Exception {
  const RegistrationFailure({
    this.message,
    this.fieldErrors = const {},
  });

  final String? message;

  /// Server-side per-field errors keyed by field name.
  final Map<String, String> fieldErrors;
}
```

---

## `lib/src/features/registration/presentation/pages/registration_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../registration_cubit.dart';
import '../registration_state.dart';
import 'step_personal_info.dart';
import 'step_address.dart';
import 'step_review.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegistrationCubit, RegistrationState>(
      listener: (context, state) {
        if (state is RegistrationSuccess) {
          // Navigate to success / home.
        }
      },
      builder: (context, state) {
        if (state is! RegistrationForm) return const SizedBox.shrink();
        final cubit = context.read<RegistrationCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Create Account'),
            leading: state.isFirstStep
                ? null
                : IconButton(
                    onPressed: cubit.previousStep,
                    icon: const Icon(Icons.arrow_back),
                  ),
          ),
          body: Column(
            children: [
              // ── Progress indicator ──
              LinearProgressIndicator(value: state.progress),
              // ── Step labels ──
              _StepIndicator(currentStep: state.currentStep),
              // ── Step content ──
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: switch (state.currentStep) {
                    0 => StepPersonalInfo(key: const ValueKey(0), form: state),
                    1 => StepAddress(key: const ValueKey(1), form: state),
                    2 => StepReview(key: const ValueKey(2), form: state),
                    _ => const SizedBox.shrink(),
                  },
                ),
              ),
              // ── Navigation buttons ──
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : state.isLastStep
                              ? cubit.submit
                              : cubit.nextStep,
                      child: state.isSubmitting
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(state.isLastStep ? 'Submit' : 'Next'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const labels = ['Personal', 'Address', 'Review'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const Expanded(child: Divider()),
            _StepDot(
              label: labels[i],
              isActive: i == currentStep,
              isCompleted: i < currentStep,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  final String label;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final color = isActive || isCompleted
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: isCompleted
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  '${label[0]}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
```

---

## `lib/src/features/registration/presentation/pages/step_personal_info.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/forms/form_field_state.dart';
import '../registration_cubit.dart';
import '../registration_state.dart';

class StepPersonalInfo extends StatefulWidget {
  const StepPersonalInfo({super.key, required this.form});
  final RegistrationForm form;

  @override
  State<StepPersonalInfo> createState() => _StepPersonalInfoState();
}

class _StepPersonalInfoState extends State<StepPersonalInfo> {
  late final _firstNameCtrl = TextEditingController(text: widget.form.firstName.value);
  late final _lastNameCtrl = TextEditingController(text: widget.form.lastName.value);
  late final _emailCtrl = TextEditingController(text: widget.form.email.value);
  late final _phoneCtrl = TextEditingController(text: widget.form.phone.value);

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationCubit, RegistrationState>(
      builder: (context, state) {
        if (state is! RegistrationForm) return const SizedBox.shrink();
        final cubit = context.read<RegistrationCubit>();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_firstNameCtrl, state.firstName, 'First Name',
                cubit.firstNameChanged, 'firstName', cubit),
            const SizedBox(height: 16),
            _field(_lastNameCtrl, state.lastName, 'Last Name',
                cubit.lastNameChanged, 'lastName', cubit),
            const SizedBox(height: 16),
            _field(_emailCtrl, state.email, 'Email',
                cubit.emailChanged, 'email', cubit,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _field(_phoneCtrl, state.phone, 'Phone',
                cubit.phoneChanged, 'phone', cubit,
                keyboardType: TextInputType.phone),
          ],
        );
      },
    );
  }

  Widget _field(
    TextEditingController controller,
    FormFieldState<String> fieldState,
    String label,
    ValueChanged<String> onChanged,
    String fieldName,
    RegistrationCubit cubit, {
    TextInputType? keyboardType,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) cubit.fieldFocusLost(fieldName);
      },
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          errorText: fieldState.shouldShowError ? fieldState.error : null,
        ),
      ),
    );
  }
}
```

---

## Rules

- **Validate step before advancing** — `nextStep()` validates the current step before allowing forward navigation. Back navigation (`previousStep()`) is always free.
- **`goToStep` validates intermediates** — jumping forward validates all steps between current and target before allowing the jump.
- **Server error mapping** — apply API field errors by field name via `applyServerErrors()`. Clear server errors when the user edits the field.
