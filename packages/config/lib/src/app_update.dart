/// Server-driven app-update gate: the client compares its own version against
/// a Remote Config payload and either blocks (force) or nags (soft).
///
/// Everything here is pure — no Firebase, no plugins, no clock — so the rules
/// are unit-testable and the UI layer only has to render the result.
library;

import 'dart:convert';

/// Remote Config key holding the update payload. Empty/absent (the default)
/// means "never prompt". Set it in the Firebase console as JSON:
///
/// ```json
/// {
///   "enabled": true,
///   "remind_after_hours": 24,
///   "android": {
///     "latest": "1.3.0",
///     "min_supported": "1.1.0",
///     "force": false,
///     "store_url": "https://play.google.com/store/apps/details?id=...",
///     "title": "Đã có phiên bản mới",
///     "message": "Cập nhật ZenPack để dùng bản mới nhất."
///   },
///   "ios": { "latest": "1.3.0", "store_url": "https://apps.apple.com/app/id..." }
/// }
/// ```
///
/// `min_supported` is the hard cutoff (blocking); `force` makes `latest` itself
/// blocking. Omit both for a dismissible nag. `title`/`message` are optional —
/// the app falls back to its own localized strings, which is the right choice
/// unless the release needs a specific explanation.
const appUpdateKey = 'app_update';

/// Tên các THAM SỐ RỜI trên Firebase Remote Config — cách cấu hình đang dùng
/// thật, và là cách được ưu tiên.
///
/// Khác [appUpdateKey] ở chỗ mỗi giá trị là một tham số riêng trong bảng điều
/// khiển Firebase, đúng kiểu:
///
/// ```
/// updatePopupEnabled        (boolean) true
/// updateRemindAfterHours    (number)  24
/// androidLatestVersion      (string)  "2.0.1"
/// androidMinSupportedVersion(string)  "2.0.1"
/// androidIsForceUpdate      (boolean) true
/// androidStoreUrl           (string)  "https://play.google.com/..."
/// androidUpdateTitle        (string)  "Đã có phiên bản Zenpack mới"
/// androidUpdateMessage      (string)  "Cập nhật để có trải nghiệm tốt hơn..."
/// iosLatestVersion, iosMinSupportedVersion, iosIsForceUpdate,
/// iosStoreUrl, iosUpdateTitle, iosUpdateMessage — y hệt cho iOS.
/// ```
///
/// Sửa từng dòng trong bảng điều khiển dễ hơn sửa một khối JSON: đổi một số
/// phiên bản không phải dán lại cả đoạn, và gõ sai một dấu ngoặc không làm câm
/// toàn bộ cổng cập nhật.
class AppUpdateKeys {
  const AppUpdateKeys._();

  static const enabled = 'updatePopupEnabled';
  static const remindAfterHours = 'updateRemindAfterHours';

  static String latest(String platform) => '${platform}LatestVersion';
  static String minSupported(String platform) =>
      '${platform}MinSupportedVersion';
  static String force(String platform) => '${platform}IsForceUpdate';
  static String storeUrl(String platform) => '${platform}StoreUrl';
  static String title(String platform) => '${platform}UpdateTitle';
  static String message(String platform) => '${platform}UpdateMessage';

  /// Mọi tên tham số của một nền tảng — để bên gọi đọc đúng chừng đó khoá, và
  /// để test đối chiếu không sót cái nào.
  static List<String> allFor(String platform) => [
    enabled,
    remindAfterHours,
    latest(platform),
    minSupported(platform),
    force(platform),
    storeUrl(platform),
    title(platform),
    message(platform),
  ];
}

/// The platform-specific half of the update payload, already resolved for the
/// device this code is running on.
class AppUpdateConfig {
  const AppUpdateConfig({
    this.enabled = false,
    this.remindAfterHours = 24,
    this.latestVersion = '',
    this.minSupportedVersion = '',
    this.isForceUpdate = false,
    this.storeUrl = '',
    this.title = '',
    this.message = '',
  });

  /// Parses the Remote Config JSON, picking the `android`/`ios` sub-object for
  /// [platform]. Returns a disabled config on anything malformed — a bad
  /// payload must never prompt, and must never throw at startup.
  factory AppUpdateConfig.parse(String raw, {required String platform}) {
    if (raw.trim().isEmpty) return const AppUpdateConfig();
    try {
      final root = jsonDecode(raw);
      if (root is! Map<String, dynamic>) return const AppUpdateConfig();
      final platformNode = root[platform];
      final node = platformNode is Map<String, dynamic>
          ? platformNode
          : const <String, dynamic>{};
      return AppUpdateConfig(
        enabled: root['enabled'] == true,
        remindAfterHours: (root['remind_after_hours'] as num?)?.toInt() ?? 24,
        latestVersion: node['latest'] as String? ?? '',
        minSupportedVersion: node['min_supported'] as String? ?? '',
        isForceUpdate: node['force'] == true,
        storeUrl: node['store_url'] as String? ?? '',
        title: node['title'] as String? ?? '',
        message: node['message'] as String? ?? '',
      );
    } on Object {
      return const AppUpdateConfig();
    }
  }

  /// Dựng từ các THAM SỐ RỜI đã đọc sẵn khỏi Remote Config.
  ///
  /// Nhận một `Map` chứ không nhận thẳng dịch vụ Remote Config: tệp này cố ý
  /// thuần — không Firebase, không plugin, không đồng hồ — nên luật kiểm phiên
  /// bản test được mà không cần dựng cả một dự án Firebase.
  ///
  /// Thiếu khoá thì rơi về mặc định an toàn: không bật, không chặn ai. Một cấu
  /// hình hỏng KHÔNG được phép khoá người dùng ra khỏi app của họ.
  factory AppUpdateConfig.fromFlat(
    Map<String, Object?> values, {
    required String platform,
  }) {
    String str(String key) {
      final value = values[key];
      return value is String ? value.trim() : '';
    }

    bool flag(String key) {
      final value = values[key];
      // Bảng điều khiển Firebase lưu boolean thành chuỗi ở một số đường đọc,
      // nên "true" phải được hiểu là true — nếu không thì cờ bật mà app coi như
      // tắt, và cổng cập nhật im lặng không ai biết vì sao.
      if (value is bool) return value;
      if (value is String) return value.trim().toLowerCase() == 'true';
      return false;
    }

    final hours = values[AppUpdateKeys.remindAfterHours];
    return AppUpdateConfig(
      enabled: flag(AppUpdateKeys.enabled),
      remindAfterHours: hours is num
          ? hours.toInt()
          : int.tryParse(hours is String ? hours : '') ?? 24,
      latestVersion: str(AppUpdateKeys.latest(platform)),
      minSupportedVersion: str(AppUpdateKeys.minSupported(platform)),
      isForceUpdate: flag(AppUpdateKeys.force(platform)),
      storeUrl: str(AppUpdateKeys.storeUrl(platform)),
      title: str(AppUpdateKeys.title(platform)),
      message: str(AppUpdateKeys.message(platform)),
    );
  }

  /// Master switch. Off means no prompt of any kind, whatever the versions say.
  final bool enabled;

  /// How long a dismissed soft prompt stays quiet. `<= 0` means "every launch".
  final int remindAfterHours;

  final String latestVersion;

  /// Anything below this is cut off: a blocking prompt with no dismiss.
  final String minSupportedVersion;

  /// Makes [latestVersion] itself blocking, without moving the cutoff.
  final bool isForceUpdate;

  final String storeUrl;
  final String title;
  final String message;
}

/// What the UI should show. `null` from [checkAppUpdate] means "nothing".
class AppUpdatePrompt {
  const AppUpdatePrompt({
    required this.isForced,
    required this.latestVersion,
    required this.storeUrl,
    required this.title,
    required this.message,
  });

  /// Blocking: the dialog has no "later" and the app stays behind it.
  final bool isForced;

  final String latestVersion;
  final String storeUrl;
  final String title;
  final String message;
}

/// Decides whether to prompt, given the device's [currentVersion] and what the
/// user already dismissed.
///
/// [lastDismissedAt] / [postponedVersion] are the two values the caller
/// persists when a soft prompt is dismissed. A config `latestVersion` newer
/// than [postponedVersion] resets the quiet period, so a fresh release is
/// never silenced by a dismissal aimed at an older one.
AppUpdatePrompt? checkAppUpdate({
  required AppUpdateConfig config,
  required String currentVersion,
  required DateTime now,
  DateTime? lastDismissedAt,
  String? postponedVersion,
}) {
  if (!config.enabled) return null;
  if (config.latestVersion.isEmpty || config.storeUrl.isEmpty) return null;

  final current = _Version.parse(currentVersion);
  final latest = _Version.parse(config.latestVersion);
  if (current == null || latest == null) return null;

  AppUpdatePrompt prompt({required bool isForced}) => AppUpdatePrompt(
    isForced: isForced,
    latestVersion: config.latestVersion,
    storeUrl: config.storeUrl,
    title: config.title,
    message: config.message,
  );

  final minSupported = _Version.parse(config.minSupportedVersion);
  if (minSupported != null && current < minSupported) {
    return prompt(isForced: true);
  }
  if (current >= latest) return null;
  if (config.isForceUpdate) return prompt(isForced: true);

  final postponed = _Version.parse(postponedVersion ?? '');
  final supersedesDismissal = postponed == null || latest > postponed;
  if (supersedesDismissal ||
      _isQuietPeriodOver(lastDismissedAt, config.remindAfterHours, now)) {
    return prompt(isForced: false);
  }
  return null;
}

bool _isQuietPeriodOver(
  DateTime? lastDismissedAt,
  int remindAfterHours,
  DateTime now,
) {
  if (remindAfterHours <= 0 || lastDismissedAt == null) return true;
  return !now.isBefore(lastDismissedAt.add(Duration(hours: remindAfterHours)));
}

/// Dotted numeric version, comparing segment by segment. Build/pre-release
/// suffixes (`1.2.0+41`, `1.2.0-beta`) are cut off before parsing — the store
/// version is what matters, not the build number.
class _Version implements Comparable<_Version> {
  const _Version(this._parts);

  static _Version? parse(String raw) {
    final core = raw.trim().split(RegExp('[+-]')).first;
    if (core.isEmpty) return null;
    final parts = <int>[];
    for (final segment in core.split('.')) {
      final value = int.tryParse(segment);
      if (value == null) return null;
      parts.add(value);
    }
    return _Version(parts);
  }

  final List<int> _parts;

  @override
  int compareTo(_Version other) {
    final length = _parts.length > other._parts.length
        ? _parts.length
        : other._parts.length;
    for (var i = 0; i < length; i++) {
      final a = i < _parts.length ? _parts[i] : 0;
      final b = i < other._parts.length ? other._parts[i] : 0;
      if (a != b) return a.compareTo(b);
    }
    return 0;
  }

  bool operator <(_Version other) => compareTo(other) < 0;
  bool operator >(_Version other) => compareTo(other) > 0;
  bool operator >=(_Version other) => compareTo(other) >= 0;
}
