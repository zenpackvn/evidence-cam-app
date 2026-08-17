/// Server-driven app-update gate: the client compares its own version against
/// a Remote Config payload and either blocks (force) or nags (soft).
///
/// Everything here is pure — no Firebase, no plugins, no clock — so the rules
/// are unit-testable and the UI layer only has to render the result.
library;

import 'dart:convert';

/// Tham số Remote Config DUY NHẤT chứa cấu hình cập nhật: một khối JSON phẳng,
/// tên khoá bên trong trùng khít [AppUpdateKeys].
///
/// ```json
/// {
///   "updatePopupEnabled": true,
///   "updateRemindAfterHours": 24,
///   "androidLatestVersion": "2.0.1",
///   "androidMinSupportedVersion": "2.0.1",
///   "androidIsForceUpdate": true,
///   "androidStoreUrl": "https://play.google.com/store/apps/details?id=...",
///   "androidUpdateTitle": "Đã có phiên bản Zenpack mới",
///   "androidUpdateMessage": "Cập nhật để có trải nghiệm tốt hơn...",
///   "iosLatestVersion": "2.0.0", "iosMinSupportedVersion": "2.0.0",
///   "iosIsForceUpdate": true,
///   "iosStoreUrl": "https://apps.apple.com/app/id..."
/// }
/// ```
///
/// Khoá vắng mặt hoặc rỗng (mặc định) nghĩa là "đừng nhắc ai cả".
/// `*MinSupportedVersion` là mốc chặn cứng; `*IsForceUpdate` biến
/// `*LatestVersion` thành chặn cứng. Bỏ cả hai thì chỉ là lời nhắc bỏ qua
/// được. `*UpdateTitle`/`*UpdateMessage` không bắt buộc — thiếu thì app dùng
/// chuỗi đã dịch của chính nó, và đó mới là lựa chọn đúng trừ khi bản phát
/// hành cần một lời giải thích riêng.
const appUpdateBlobKey = 'change_version_zenpack';

/// Tên các khoá bên trong khối JSON của [appUpdateBlobKey].
///
/// Tách riêng thành hằng số vì đây là hợp đồng với bảng điều khiển Firebase:
/// gõ sai một tên ở đây thì cổng cập nhật câm lặng, không có lỗi nào nổ.
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

  /// Đọc khối JSON của [appUpdateBlobKey].
  ///
  /// Rỗng, không phải JSON, hay không phải một object đều rơi về "không bật,
  /// không chặn ai": một cấu hình hỏng KHÔNG được phép khoá người dùng ra khỏi
  /// app của họ, và cũng không được phép ném lỗi lúc khởi động.
  factory AppUpdateConfig.parse(String raw, {required String platform}) {
    if (raw.trim().isEmpty) return const AppUpdateConfig();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) return const AppUpdateConfig();
      return AppUpdateConfig.fromFlat(decoded, platform: platform);
    } on Object {
      return const AppUpdateConfig();
    }
  }

  /// Dựng từ một `Map` đã giải mã sẵn.
  ///
  /// Nhận một `Map` chứ không nhận thẳng dịch vụ Remote Config: tệp này cố ý
  /// thuần — không Firebase, không plugin, không đồng hồ — nên luật kiểm phiên
  /// bản test được mà không cần dựng cả một dự án Firebase.
  ///
  /// Bảng điều khiển Firebase lưu số thành chuỗi ở một số đường đọc, nên mọi
  /// trường đều nhận cả hai kiểu.
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
