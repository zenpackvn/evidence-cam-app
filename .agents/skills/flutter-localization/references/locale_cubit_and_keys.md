# Localization — LocaleCubit and Translation Keys

## `LocaleCubit` — `lib/src/core/localization/locale_cubit.dart`

Drives reactive locale switching. Provided at app root so all widgets using `context.tr()` rebuild when the locale changes.

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../base/safe_emit_mixin.dart';
import 'localization_service.dart';

class LocaleCubit extends Cubit<Locale> with SafeEmitMixin<Locale> {
  LocaleCubit({required LocalizationService localization})
      : _localization = localization,
        super(localization.currentLocale);

  final LocalizationService _localization;

  Future<void> setLanguage(Locale locale) async {
    await _localization.setLocale(locale);
    safeEmit(locale);
  }
}
```

---

## Translation Keys — `lib/src/core/localization/app_locale.dart`

```dart
/// Translation key constants.
///
/// Convention:
/// - Group by feature prefix: `home_`, `auth_`, `post_`, `common_`.
/// - Plurals use `_zero`, `_one`, `_other` suffixes.
/// - Parameters use `%s` (positional) or `{name}` (named).
mixin AppLocale {
  // ── English ──────────────────────────────────────────────
  static const Map<String, dynamic> en = {
    // Common
    'common_ok': 'OK',
    'common_cancel': 'Cancel',
    'common_save': 'Save',
    'common_delete': 'Delete',
    'common_retry': 'Retry',
    'common_loading': 'Loading…',
    'common_error': 'Something went wrong',
    'common_empty': 'Nothing here yet',

    // Greeting with positional param
    'common_greeting': 'Hello, %s!',

    // Plurals
    'item_count_zero': 'No items',
    'item_count_one': '1 item',
    'item_count_other': '%d items',

    // Named params
    'order_summary': 'You ordered {count} {item}.',

    // Home
    'home_title': 'Home',
    'home_welcome': 'Welcome back, %s',

    // Auth
    'auth_login': 'Log In',
    'auth_logout': 'Log Out',
    'auth_email_hint': 'Email address',
    'auth_password_hint': 'Password',
    'auth_forgot_password': 'Forgot password?',

    // Settings
    'settings_title': 'Settings',
    'settings_language': 'Language',
    'settings_theme': 'Theme',
  };

  // ── Vietnamese ───────────────────────────────────────────
  static const Map<String, dynamic> vi = {
    'common_ok': 'Đồng ý',
    'common_cancel': 'Hủy',
    'common_save': 'Lưu',
    'common_delete': 'Xóa',
    'common_retry': 'Thử lại',
    'common_loading': 'Đang tải…',
    'common_error': 'Đã xảy ra lỗi',
    'common_empty': 'Chưa có gì ở đây',
    'common_greeting': 'Xin chào, %s!',
    'item_count_zero': 'Không có mục nào',
    'item_count_one': '1 mục',
    'item_count_other': '%d mục',
    'order_summary': 'Bạn đã đặt {count} {item}.',
    'home_title': 'Trang chủ',
    'home_welcome': 'Chào mừng trở lại, %s',
    'auth_login': 'Đăng nhập',
    'auth_logout': 'Đăng xuất',
    'auth_email_hint': 'Địa chỉ email',
    'auth_password_hint': 'Mật khẩu',
    'auth_forgot_password': 'Quên mật khẩu?',
    'settings_title': 'Cài đặt',
    'settings_language': 'Ngôn ngữ',
    'settings_theme': 'Giao diện',
  };

  // ── Arabic (RTL) ────────────────────────────────────────
  static const Map<String, dynamic> ar = {
    'common_ok': 'موافق',
    'common_cancel': 'إلغاء',
    'common_save': 'حفظ',
    'common_delete': 'حذف',
    'common_retry': 'إعادة المحاولة',
    'common_loading': 'جار التحميل…',
    'common_error': 'حدث خطأ ما',
    'common_empty': 'لا يوجد شيء هنا بعد',
    'common_greeting': '!%s ،مرحبًا',
    'item_count_zero': 'لا توجد عناصر',
    'item_count_one': 'عنصر واحد',
    'item_count_other': '%d عناصر',
    'order_summary': '.{item} {count} لقد طلبت',
    'home_title': 'الرئيسية',
    'home_welcome': '%s ،مرحبًا بعودتك',
    'auth_login': 'تسجيل الدخول',
    'auth_logout': 'تسجيل الخروج',
    'auth_email_hint': 'عنوان البريد الإلكتروني',
    'auth_password_hint': 'كلمة المرور',
    'auth_forgot_password': 'نسيت كلمة المرور؟',
    'settings_title': 'الإعدادات',
    'settings_language': 'اللغة',
    'settings_theme': 'المظهر',
  };
}
```

---

## Key naming conventions

| Convention | Example key | Example value |
|---|---|---|
| Feature prefix | `home_title`, `auth_login` | Groups keys by screen/feature |
| Common prefix | `common_ok`, `common_cancel` | Shared across features |
| Positional param | `common_greeting` | `"Hello, %s!"` |
| Named params | `order_summary` | `"You ordered {count} {item}."` |
| Plural zero | `item_count_zero` | `"No items"` |
| Plural one | `item_count_one` | `"1 item"` |
| Plural other | `item_count_other` | `"%d items"` |

### Rules

1. Use `snake_case` — consistent with Dart conventions.
2. Prefix with feature name — `auth_`, `home_`, `post_`, `settings_`.
3. Use `common_` for shared strings — OK, Cancel, Save, Delete, Retry.
4. Plural keys always have `_zero`, `_one`, `_other` suffixes.
5. Never concatenate translated strings — use parameterized messages instead.
6. Keep keys stable — changing a key breaks all translations.
7. When adding a key to one language, add it to all languages immediately. Missing keys return the raw key string.
