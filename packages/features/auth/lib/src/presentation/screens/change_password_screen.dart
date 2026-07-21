import 'package:app_ui/app_ui.dart';
import 'package:architecture/architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';

import '../../locator.dart';
import '../bloc/change_password_cubit.dart';
import '../bloc/change_password_state.dart';

/// F07-S07 — "Đổi mật khẩu": current + new + confirm, then Firebase
/// reauthenticates and updates the password, so the next sign-in uses the new
/// one. Matched to `pencil-new.pen` fg0454.
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChangePasswordCubit>(
      create: (_) => getIt<ChangePasswordCubit>(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static const _ground = Color(0xFFFBF1E9);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await context.read<ChangePasswordCubit>().submit(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );
  }

  String _localizeFailure(Failure failure) => switch (failure) {
    InvalidCredentialsFailure() => context.l10n.errorInvalidInput,
    _ => context.l10n.errorUnknown,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return BlocListener<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state is ChangePasswordSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(context.l10n.changePasswordSuccessMessage),
              ),
            );
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: _ground,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: _Header(
                  title: context.l10n.changePasswordAppBarTitle,
                  onBack: () => Navigator.of(context).maybePop(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                    builder: (context, state) {
                      final isSubmitting = state is ChangePasswordSubmitting;
                      final errorMessage = state is ChangePasswordFailure
                          ? _localizeFailure(state.failure)
                          : null;
                      return Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xxl,
                            0,
                            AppSpacing.xxl,
                            AppSpacing.xxl,
                          ),
                          children: [
                            const _IntroCard(
                              text:
                                  'Vì lý do bảo mật, vui lòng sử dụng mật khẩu '
                                  'mạnh và không chia sẻ cho người khác.',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: context.brand.surfaceElevated,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xxl,
                                ),
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
                                  _PasswordField(
                                    controller: _currentPasswordController,
                                    label:
                                        context.l10n.changePasswordCurrentLabel,
                                    hint: 'Nhập mật khẩu hiện tại',
                                    enabled: !isSubmitting,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) =>
                                        (value == null || value.isEmpty)
                                        ? context.l10n.fieldRequired
                                        : null,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  _PasswordField(
                                    controller: _newPasswordController,
                                    label: context.l10n.changePasswordNewLabel,
                                    hint: 'Nhập mật khẩu mới',
                                    enabled: !isSubmitting,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) =>
                                        (value == null || value.isEmpty)
                                        ? context.l10n.fieldRequired
                                        : null,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  _PasswordField(
                                    controller: _confirmPasswordController,
                                    label:
                                        context.l10n.changePasswordConfirmLabel,
                                    hint: 'Nhập lại mật khẩu mới',
                                    enabled: !isSubmitting,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _submit(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return context.l10n.fieldRequired;
                                      }
                                      if (value !=
                                          _newPasswordController.text) {
                                        return context
                                            .l10n
                                            .changePasswordMismatchError;
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            if (errorMessage != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                errorMessage,
                                style: TextStyle(color: scheme.error),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            SizedBox(
                              height: 54,
                              child: FilledButton.icon(
                                onPressed: isSubmitting ? null : _submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: scheme.primary,
                                  shape: const StadiumBorder(),
                                  textStyle: context.textTheme.titleMedium,
                                ),
                                icon: isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.lock_outline, size: 20),
                                label: Text(context.l10n.changePasswordSubmit),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const _RequirementNote(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Back button + centered title (fg0454 header).
class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: context.brand.surfaceElevated,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onBack,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.chevron_left, size: 22),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: context.textTheme.displayMedium?.copyWith(fontSize: 22),
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }
}

/// The soft security intro (fg0454): a lock chip and a short reason.
class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.brand.softPeach,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFDE8E4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              size: 18,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
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

/// The green "password requirements" note (fg0454).
class _RequirementNote extends StatelessWidget {
  const _RequirementNote();

  static const _green = Color(0xFF2F7A55);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F5EE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user_outlined, size: 16, color: _green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sử dụng ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và '
              'ký tự đặc biệt.',
              style: context.textTheme.bodySmall?.copyWith(color: _green),
            ),
          ),
        ],
      ),
    );
  }
}

/// A labelled password input with a show/hide eye toggle (fg0454).
class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final FormFieldValidator<String> validator;
  final bool enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _obscure,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
