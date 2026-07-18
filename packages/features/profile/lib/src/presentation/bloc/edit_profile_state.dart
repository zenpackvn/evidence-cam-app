import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_profile.dart';

part 'edit_profile_state.freezed.dart';

enum EditProfileStatus {
  /// Fetching the profile to edit.
  loading,

  /// The profile could not be loaded and there is nothing to edit (§5: show an
  /// error with a retry).
  loadFailure,

  /// The form is editable.
  ready,

  /// A save is in flight.
  saving,

  /// The save succeeded; the screen pops.
  saved,
}

/// State of the "Sửa hồ sơ" form (SM-024 BR-02, BR-03, BR-06).
///
/// Field errors are separate so each one renders under its own input (§5:
/// "báo lỗi ngay tại ô nhập"). [saveError] carries whole-form problems — an
/// offline save (AC-11) or a taken username.
@freezed
abstract class EditProfileState with _$EditProfileState {
  const factory EditProfileState({
    @Default(EditProfileStatus.loading) EditProfileStatus status,
    UserProfile? profile,
    @Default('') String displayName,
    @Default('') String username,
    @Default('') String day,
    @Default('') String month,
    @Default('') String year,
    String? displayNameError,
    String? usernameError,
    String? birthDateError,
    String? saveError,

    /// AC-03: set on the save that spends the last username change, so the
    /// screen can tell the user the allowance is now gone.
    @Default(false) bool usernameJustExhausted,

    /// True while a new avatar is uploading + saving. Separate from [status] so
    /// the avatar spinner is independent of the form's save button.
    @Default(false) bool isSavingAvatar,
  }) = _EditProfileState;

  const EditProfileState._();

  /// BR-03: once the allowance is spent the username input is disabled (AC-04).
  bool get canChangeUsername => profile?.canChangeUsername ?? false;

  bool get isSaving => status == EditProfileStatus.saving;

  /// A save is offered only when no field is currently in error.
  bool get hasFieldErrors =>
      displayNameError != null ||
      usernameError != null ||
      birthDateError != null;
}
