/// EvidenceCam screens, built pixel-perfect from
/// `specs/projects/evidencecam/design-spec/pencil-new.pen`.
///
/// These are presentational (data-in, callbacks-out) so they can be verified in
/// isolation now and wired to auth/router as those land. Every dimension, gap,
/// font size/weight and color is taken directly from the design file.
library;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

// Shared text styles (Inter is inherited from AppTheme's textTheme).
TextStyle _t(double size, FontWeight weight, Color color) =>
    TextStyle(fontSize: size, fontWeight: weight, color: color, height: 1.3);

/// Splash — logo, app name, tagline, primary "Bắt đầu" button, version.
class EcSplashScreen extends StatelessWidget {
  const EcSplashScreen({this.onStart, this.version = 'v1.0.0', super.key});

  final VoidCallback? onStart;
  final String version;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/icons/logo.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ZenPack',
                      style: _t(28, FontWeight.w700, BrandColors.ink),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 260,
                      child: Text(
                        'Quay video bằng chứng đóng hàng cho seller TMĐT',
                        textAlign: TextAlign.center,
                        style: _t(14, FontWeight.w400, BrandColors.mut),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _EcPrimaryButton(label: 'Bắt đầu', onPressed: onStart),
              const SizedBox(height: 16),
              Text(version, style: _t(11, FontWeight.w400, BrandColors.mut)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Login — language chip, title, email/password fields, forgot link, primary
/// login button, "hoặc" divider, Google + Apple buttons, register footer.
class EcLoginScreen extends StatelessWidget {
  const EcLoginScreen({
    this.emailController,
    this.passwordController,
    this.onLogin,
    this.onForgot,
    this.onGoogle,
    this.onApple,
    this.onRegister,
    this.onLanguage,
    super.key,
  });

  final TextEditingController? emailController;
  final TextEditingController? passwordController;
  final VoidCallback? onLogin;
  final VoidCallback? onForgot;
  final VoidCallback? onGoogle;
  final VoidCallback? onApple;
  final VoidCallback? onRegister;
  final VoidCallback? onLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: _LangChip(onTap: onLanguage),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Column(
                        children: [
                          Text(
                            'Đăng nhập',
                            style: _t(24, FontWeight.w700, BrandColors.ink),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Chọn phương thức đăng nhập',
                            style: _t(13, FontWeight.w400, BrandColors.mut),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      label: 'Email',
                      hint: 'ban@email.com',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      label: 'Mật khẩu',
                      hint: '••••••••',
                      controller: passwordController,
                      obscure: true,
                      trailing: Icons.visibility_outlined,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: onForgot,
                        child: Text(
                          'Quên mật khẩu?',
                          style: _t(13, FontWeight.w500, BrandColors.ink),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _EcPrimaryButton(label: 'Đăng nhập', onPressed: onLogin),
                    const SizedBox(height: 12),
                    const _OrDivider(),
                    const SizedBox(height: 12),
                    _SocialButton(
                      label: 'Đăng nhập với Google',
                      background: Colors.white,
                      borderColor: const Color(0xFFDADCE0),
                      foreground: const Color(0xFF3C4043),
                      icon: Icons.g_mobiledata,
                      iconColor: const Color(0xFF4285F4),
                      onPressed: onGoogle,
                    ),
                    const SizedBox(height: 12),
                    _SocialButton(
                      label: 'Đăng nhập với Apple',
                      background: Colors.black,
                      borderColor: Colors.black,
                      foreground: Colors.white,
                      icon: Icons.apple,
                      iconColor: Colors.white,
                      onPressed: onApple,
                    ),
                    const Spacer(),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Bạn chưa có tài khoản? ',
                          style: _t(13, FontWeight.w400, BrandColors.mut),
                        ),
                        GestureDetector(
                          onTap: onRegister,
                          child: Text(
                            'Đăng ký',
                            style: _t(13, FontWeight.w600, BrandColors.ink),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- shared pieces (pixel specs from pencil-new.pen) ---

class _EcPrimaryButton extends StatelessWidget {
  const _EcPrimaryButton({required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: BrandColors.dark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _t(16, FontWeight.w600, Colors.white),
        ),
        child: Text(label),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: BrandColors.line),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 14, color: BrandColors.ink),
            const SizedBox(width: 5),
            Text('VI', style: _t(12, FontWeight.w600, BrandColors.ink)),
            const SizedBox(width: 5),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 12,
              color: BrandColors.mut,
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    this.controller,
    this.obscure = false,
    this.trailing,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  final IconData? trailing;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: _t(14, FontWeight.w500, BrandColors.ink)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: _t(15, FontWeight.w400, BrandColors.ink),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: BrandColors.bg,
            hintText: hint,
            hintStyle: _t(15, FontWeight.w400, BrandColors.mut),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            suffixIcon: trailing == null
                ? null
                : Icon(trailing, size: 18, color: BrandColors.mut),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 24,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: BrandColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: BrandColors.dark, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: BrandColors.line, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('hoặc', style: _t(12, FontWeight.w400, BrandColors.mut)),
        ),
        const Expanded(child: Divider(color: BrandColors.line, height: 1)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.background,
    required this.borderColor,
    required this.foreground,
    required this.icon,
    required this.iconColor,
    this.onPressed,
  });

  final String label;
  final Color background;
  final Color borderColor;
  final Color foreground;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 54,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: _t(15, FontWeight.w500, foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
