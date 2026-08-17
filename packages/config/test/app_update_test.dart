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

  group('AppUpdateConfig.parse (khối JSON $appUpdateBlobKey)', () {
    // Đúng nguyên văn giá trị đang nằm trên Firebase, dán lại chứ không dựng
    // lại từ hằng số: test này để bắt lúc khối JSON thật lệch khỏi thứ app đọc
    // được, nên nó phải là bản sao độc lập.
    const raw = '''
    {
      "updatePopupEnabled": true,
      "updateRemindAfterHours": 24,
      "androidLatestVersion": "2.0.1",
      "androidMinSupportedVersion": "2.0.1",
      "androidIsForceUpdate": true,
      "androidStoreUrl": "https://play.google.com/store/apps/details?id=com.aktechvn.zenpack",
      "androidUpdateTitle": "Đã có phiên bản Zenpack mới",
      "androidUpdateMessage": "Cập nhật để có trải nghiệm tốt hơn...",
      "iosLatestVersion": "2.0.0",
      "iosMinSupportedVersion": "2.0.0",
      "iosIsForceUpdate": true,
      "iosStoreUrl": "https://apps.apple.com/app/id6794540715",
      "iosUpdateTitle": "Đã có phiên bản Zenpack mới",
      "iosUpdateMessage": "Cập nhật để có trải nghiệm tốt hơn..."
    }''';

    test('tách đúng phần của từng nền tảng', () {
      final android = AppUpdateConfig.parse(raw, platform: 'android');
      expect(android.enabled, isTrue);
      expect(android.remindAfterHours, 24);
      expect(android.latestVersion, '2.0.1');
      expect(android.minSupportedVersion, '2.0.1');
      expect(android.isForceUpdate, isTrue);
      expect(android.storeUrl, contains('com.aktechvn.zenpack'));

      final ios = AppUpdateConfig.parse(raw, platform: 'ios');
      expect(ios.latestVersion, '2.0.0');
      expect(ios.storeUrl, contains('id6794540715'));
    });

    // Khối JSON thật và bảng tham số rời phải cho ra cùng một quyết định —
    // nếu không thì một trong hai đang nói dối.
    test('quyết định y hệt khi dựng thẳng từ Map', () {
      final fromJson = AppUpdateConfig.parse(raw, platform: 'android');
      final prompt = checkAppUpdate(
        config: fromJson,
        currentVersion: '2.0.0',
        now: DateTime(2026, 8, 17),
      );
      expect(prompt!.isForced, isTrue);
      expect(prompt.title, 'Đã có phiên bản Zenpack mới');
    });

    test('rỗng hoặc hỏng thì tắt hẳn, không chặn ai', () {
      for (final bad in ['', '   ', 'not json', '[]', '{"androidLatest": ']) {
        final cfg = AppUpdateConfig.parse(bad, platform: 'android');
        expect(cfg.enabled, isFalse, reason: bad);
        expect(check(cfg), isNull, reason: bad);
      }
    });
  });

  group('cấu hình dạng tham số rời', () {
    test('đọc đúng mọi trường của Android', () {
      final c = AppUpdateConfig.fromFlat(_live, platform: 'android');
      expect(c.enabled, isTrue);
      expect(c.remindAfterHours, 24);
      expect(c.latestVersion, '2.0.1');
      expect(c.minSupportedVersion, '2.0.1');
      expect(c.isForceUpdate, isTrue);
      expect(c.storeUrl, contains('play.google.com'));
      expect(c.title, 'Đã có phiên bản Zenpack mới');
    });

    test('đọc đúng mọi trường của iOS, không lẫn sang Android', () {
      final c = AppUpdateConfig.fromFlat(_live, platform: 'ios');
      expect(c.latestVersion, '2.0.0');
      expect(c.storeUrl, contains('apps.apple.com'));
      expect(c.storeUrl, isNot(contains('play.google.com')));
    });

    // Bảng điều khiển Firebase lưu boolean thành CHUỖI ở một số đường đọc. Hiểu
    // "true" là false thì cờ bật mà app coi như tắt, và cổng cập nhật im lặng
    // không ai biết vì sao.
    test('boolean gửi về dạng chuỗi vẫn hiểu đúng', () {
      final c = AppUpdateConfig.fromFlat({
        ..._live,
        'updatePopupEnabled': 'true',
        'androidIsForceUpdate': 'true',
      }, platform: 'android');
      expect(c.enabled, isTrue);
      expect(c.isForceUpdate, isTrue);
    });

    test('số gửi về dạng chuỗi vẫn hiểu đúng', () {
      final c = AppUpdateConfig.fromFlat({
        ..._live,
        'updateRemindAfterHours': '48',
      }, platform: 'android');
      expect(c.remindAfterHours, 48);
    });

    // Cấu hình hỏng KHÔNG được phép khoá người dùng ra khỏi app của họ.
    test('thiếu khoá thì tắt hẳn, không chặn ai', () {
      final c = AppUpdateConfig.fromFlat(const {}, platform: 'android');
      expect(c.enabled, isFalse);
      expect(_promptFor('android', '1.0.0', values: const {}), isNull);
    });
  });

  group('cấu hình thật, quyết định thật', () {
    // Bản đang phát hành là 2.0.1 — đúng bằng `latest` của Android, nên KHÔNG
    // được nhắc gì. Nhắc người đang ở bản mới nhất là cách nhanh nhất để họ học
    // cách bỏ qua mọi hộp thoại của app.
    test('Android đúng bản mới nhất: không nhắc', () {
      expect(_promptFor('android', '2.0.1'), isNull);
      expect(_promptFor('android', '2.0.1+683'), isNull);
    });

    // `androidIsForceUpdate` đang BẬT, nên ai ở dưới 2.0.1 bị chặn cứng.
    test('Android bản cũ hơn: chặn cứng, không cho bỏ qua', () {
      final p = _promptFor('android', '2.0.0');
      expect(p, isNotNull);
      expect(p!.isForced, isTrue);
      expect(p.storeUrl, contains('com.aktechvn.zenpack'));
      expect(p.title, 'Đã có phiên bản Zenpack mới');
    });

    test('iOS đúng bản mới nhất: không nhắc', () {
      expect(_promptFor('ios', '2.0.0'), isNull);
    });

    // Bản iOS hiện tại (2.0.1) MỚI HƠN `iosLatestVersion` (2.0.0) — chuyện
    // thường khi Android đã lên bản mới còn iOS chờ duyệt. Không được nhắc, và
    // càng không được chặn.
    test('iOS mới hơn cấu hình: không nhắc, không chặn', () {
      expect(_promptFor('ios', '2.0.1'), isNull);
    });

    test('iOS bản cũ hơn: chặn cứng', () {
      final p = _promptFor('ios', '1.9.0');
      expect(p!.isForced, isTrue);
      expect(p.storeUrl, contains('id6794540715'));
    });

    // Tắt công tắc tổng là im hẳn, kể cả khi mọi thứ khác nói phải chặn.
    test('tắt công tắc tổng thì không nhắc dù bản rất cũ', () {
      expect(
        _promptFor(
          'android',
          '1.0.0',
          values: {..._live, 'updatePopupEnabled': false},
        ),
        isNull,
      );
    });

    // Bỏ chặn cứng thì thành lời nhắc mềm, và mốc 24 giờ mới có ý nghĩa.
    test('không chặn cứng: nhắc mềm, im 24 giờ sau khi bỏ qua', () {
      final soft = {
        ..._live,
        'androidIsForceUpdate': false,
        'androidMinSupportedVersion': '1.0.0',
      };
      expect(_promptFor('android', '2.0.0', values: soft)!.isForced, isFalse);

      // Vừa bỏ qua cách đây 1 giờ → im.
      expect(
        _promptFor(
          'android',
          '2.0.0',
          values: soft,
          dismissedAt: DateTime(2026, 8, 17, 11),
          postponed: '2.0.1',
        ),
        isNull,
      );
      // Đã quá 24 giờ → nhắc lại.
      expect(
        _promptFor(
          'android',
          '2.0.0',
          values: soft,
          dismissedAt: DateTime(2026, 8, 16, 11),
          postponed: '2.0.1',
        ),
        isNotNull,
      );
    });
  });
}

/// Cấu hình THẬT đang nằm trên Firebase Remote Config, dạng tham số rời.
///
/// Chép nguyên giá trị của bảng điều khiển vào đây, không rút gọn: ca này tồn
/// tại để bắt đúng lúc ai đó đổi tên một tham số bên Firebase mà quên app, và
/// một bản chép "gần đúng" thì không bắt được gì.
const _live = <String, Object?>{
  'updatePopupEnabled': true,
  'updateRemindAfterHours': 24,
  'androidLatestVersion': '2.0.1',
  'androidMinSupportedVersion': '2.0.1',
  'androidIsForceUpdate': true,
  'androidStoreUrl':
      'https://play.google.com/store/apps/details?id=com.aktechvn.zenpack',
  'androidUpdateTitle': 'Đã có phiên bản Zenpack mới',
  'androidUpdateMessage': 'Cập nhật để có trải nghiệm tốt hơn...',
  'iosLatestVersion': '2.0.0',
  'iosMinSupportedVersion': '2.0.0',
  'iosIsForceUpdate': true,
  'iosStoreUrl': 'https://apps.apple.com/app/id6794540715',
  'iosUpdateTitle': 'Đã có phiên bản Zenpack mới',
  'iosUpdateMessage': 'Cập nhật để có trải nghiệm tốt hơn...',
};

AppUpdatePrompt? _promptFor(
  String platform,
  String version, {
  Map<String, Object?> values = _live,
  DateTime? dismissedAt,
  String? postponed,
}) => checkAppUpdate(
  config: AppUpdateConfig.fromFlat(values, platform: platform),
  currentVersion: version,
  now: DateTime(2026, 8, 17, 12),
  lastDismissedAt: dismissedAt,
  postponedVersion: postponed,
);
