import 'package:architecture/architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

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
  EditProfileCubit(this._repository) : super(const EditProfileState());

  final ProfileRepository _repository;

  /// Loads the profile the form edits.
  Future<void> load() async {
    emit(state.copyWith(status: EditProfileStatus.loading, saveError: null));
    switch (await _repository.me()) {
      case Ok(:final value):
        emit(_formFor(value));
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

  EditProfileState _formFor(UserProfile p) => EditProfileState(
    status: EditProfileStatus.ready,
    profile: p,
    displayName: p.displayName,
    username: p.username,
    day: p.birthDate?.day.toString() ?? '',
    month: p.birthDate?.month.toString() ?? '',
    year: p.birthDate?.year?.toString() ?? '',
  );

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
        usernameError: profile == null ? null : validateUsername(value, profile),
        saveError: null,
      ),
    );
  }

  void dayChanged(String value) => _birthDateChanged(state.copyWith(day: value));

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
    emit(state.copyWith(status: EditProfileStatus.saving, saveError: null));
    switch (await _repository.update(edit)) {
      case Ok(:final value):
        emit(
          _formFor(value).copyWith(
            status: EditProfileStatus.saved,
            // AC-03: the change that used up the allowance is the one worth
            // announcing.
            usernameJustExhausted:
                edit.username != null && !value.canChangeUsername,
          ),
        );
      case Err(:final failure):
        // AC-11: the form keeps everything the user typed; only the status and
        // the error change.
        final onUsername = _belongsToUsername(failure, edit);
        emit(
          state.copyWith(
            status: EditProfileStatus.ready,
            usernameError: onUsername ? failure.message : null,
            saveError: onUsername ? null : failure.message,
          ),
        );
    }
  }

  /// Whether a rejection belongs under the username field rather than the
  /// form-wide banner: the spent allowance (BR-03), and any value the server
  /// refused on a save that changed the username — a taken name (§5) being the
  /// case the user must see there.
  bool _belongsToUsername(Failure failure, ProfileEdit edit) => switch (failure) {
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
