import 'package:architecture/architecture.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:feature_auth/src/presentation/bloc/sign_out_all_devices_cubit.dart';
import 'package:feature_auth/src/presentation/bloc/sign_out_all_devices_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';

void main() {
  late MockSignOutAllDevices mockSignOutAllDevices;
  late MockAnalyticsService mockAnalytics;

  setUp(() {
    mockSignOutAllDevices = MockSignOutAllDevices();
    mockAnalytics = MockAnalyticsService();
    stubAnalyticsService(mockAnalytics);
  });

  SignOutAllDevicesCubit buildCubit() =>
      SignOutAllDevicesCubit(mockSignOutAllDevices, mockAnalytics);

  group('SignOutAllDevicesCubit', () {
    test('initial state is SignOutAllDevicesInitial', () {
      expect(buildCubit().state, const SignOutAllDevicesState.initial());
    });

    blocTest<SignOutAllDevicesCubit, SignOutAllDevicesState>(
      'emits submitting then success and tracks analytics on success',
      build: () {
        when(
          () => mockSignOutAllDevices(),
        ).thenAnswer((_) async => const Ok(null));
        return buildCubit();
      },
      act: (cubit) => cubit.submit(),
      expect: () => [
        const SignOutAllDevicesState.submitting(),
        const SignOutAllDevicesState.success(),
      ],
      verify: (_) {
        verify(() => mockAnalytics.setCurrentUser(null)).called(1);
      },
    );

    // The whole point of this cubit: a failed revoke must surface. Emitting
    // success here would tell the user their other devices are signed out while
    // the repository has deliberately kept the session alive.
    blocTest<SignOutAllDevicesCubit, SignOutAllDevicesState>(
      'emits submitting then failure on error, and does not clear the user',
      build: () {
        when(
          () => mockSignOutAllDevices(),
        ).thenAnswer((_) async => const Err(testFailure));
        return buildCubit();
      },
      act: (cubit) => cubit.submit(),
      expect: () => [
        const SignOutAllDevicesState.submitting(),
        const SignOutAllDevicesState.failure(testFailure),
      ],
      verify: (_) {
        verifyNever(() => mockAnalytics.setCurrentUser(null));
      },
    );

    blocTest<SignOutAllDevicesCubit, SignOutAllDevicesState>(
      'ignores a second submit while one is in flight',
      build: () {
        when(() => mockSignOutAllDevices()).thenAnswer(
          (_) => Future.delayed(
            const Duration(milliseconds: 50),
            () => const Ok(null),
          ),
        );
        return buildCubit();
      },
      act: (cubit) {
        cubit
          ..submit()
          ..submit();
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        const SignOutAllDevicesState.submitting(),
        const SignOutAllDevicesState.success(),
      ],
      verify: (_) {
        verify(() => mockSignOutAllDevices()).called(1);
      },
    );
  });
}
