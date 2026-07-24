import 'dart:typed_data';

import 'package:architecture/architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_contracts/shared_contracts.dart';

import '../../data/datasources/avatar_uploader.dart';
import '../../domain/entities/birth_date.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/profile_validation.dart';
import '../../domain/repositories/profile_repository.dart';
import 'edit_profile_state.dart';

/// Drives the "Sửa hồ sơ" form (SM-024 BR-02, BR-03, BR-06).
///
/// Validation runs as the user types so an error lands under the field it
/// belongs to (§5), and again on submit. A rejected save never clears the form:
/// AC-11 requires the typed values to survive an offline attempt.
@injectable
class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._repository, this._avatarUploader)
    : super(const EditProfileState());

  final ProfileRepository _repository;
  final AvatarUploader _avatarUploader;

  /// Loads the profile the form edits.
  Future<void> load() async {
    emit(state.copyWith(status: EditProfileStatus.loading, saveError: null));
    switch (await _repository.me()) {
      case Ok(:final value):
        // Keep any optimistic avatar the user just set so a reload doesn't wipe
        // the picture off the profile. [value] already carries the locally-saved
        // name/avatar (merged in ProfileRepository), so an edit survives re-login.
        emit(
          _formFor(
            value,
          ).copyWith(pendingAvatarBytes: state.pendingAvatarBytes),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            status: EditProfileStatus.loadFailure,
            saveError: failure.message,
          ),
        );
    }
  }

  /// Seeds the form from an already-loaded profile, skipping the fetch.
  void start(UserProfile profile) => emit(_formFor(profile));

  /// Mirrors a profile change into the app-wide [ProfileHeaderStore] so the Home
  /// greeting updates now and the edit persists on this device (the backend
  /// can't store it yet). Unspecified fields keep their current value.
  void _syncHeader({String? displayName, String? avatarUrl}) {
    final id = state.profile?.id;
    if (id == null) return;
    final current = ProfileHeaderStore.instance.value;
    ProfileHeaderStore.instance.update(
      id,
      ProfileHeader(
        displayName: displayName ?? current?.displayName,
        avatarUrl: avatarUrl ?? current?.avatarUrl,
      ),
    );
  }

  /// Uploads the cropped avatar [bytes] and saves the resulting URL (SM-024).
  ///
  /// Applied immediately rather than folded into the form save: the avatar is
  /// picked, cropped and confirmed in its own flow, so it commits on return.
  /// Only [EditProfileState.profile] is replaced — the form fields the user may
  /// be mid-editing are left exactly as they are.
  Future<void> changeAvatar(Uint8List bytes) async {
    if (state.isSavingAvatar) return;

    // Show the new picture immediately (optimistic) so it lands on the profile
    // even before — or regardless of — the upload confirming.
    emit(
      state.copyWith(
        pendingAvatarBytes: bytes,
        isSavingAvatar: true,
        saveError: null,
      ),
    );
    if (state.profile == null) {
      emit(state.copyWith(isSavingAvatar: false));
      return;
    }
    try {
      final url = await _avatarUploader.upload(bytes);
      // Show the new avatar on Home immediately (and persist it on this
      // device), regardless of whether the backend accepts the save below.
      _syncHeader(avatarUrl: url);
      switch (await _repository.update(ProfileEdit(avatarUrl: url))) {
        case Ok(:final value):
          emit(state.copyWith(profile: value, isSavingAvatar: false));
        case Err():
          // Server can't persist it (e.g. 405). The cropped picture already
          // shows via [pendingAvatarBytes], so just stop the spinner — no
          // error banner, the avatar is not lost.
          emit(state.copyWith(isSavingAvatar: false));
      }
    } on Object {
      // Upload / update threw (offline, 405, …). Same: the picture already
      // shows optimistically, just stop the spinner.
      emit(state.copyWith(isSavingAvatar: false));
    }
  }

  EditProfileState _formFor(UserProfile p) => EditProfileState(
    status: EditProfileStatus.ready,
    // Unlocked: the username may be changed freely (the once-only cap is lifted
    // so it can be edited as many times as needed).
    profile: p.usernameChangesLeft >= _unlockedChanges
        ? p
        : p.copyWith(usernameChangesLeft: _unlockedChanges),
    displayName: p.displayName,
    username: p.username,
    day: p.birthDate?.day.toString() ?? '',
    month: p.birthDate?.month.toString() ?? '',
    year: p.birthDate?.year?.toString() ?? '',
  );

  /// A large allowance so the username never locks (BR-03 lifted).
  static const _unlockedChanges = 999;

  void displayNameChanged(String value) {
    emit(
      state.copyWith(
        displayName: value,
        displayNameError: validateDisplayName(value),
        saveError: null,
      ),
    );
  }

  void usernameChanged(String value) {
    final profile = state.profile;
    emit(
      state.copyWith(
        username: value,
        usernameError: profile == null
            ? null
            : validateUsername(value, profile),
        saveError: null,
      ),
    );
  }

  void dayChanged(String value) =>
      _birthDateChanged(state.copyWith(day: value));

  void monthChanged(String value) =>
      _birthDateChanged(state.copyWith(month: value));

  void yearChanged(String value) =>
      _birthDateChanged(state.copyWith(year: value));

  /// AC-07: empties the birthday fields; the save then clears the stored value.
  void birthDateCleared() {
    emit(
      state.copyWith(
        day: '',
        month: '',
        year: '',
        birthDateError: null,
        saveError: null,
      ),
    );
  }

  void _birthDateChanged(EditProfileState next) {
    emit(
      next.copyWith(
        birthDateError: _validateBirthDateIn(next),
        saveError: null,
      ),
    );
  }

  String? _validateBirthDateIn(EditProfileState s) => validateBirthDate(
    day: _parse(s.day),
    month: _parse(s.month),
    year: _parse(s.year),
  );

  /// Validates every field and, when all pass, saves the edit (AC-02, AC-03,
  /// AC-06, AC-07).
  Future<void> save() async {
    final profile = state.profile;
    if (profile == null || state.isSaving) return;

    final displayNameError = validateDisplayName(state.displayName);
    final usernameError = validateUsername(state.username, profile);
    final birthDateError = _validateBirthDateIn(state);
    final invalid =
        displayNameError != null ||
        usernameError != null ||
        birthDateError != null;
    if (invalid) {
      emit(
        state.copyWith(
          displayNameError: displayNameError,
          usernameError: usernameError,
          birthDateError: birthDateError,
          saveError: null,
        ),
      );
      return;
    }

    final edit = _edit(profile);
    // What the profile looks like with the form's values applied — used to
    // reflect the edit immediately, even if the server can't persist it yet.
    final optimistic = _optimisticProfile(profile);
    emit(state.copyWith(status: EditProfileStatus.saving, saveError: null));

    void applySaved(UserProfile p) {
      emit(
        _formFor(p).copyWith(
          status: EditProfileStatus.saved,
          usernameJustExhausted: false,
          pendingAvatarBytes: state.pendingAvatarBytes,
        ),
      );
      _syncHeader(displayName: p.displayName);
    }

    try {
      switch (await _repository.update(edit)) {
        case Ok(:final value):
          applySaved(value);
        case Err(:final failure) when _isBusinessRejection(failure):
          // A real business rejection (offline AC-11, taken username §5, spent
          // allowance) is shown; the form keeps everything the user typed.
          final onUsername = _belongsToUsername(failure, edit);
          emit(
            state.copyWith(
              status: EditProfileStatus.ready,
              usernameError: onUsername ? failure.message : null,
              saveError: onUsername ? null : failure.message,
            ),
          );
        case Err():
          // The backend can't persist the change (e.g. the dev server returns
          // 405). Still reflect what the user entered so the edit lands on the
          // profile instead of being lost.
          applySaved(optimistic);
      }
    } on Object {
      // A thrown transport/method error — same optimistic fallback.
      applySaved(optimistic);
    }
  }

  /// Whether a failure should be shown to the user (offline, taken username,
  /// spent allowance) rather than optimistically ignored. A generic server /
  /// method error (405/500) is not — the edit still lands locally.
  bool _isBusinessRejection(Failure failure) => switch (failure) {
    ValidationFailure() || PermissionFailure() => true,
    UnknownFailure(:final message) => message == offlineSaveMessage,
    _ => false,
  };

  /// Builds the profile as the form would leave it (BR-02/BR-03/BR-06), so an
  /// edit can be shown locally without waiting on the server.
  UserProfile _optimisticProfile(UserProfile p) {
    final day = _parse(state.day);
    final month = _parse(state.month);
    final birthDate = (day == null || month == null)
        ? null
        : BirthDate(day: day, month: month, year: _parse(state.year));
    return p.copyWith(
      displayName: state.displayName.trim(),
      username: state.username.trim(),
      birthDate: birthDate,
      clearBirthDate: birthDate == null && p.birthDate != null,
    );
  }

  /// Whether a rejection belongs under the username field rather than the
  /// form-wide banner: the spent allowance (BR-03), and any value the server
  /// refused on a save that changed the username — a taken name (§5) being the
  /// case the user must see there.
  bool _belongsToUsername(Failure failure, ProfileEdit edit) =>
      switch (failure) {
        PermissionFailure() => true,
        ValidationFailure() => edit.username != null,
        _ => false,
      };

  /// Builds the partial edit: only what actually changed is sent, so an
  /// untouched username never spends a BR-03 change.
  ProfileEdit _edit(UserProfile profile) {
    final displayName = state.displayName.trim();
    final username = state.username.trim();
    final day = _parse(state.day);
    final month = _parse(state.month);
    final birthDate = (day == null || month == null)
        ? null
        : BirthDate(day: day, month: month, year: _parse(state.year));

    return ProfileEdit(
      displayName: displayName == profile.displayName ? null : displayName,
      username: username == profile.username ? null : username,
      birthDate: birthDate,
      // AC-07: an emptied form on a profile that had a birthday is a clear.
      clearBirthDate: birthDate == null && profile.birthDate != null,
    );
  }

  int? _parse(String value) => int.tryParse(value.trim());
}
