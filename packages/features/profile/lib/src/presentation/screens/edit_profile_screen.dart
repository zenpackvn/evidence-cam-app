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
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({this.picker, this.cubit, super.key});

  /// Supplied by the host (the router) so the feature does not reach into the
  /// platform itself. Null in contexts without a picker (some tests), where the
  /// avatar tap is simply inert.
  final ImagePickerService? picker;

  /// When the host already owns the cubit (so the profile mirrors edits live),
  /// it is shared in rather than created here. Otherwise a fresh one is made.
  final EditProfileCubit? cubit;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final bool _ownsCubit = widget.cubit == null;
  late final EditProfileCubit _cubit =
      widget.cubit ?? getIt<EditProfileCubit>();

  @override
  void initState() {
    super.initState();
    // Load only when there's nothing yet — reopening the screen must NOT re-fetch
    // and wipe a previously-saved edit, so what the user changed sticks until
    // they change it again. Loading here (not in build) also keeps focus/typed
    // text across the rebuilds a keyboard show/hide triggers.
    if (_cubit.state.profile == null) _cubit.load();
  }

  @override
  void dispose() {
    if (_ownsCubit) _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditProfileCubit>.value(
      value: _cubit,
      child: EditProfileBody(picker: widget.picker),
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
      builder: (context, state) {
        final ready =
            state.status != EditProfileStatus.loading &&
            state.status != EditProfileStatus.loadFailure;
        return ProfileSubScaffold(
          title: 'Sửa hồ sơ',
          trailing: ready
              ? TextButton(
                  key: const Key('editProfile_save'),
                  onPressed: state.isSaving
                      ? null
                      : context.read<EditProfileCubit>().save,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: context.colorScheme.primary,
                    textStyle: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: state.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Lưu'),
                )
              : null,
          child: switch (state.status) {
            EditProfileStatus.loading => const Center(child: AppLoading()),
            EditProfileStatus.loadFailure => _LoadFailure(
              message: state.saveError,
              onRetry: () => context.read<EditProfileCubit>().load(),
            ),
            _ => _Form(state: state, picker: picker),
          },
        );
      },
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

  static const _border = Color(0xFFEFE9E3);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();
    // Tapping any empty area (or dragging the list) dismisses the keyboard, so
    // typing stops until the user taps a field again.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          _AvatarCard(state: state, picker: picker),
          const SizedBox(height: 12),
          // A whole-form problem (offline save / taken username) shows near the
          // top so it is visible without scrolling past the form.
          if (state.saveError != null) ...[
            _SaveError(message: state.saveError!),
            const SizedBox(height: 12),
          ],
          // The single white form card (fg0291): each field is a labelled section
          // separated by hairline dividers.
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.brand.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F24211F),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel('Tên hiển thị'),
                const SizedBox(height: AppSpacing.sm),
                // BR-02: freely editable, at most 30 characters. Not hard-capped —
                // §5 asks for an error at the field when it is exceeded.
                _SyncedField(
                  fieldKey: const Key('editProfile_displayName'),
                  hint: 'Tên bạn muốn hiển thị',
                  value: state.displayName,
                  errorText: state.displayNameError,
                  textCapitalization: TextCapitalization.words,
                  enabled: !state.isSaving,
                  onChanged: cubit.displayNameChanged,
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${state.displayName.runes.length}/$displayNameMaxLength',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const _Divider(color: _border),
                const _FieldLabel('Username'),
                const SizedBox(height: AppSpacing.sm),
                _UsernameField(state: state),
                const _Divider(color: _border),
                const _FieldLabel('Ngày sinh'),
                const SizedBox(height: AppSpacing.sm),
                _BirthDateField(state: state),
                const SizedBox(height: AppSpacing.md),
                const _PrivacyToggle(),
                const SizedBox(height: AppSpacing.md),
                const _BirthDateNote(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A field's leading label: a soft-pink icon chip and a bold title (fg0291).
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFFDE8EC),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.auto_awesome,
            size: 13,
            color: context.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Divider(height: 1, color: color),
  );
}

/// The "show my birthday to others" toggle (fg0291 privacy). UI-only local
/// state for now — there is no birthday-visibility field on the profile yet.
class _PrivacyToggle extends StatefulWidget {
  const _PrivacyToggle();

  @override
  State<_PrivacyToggle> createState() => _PrivacyToggleState();
}

class _PrivacyToggleState extends State<_PrivacyToggle> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFFDF1E0),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_outline,
            size: 18,
            color: Color(0xFFF47A43),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Hiển thị ngày & tháng cho người khác',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Switch(
          value: _on,
          activeThumbColor: Colors.white,
          activeTrackColor: context.colorScheme.primary,
          onChanged: (v) => setState(() => _on = v),
        ),
      ],
    );
  }
}

/// The soft explanatory note under the birthday (fg0291 note).
class _BirthDateNote extends StatelessWidget {
  const _BirthDateNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F0E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 15,
            color: context.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ngày sinh của bạn giúp cá nhân hóa trải nghiệm và gợi ý nội '
              'dung phù hợp hơn.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// SM-024 avatar (fg0291 avCard): the current picture with a camera badge,
/// a title/subtitle, and a "Thay đổi ảnh" button — all opening pick → crop →
/// upload. A spinner replaces the edit badge while the new avatar saves.
class _AvatarCard extends StatelessWidget {
  const _AvatarCard({required this.state, this.picker});

  final EditProfileState state;
  final ImagePickerService? picker;

  static const _size = 92.0;

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
    final onTap = state.isSavingAvatar ? null : () => _pickAndCrop(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.brand.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F24211F),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Đổi ảnh đại diện',
            child: InkWell(
              key: const Key('editProfile_avatar'),
              onTap: onTap,
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
                        child: state.pendingAvatarBytes != null
                            ? Image.memory(
                                state.pendingAvatarBytes!,
                                fit: BoxFit.cover,
                              )
                            : avatarUrl.isEmpty
                            ? ColoredBox(
                                color: scheme.primaryContainer,
                                child: Center(
                                  child: Text(
                                    initial,
                                    style: context.textTheme.displaySmall
                                        ?.copyWith(
                                          color: scheme.onPrimaryContainer,
                                        ),
                                  ),
                                ),
                              )
                            : AppNetworkImage(imageUrl: avatarUrl),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.primary,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: state.isSavingAvatar
                            ? const SizedBox(
                                width: 13,
                                height: 13,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 13,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ảnh đại diện',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chọn ảnh đại diện giúp bạn bè nhận ra bạn dễ dàng hơn.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Thay đổi ảnh'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.onSurface,
                    side: const BorderSide(color: Color(0xFFDED6CF)),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SyncedField(
          fieldKey: const Key('editProfile_username'),
          value: state.username,
          errorText: state.usernameError,
          enabled: !state.isSaving,
          onChanged: cubit.usernameChanged,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                'Bạn có thể đổi username bất cứ lúc nào.',
                style: context.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            if (state.usernameError == null) ...[
              const Icon(
                Icons.check_circle,
                size: 14,
                color: Color(0xFF2F7A55),
              ),
              const SizedBox(width: 4),
              Text(
                'Đang sử dụng',
                style: context.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF2F7A55),
                ),
              ),
            ],
          ],
        ),
      ],
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
        if (hasValue)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const Key('editProfile_clearBirthDate'),
              onPressed: state.isSaving ? null : cubit.birthDateCleared,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Xoá'),
            ),
          ),
        if (hasValue) const SizedBox(height: AppSpacing.xs),
        Row(
          // Keyed so the row (and the focused date field) is preserved when the
          // "Xoá" button appears above it — otherwise the row is rebuilt on the
          // first digit and the keyboard closes.
          key: const ValueKey('editProfile_dobRow'),
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
    return _SyncedField(
      fieldKey: fieldKey,
      hint: hint,
      value: value,
      enabled: enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 4,
      onChanged: onChanged,
    );
  }
}

/// A text field backed by its own [TextEditingController], so typing survives
/// the form rebuilding on every keystroke — the field never loses focus or
/// jumps. External changes (a load, or the "Xoá" clear) still flow in: when
/// [value] differs from the controller (i.e. it changed from outside, not from
/// the user's own keystroke), the controller is synced to it.
class _SyncedField extends StatefulWidget {
  const _SyncedField({
    required this.fieldKey,
    required this.value,
    required this.onChanged,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
  });

  final Key fieldKey;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  @override
  State<_SyncedField> createState() => _SyncedFieldState();
}

class _SyncedFieldState extends State<_SyncedField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(_SyncedField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Never rewrite the field while the user is editing it: replacing the
    // controller value drops the IME composing region, which breaks Vietnamese
    // (Telex/VNI) diacritics mid-word — you literally cannot type "â"/"ế". So
    // adopt an external value only when the field is not focused (initial load,
    // a programmatic reset), and let the controller own the text while typing.
    if (!_focusNode.hasFocus && widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      key: widget.fieldKey,
      controller: _controller,
      focusNode: _focusNode,
      hint: widget.hint,
      errorText: widget.errorText,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      textCapitalization: widget.textCapitalization,
      onChanged: widget.onChanged,
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
