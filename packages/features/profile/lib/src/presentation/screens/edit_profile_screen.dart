import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/profile_validation.dart';
import '../../locator.dart';
import '../bloc/edit_profile_cubit.dart';
import '../bloc/edit_profile_state.dart';
import '../widgets/profile_sub_scaffold.dart';
import 'crop_avatar_screen.dart';

/// SM-024 — "Sửa hồ sơ": the form behind the profile's edit action. Covers the
/// avatar, display name (BR-02), the once-only username change (BR-03) and the
/// optional birthday (BR-06).
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({this.picker, super.key});

  /// Supplied by the host (the router) so the feature does not reach into the
  /// platform itself. Null in contexts without a picker (some tests), where the
  /// avatar tap is simply inert.
  final ImagePickerService? picker;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditProfileCubit>(
      create: (_) => getIt<EditProfileCubit>()..load(),
      child: EditProfileBody(picker: picker),
    );
  }
}

@visibleForTesting
class EditProfileBody extends StatelessWidget {
  const EditProfileBody({this.picker, super.key});

  final ImagePickerService? picker;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listenWhen: (prev, next) => prev.status != next.status,
      listener: (context, state) {
        if (state.status != EditProfileStatus.saved) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                // AC-03: the user is told when the last change is spent.
                state.usernameJustExhausted
                    ? 'Đã lưu. Bạn đã dùng hết lượt đổi tên người dùng.'
                    : 'Đã lưu hồ sơ.',
              ),
            ),
          );
        Navigator.of(context).maybePop();
      },
      builder: (context, state) => ProfileSubScaffold(
        title: 'Sửa hồ sơ',
        child: switch (state.status) {
          EditProfileStatus.loading => const Center(child: AppLoading()),
          EditProfileStatus.loadFailure => _LoadFailure(
            message: state.saveError,
            onRetry: () => context.read<EditProfileCubit>().load(),
          ),
          _ => _Form(state: state, picker: picker),
        },
      ),
    );
  }
}

/// §5: the profile could not be loaded and there is no cache — show the error
/// with a retry so the user need not leave the screen.
class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.onRetry, this.message});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorView(
      message: message ?? 'Không tải được hồ sơ.',
      onRetry: onRetry,
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.state, this.picker});

  final EditProfileState state;
  final ImagePickerService? picker;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      children: [
        _AvatarField(state: state, picker: picker),
        const SizedBox(height: AppSpacing.xl),
        // BR-02: freely editable, at most 30 characters. The length is not
        // hard-capped — §5 asks for an error at the field when it is exceeded,
        // which a cap would make unreachable.
        AppTextField(
          key: const Key('editProfile_displayName'),
          label: 'Tên hiển thị',
          hint: 'Tên bạn muốn hiển thị',
          initialValue: state.displayName,
          errorText: state.displayNameError,
          helperText:
              '${state.displayName.runes.length}/$displayNameMaxLength ký tự',
          textCapitalization: TextCapitalization.words,
          enabled: !state.isSaving,
          onChanged: cubit.displayNameChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        _UsernameField(state: state),
        const SizedBox(height: AppSpacing.lg),
        _BirthDateField(state: state),
        const SizedBox(height: AppSpacing.xl),
        if (state.saveError != null) ...[
          _SaveError(message: state.saveError!),
          const SizedBox(height: AppSpacing.lg),
        ],
        AppButton(
          key: const Key('editProfile_save'),
          label: 'Lưu',
          onPressed: state.isSaving ? null : cubit.save,
          isLoading: state.isSaving,
          expand: true,
        ),
      ],
    );
  }
}

/// SM-024 avatar: the current picture (or an initial-letter placeholder),
/// tappable to pick → crop → upload a new one. A spinner replaces the edit
/// badge while the new avatar uploads and saves.
class _AvatarField extends StatelessWidget {
  const _AvatarField({required this.state, this.picker});

  final EditProfileState state;
  final ImagePickerService? picker;

  static const _size = 96.0;

  /// Picks a photo, sends it through the crop screen, and hands the cropped
  /// bytes to the cubit. A cancel at either step is a no-op.
  Future<void> _pickAndCrop(BuildContext context) async {
    final service = picker;
    if (service == null) return;
    final cubit = context.read<EditProfileCubit>();
    final navigator = Navigator.of(context);

    final file = await service.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    await navigator.push<void>(
      MaterialPageRoute(
        builder: (_) => CropAvatarScreen(
          imagePath: file.path,
          onSave: (bytes) {
            navigator.pop();
            cubit.changeAvatar(bytes);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final avatarUrl = state.profile?.avatarUrl ?? '';
    final initial = state.displayName.isNotEmpty
        ? state.displayName.characters.first.toUpperCase()
        : (state.username.isNotEmpty
              ? state.username.characters.first.toUpperCase()
              : '?');

    return Center(
      child: Semantics(
        button: true,
        label: 'Đổi ảnh đại diện',
        child: InkWell(
          key: const Key('editProfile_avatar'),
          onTap: state.isSavingAvatar ? null : () => _pickAndCrop(context),
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: _size,
            height: _size,
            child: Stack(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: _size,
                    height: _size,
                    child: avatarUrl.isEmpty
                        ? ColoredBox(
                            color: scheme.primaryContainer,
                            child: Center(
                              child: Text(
                                initial,
                                style: context.textTheme.displaySmall?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          )
                        : AppNetworkImage(imageUrl: avatarUrl),
                  ),
                ),
                // The edit badge, replaced by a spinner while saving.
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: scheme.primary,
                    child: state.isSavingAvatar
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onPrimary,
                            ),
                          )
                        : Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: scheme.onPrimary,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// BR-03: the username may be changed once after sign-up; afterwards the field
/// is locked for good (AC-04).
class _UsernameField extends StatelessWidget {
  const _UsernameField({required this.state});

  final EditProfileState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();
    final locked = !state.canChangeUsername;
    return AppTextField(
      key: const Key('editProfile_username'),
      label: 'Tên người dùng',
      initialValue: state.username,
      errorText: state.usernameError,
      helperText: locked
          ? 'Bạn đã hết lượt đổi tên người dùng.'
          : 'Bạn chỉ được đổi tên người dùng thêm ${state.profile?.usernameChangesLeft ?? 0} lần.',
      enabled: !locked && !state.isSaving,
      onChanged: cubit.usernameChanged,
    );
  }
}

/// BR-06: day and month are required together, the year is optional, and the
/// whole thing can be cleared at any time (AC-07).
class _BirthDateField extends StatelessWidget {
  const _BirthDateField({required this.state});

  final EditProfileState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();
    final scheme = context.colorScheme;
    final hasValue =
        state.day.isNotEmpty || state.month.isNotEmpty || state.year.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ngày sinh',
              style: context.textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (hasValue)
              TextButton(
                key: const Key('editProfile_clearBirthDate'),
                onPressed: state.isSaving ? null : cubit.birthDateCleared,
                child: const Text('Xoá'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DatePart(
                fieldKey: const Key('editProfile_birthDay'),
                hint: 'Ngày',
                value: state.day,
                enabled: !state.isSaving,
                onChanged: cubit.dayChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _DatePart(
                fieldKey: const Key('editProfile_birthMonth'),
                hint: 'Tháng',
                value: state.month,
                enabled: !state.isSaving,
                onChanged: cubit.monthChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _DatePart(
                fieldKey: const Key('editProfile_birthYear'),
                hint: 'Năm (tuỳ chọn)',
                value: state.year,
                enabled: !state.isSaving,
                onChanged: cubit.yearChanged,
              ),
            ),
          ],
        ),
        if (state.birthDateError != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            state.birthDateError!,
            key: const Key('editProfile_birthDateError'),
            style: context.textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
        ],
      ],
    );
  }
}

class _DatePart extends StatelessWidget {
  const _DatePart({
    required this.fieldKey,
    required this.hint,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final Key fieldKey;
  final String hint;
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      key: fieldKey,
      hint: hint,
      initialValue: value,
      enabled: enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 4,
      onChanged: onChanged,
    );
  }
}

/// Whole-form problems: an offline save (AC-11) or a server error. The typed
/// values stay on screen behind it.
class _SaveError extends StatelessWidget {
  const _SaveError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      key: const Key('editProfile_saveError'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
