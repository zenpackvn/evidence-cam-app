import 'package:architecture/architecture.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_out_all_devices_state.freezed.dart';

@freezed
sealed class SignOutAllDevicesState with _$SignOutAllDevicesState {
  const factory SignOutAllDevicesState.initial() = SignOutAllDevicesInitial;
  const factory SignOutAllDevicesState.submitting() =
      SignOutAllDevicesSubmitting;
  const factory SignOutAllDevicesState.success() = SignOutAllDevicesSuccess;
  const factory SignOutAllDevicesState.failure(Failure failure) =
      SignOutAllDevicesFailure;
}
