# Forms — Testing

## Validator unit tests

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:app/src/core/forms/form_validator.dart';

void main() {
  group('required', () {
    final validator = required();

    test('returns error for null', () {
      expect(validator(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(validator(''), isNotNull);
    });

    test('returns error for whitespace only', () {
      expect(validator('   '), isNotNull);
    });

    test('returns null for valid input', () {
      expect(validator('hello'), isNull);
    });
  });

  group('email', () {
    final validator = email();

    test('rejects invalid email', () {
      expect(validator('notanemail'), isNotNull);
      expect(validator('missing@tld'), isNotNull);
    });

    test('accepts valid email', () {
      expect(validator('user@example.com'), isNull);
    });
  });

  group('composeValidators', () {
    test('returns first failing validator error', () {
      final composed = composeValidators<String>([
        isRequired(key: 'required'),
        minLength(5, key: 'too_short'),
      ]);

      expect(composed(null), 'required');
      expect(composed('ab'), 'too_short');
      expect(composed('hello'), isNull);
    });
  });
}
```

---

## Cubit bloc_test — single-page form (Login)

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/src/features/login/presentation/login_cubit.dart';
import 'package:app/src/features/login/presentation/login_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuth;

  setUp(() => mockAuth = MockAuthRepository());

  blocTest<LoginCubit, LoginState>(
    'emailChanged updates email field value',
    build: () => LoginCubit(authRepository: mockAuth),
    act: (cubit) => cubit.emailChanged('test@example.com'),
    expect: () => [
      isA<LoginForm>().having(
        (s) => s.email.value, 'email.value', 'test@example.com',
      ),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'submit validates all fields and shows errors when invalid',
    build: () => LoginCubit(authRepository: mockAuth),
    act: (cubit) => cubit.submit(),
    expect: () => [
      isA<LoginForm>()
          .having((s) => s.email.isTouched, 'email.isTouched', true)
          .having((s) => s.email.error, 'email.error', isNotNull)
          .having((s) => s.password.isTouched, 'password.isTouched', true)
          .having((s) => s.password.error, 'password.error', isNotNull),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'submit emits success on valid credentials',
    build: () {
      when(() => mockAuth.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async {});
      return LoginCubit(authRepository: mockAuth);
    },
    seed: () => const LoginForm(
      email: FormFieldState(value: 'a@b.com', isTouched: true),
      password: FormFieldState(value: '12345678', isTouched: true),
    ),
    act: (cubit) => cubit.submit(),
    expect: () => [
      isA<LoginForm>().having((s) => s.isSubmitting, 'submitting', true),
      isA<LoginSuccess>(),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'submit maps server error to state',
    build: () {
      when(() => mockAuth.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(const AuthFailure(message: 'Invalid credentials'));
      return LoginCubit(authRepository: mockAuth);
    },
    seed: () => const LoginForm(
      email: FormFieldState(value: 'a@b.com', isTouched: true),
      password: FormFieldState(value: '12345678', isTouched: true),
    ),
    act: (cubit) => cubit.submit(),
    expect: () => [
      isA<LoginForm>().having((s) => s.isSubmitting, 'submitting', true),
      isA<LoginForm>().having((s) => s.serverError, 'serverError', 'Invalid credentials'),
    ],
  );
}
```

---

## Multi-step navigation tests

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/src/core/forms/form_field_state.dart';
import 'package:app/src/features/registration/presentation/registration_cubit.dart';
import 'package:app/src/features/registration/presentation/registration_state.dart';

class MockRegistrationRepository extends Mock implements RegistrationRepository {}

void main() {
  late MockRegistrationRepository mockRepo;

  setUp(() => mockRepo = MockRegistrationRepository());

  blocTest<RegistrationCubit, RegistrationState>(
    'nextStep does not advance when current step is invalid',
    build: () => RegistrationCubit(registrationRepository: mockRepo),
    act: (cubit) => cubit.nextStep(),
    expect: () => [
      isA<RegistrationForm>()
          .having((s) => s.currentStep, 'step', 0)
          .having((s) => s.firstName.isTouched, 'touched', true),
    ],
  );

  blocTest<RegistrationCubit, RegistrationState>(
    'nextStep advances when step 1 is valid',
    build: () => RegistrationCubit(registrationRepository: mockRepo),
    seed: () => const RegistrationForm(
      firstName: FormFieldState(value: 'John', isTouched: true),
      lastName: FormFieldState(value: 'Doe', isTouched: true),
      email: FormFieldState(value: 'john@example.com', isTouched: true),
      phone: FormFieldState(value: '+1234567890', isTouched: true),
    ),
    act: (cubit) => cubit.nextStep(),
    expect: () => [
      isA<RegistrationForm>().having((s) => s.currentStep, 'step', 1),
    ],
  );

  blocTest<RegistrationCubit, RegistrationState>(
    'previousStep goes back without validation',
    build: () => RegistrationCubit(registrationRepository: mockRepo),
    seed: () => const RegistrationForm(currentStep: 1),
    act: (cubit) => cubit.previousStep(),
    expect: () => [
      isA<RegistrationForm>().having((s) => s.currentStep, 'step', 0),
    ],
  );
}
```
