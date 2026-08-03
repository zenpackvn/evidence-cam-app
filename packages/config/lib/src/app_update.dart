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
