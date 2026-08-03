import 'package:config/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 1, 12);

  AppUpdateConfig config({
    bool enabled = true,
    String latest = '1.2.0',
    String minSupported = '',
    bool force = false,
    int remindAfterHours = 24,
  }) => AppUpdateConfig(
    enabled: enabled,
    latestVersion: latest,
    minSupportedVersion: minSupported,
    isForceUpdate: force,
    remindAfterHours: remindAfterHours,
    storeUrl: 'https://example.com/app',
    title: 'Đã có phiên bản mới',
    message: 'Cập nhật đi',
  );

  AppUpdatePrompt? check(
    AppUpdateConfig cfg, {
    String current = '1.0.0',
    DateTime? lastDismissedAt,
    String? postponedVersion,
  }) => checkAppUpdate(
    config: cfg,
    currentVersion: current,
    now: now,
    lastDismissedAt: lastDismissedAt,
    postponedVersion: postponedVersion,
  );

  group('checkAppUpdate', () {
    test('stays silent when the feature is disabled', () {
      expect(check(config(enabled: false)), isNull);
    });

    test('stays silent when already on the latest version', () {
      expect(check(config(), current: '1.2.0'), isNull);
    });

    test('ignores the build suffix when comparing', () {
      expect(check(config(latest: '1.2.0'), current: '1.2.0+41'), isNull);
    });

    test('forces an update below the minimum supported version', () {
      final prompt = check(config(minSupported: '1.1.0'), current: '1.0.9');
      expect(prompt?.isForced, isTrue);
    });

    test('forces an update when the config marks the release mandatory', () {
      expect(check(config(force: true))?.isForced, isTrue);
    });

    test('prompts softly for a newer optional release', () {
      final prompt = check(config());
      expect(prompt?.isForced, isFalse);
      expect(prompt?.latestVersion, '1.2.0');
    });

    test('stays quiet inside the remind window after a dismissal', () {
      final prompt = check(
        config(),
        lastDismissedAt: now.subtract(const Duration(hours: 5)),
        postponedVersion: '1.2.0',
      );
      expect(prompt, isNull);
    });

    test('prompts again once the remind window has passed', () {
      final prompt = check(
        config(),
        lastDismissedAt: now.subtract(const Duration(hours: 25)),
        postponedVersion: '1.2.0',
      );
      expect(prompt?.isForced, isFalse);
    });

    test('a newer release overrides a dismissal aimed at an older one', () {
      final prompt = check(
        config(latest: '1.3.0'),
        lastDismissedAt: now.subtract(const Duration(minutes: 1)),
        postponedVersion: '1.2.0',
      );
      expect(prompt?.latestVersion, '1.3.0');
    });

    test('never prompts without a store url', () {
      const cfg = AppUpdateConfig(enabled: true, latestVersion: '9.9.9');
      expect(check(cfg), isNull);
    });
  });

  group('AppUpdateConfig.parse', () {
    test('reads the sub-object for the running platform', () {
      const raw = '''
      {
        "enabled": true,
        "remind_after_hours": 6,
        "android": {"latest": "2.0.0", "store_url": "market://a"},
        "ios": {"latest": "1.5.0", "store_url": "itms://i", "force": true}
      }''';

      final ios = AppUpdateConfig.parse(raw, platform: 'ios');
      expect(ios.latestVersion, '1.5.0');
      expect(ios.isForceUpdate, isTrue);
      expect(ios.remindAfterHours, 6);

      final android = AppUpdateConfig.parse(raw, platform: 'android');
      expect(android.latestVersion, '2.0.0');
      expect(android.isForceUpdate, isFalse);
    });

    test('degrades to disabled on empty or malformed payloads', () {
      for (final raw in ['', '   ', 'not json', '[]', '{"android": 7}']) {
        final cfg = AppUpdateConfig.parse(raw, platform: 'android');
        expect(cfg.enabled, isFalse, reason: raw);
        expect(check(cfg), isNull, reason: raw);
      }
    });
  });
}
