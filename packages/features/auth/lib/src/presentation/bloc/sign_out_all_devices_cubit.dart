import 'package:analytics/analytics.dart';
import 'package:architecture/architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/sign_out_all_devices.dart';
import 'sign_out_all_devices_state.dart';

/// Drives "đăng xuất tất cả thiết bị" (SM-027).
///
/// This is a sibling of `DeleteAccountCubit` rather than part of the ordinary
/// sign-out path: ending every session can fail, and the user has to be told
/// when it does, which the fire-and-forget `Session.signOut()` cannot express.
@injectable
class SignOutAllDevicesCubit extends Cubit<SignOutAllDevicesState> {
  SignOutAllDevicesCubit(this._signOutAllDevices, this._analytics)
    : super(const SignOutAllDevicesState.initial());

  final SignOutAllDevicesUseCase _signOutAllDevices;
  final AnalyticsService _analytics;

  Future<void> submit() async {
    if (state is SignOutAllDevicesSubmitting) return;

    emit(const SignOutAllDevicesState.submitting());

    final result = await _signOutAllDevices();

    switch (result) {
      case Ok():
        _analytics.trackSignOut().fire();
        _analytics.setCurrentUser(null).fire();
        emit(const SignOutAllDevicesState.success());
      case Err(:final failure):
        // The session is still live — the repository only clears it once the
        // server confirms. Surface the failure instead of pretending.
        emit(SignOutAllDevicesState.failure(failure));
    }
  }
}
