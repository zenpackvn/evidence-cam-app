import 'package:go_router/go_router.dart';

import 'screens/avatar_upload_screen.dart';
import 'screens/choose_username_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/verify_email_screen.dart';

/// Canonical navigation paths owned by the auth feature.
///
/// The feature navigates by pushing these via `go_router`'s `context.go`, so it
/// doesn't depend on the app shell.
abstract final class AuthRoutes {
  /// The login screen.
  static const login = '/login';

  /// The registration screen.
  static const register = '/register';

  /// The forgot-password screen (enter email → receive reset code).
  static const forgotPassword = '/forgot-password';

  /// The email-verification screen (6-digit code after email sign-up).
  static const verifyEmail = '/verify-email';

  /// The username-selection screen (shown after first authentication).
  static const chooseUsername = '/choose-username';

  /// The avatar-upload step after choosing a username (F01-S10).
  static const avatarUpload = '/avatar-upload';

  /// The change-password screen (nested under the profile tab, mounted by the
  /// app shell because it lives inside the profile branch).
  static const changePassword = '/profile/change-password';
}

/// The auth feature's unauthenticated routes, mounted by the host app.
///
/// `changePassword` is not listed here: it is nested under the app shell's
/// profile tab, so the shell mounts it directly.
List<RouteBase> get authRoutes => [
  GoRoute(
    path: AuthRoutes.login,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: AuthRoutes.register,
    builder: (context, state) => const RegisterScreen(),
  ),
  GoRoute(
    path: AuthRoutes.forgotPassword,
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    path: AuthRoutes.verifyEmail,
    builder: (context, state) => VerifyEmailScreen(
      email: state.uri.queryParameters['email'] ?? '',
      onVerified: () => context.go(AuthRoutes.chooseUsername),
    ),
  ),
  GoRoute(
    path: AuthRoutes.chooseUsername,
    builder: (context, state) => ChooseUsernameScreen(
      onDone: (_) => context.go(AuthRoutes.avatarUpload),
    ),
  ),
  GoRoute(
    path: AuthRoutes.avatarUpload,
    // The host app wires the image picker; the route keeps the flow moving
    // (avatar upload itself lands with the profile API).
    builder: (context, state) => AvatarUploadScreen(
      onDone: () => context.go('/'),
    ),
  ),
];
