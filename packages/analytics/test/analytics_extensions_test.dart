import 'package:analytics/analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

void main() {
  group('AnalyticsService extensions', () {
    late MockAnalyticsService analytics;

    setUp(() {
      analytics = MockAnalyticsService();
      stubAnalyticsService(analytics);
    });

    test('trackClipRecorded logs the video type and duration', () async {
      await analytics.trackClipRecorded(
        videoType: 'dong_hang',
        durationSeconds: 42,
      );

      final captured = verify(
        () => analytics.logEvent(
          AnalyticsEvents.clipRecorded,
          parameters: captureAny(named: 'parameters'),
        ),
      ).captured.single;

      expect(captured, {
        AnalyticsParams.videoType: 'dong_hang',
        AnalyticsParams.durationSeconds: 42,
      });
    });

    test('trackClipRecorded omits duration when it is unknown', () async {
      await analytics.trackClipRecorded(videoType: 'tra_hang');

      final captured = verify(
        () => analytics.logEvent(
          AnalyticsEvents.clipRecorded,
          parameters: captureAny(named: 'parameters'),
        ),
      ).captured.single;

      expect(captured, {AnalyticsParams.videoType: 'tra_hang'});
    });

    test('trackOrdersFiltered logs the chip and the result count', () async {
      await analytics.trackOrdersFiltered(filter: 'hom_nay', resultCount: 12);

      final captured = verify(
        () => analytics.logEvent(
          AnalyticsEvents.ordersFiltered,
          parameters: captureAny(named: 'parameters'),
        ),
      ).captured.single;

      expect(captured, {
        AnalyticsParams.filter: 'hom_nay',
        AnalyticsParams.resultCount: 12,
      });
    });

    test('trackScanFailed logs the error type', () async {
      await analytics.trackScanFailed(errorType: 'khong_doc_duoc');

      final captured = verify(
        () => analytics.logEvent(
          AnalyticsEvents.scanFailed,
          parameters: captureAny(named: 'parameters'),
        ),
      ).captured.single;

      expect(captured, {AnalyticsParams.errorType: 'khong_doc_duoc'});
    });

    test('trackNotificationOpened logs the payload size only', () async {
      await analytics.trackNotificationOpened(payloadKeyCount: 4);

      final captured = verify(
        () => analytics.logEvent(
          AnalyticsEvents.notificationOpened,
          parameters: captureAny(named: 'parameters'),
        ),
      ).captured.single;

      expect(captured, {AnalyticsParams.payloadKeyCount: 4});
    });
  });

  group('naming rules', () {
    // Firebase silently drops an event whose name breaks these rules, so a
    // typo would otherwise only show up as a hole in the reports weeks later.
    final legal = RegExp(r'^[a-z][a-z0-9_]{0,39}$');
    const reservedPrefixes = ['firebase_', 'google_', 'ga_'];

    const events = [
      AnalyticsEvents.loginFailed,
      AnalyticsEvents.signOut,
      AnalyticsEvents.emailVerificationSent,
      AnalyticsEvents.accountDeleted,
      AnalyticsEvents.shopCreated,
      AnalyticsEvents.shopSelected,
      AnalyticsEvents.memberInvited,
      AnalyticsEvents.memberRemoved,
      AnalyticsEvents.scanSucceeded,
      AnalyticsEvents.scanFailed,
      AnalyticsEvents.codeEnteredManually,
      AnalyticsEvents.recordingStarted,
      AnalyticsEvents.clipRecorded,
      AnalyticsEvents.orderCutover,
      AnalyticsEvents.nearClipLimit,
      AnalyticsEvents.videoTypePicked,
      AnalyticsEvents.videoTypeCreated,
      AnalyticsEvents.uploadCompleted,
      AnalyticsEvents.uploadFailed,
      AnalyticsEvents.uploadRetried,
      AnalyticsEvents.orderOpened,
      AnalyticsEvents.videoOpened,
      AnalyticsEvents.videoShared,
      AnalyticsEvents.videoDeleted,
      AnalyticsEvents.ordersFiltered,
      AnalyticsEvents.paywallViewed,
      AnalyticsEvents.purchaseStarted,
      AnalyticsEvents.notificationOpened,
    ];

    const params = [
      AnalyticsParams.errorType,
      AnalyticsParams.source,
      AnalyticsParams.method,
      AnalyticsParams.platform,
      AnalyticsParams.videoType,
      AnalyticsParams.planCode,
      AnalyticsParams.durationSeconds,
      AnalyticsParams.filter,
      AnalyticsParams.resultCount,
      AnalyticsParams.attempt,
      AnalyticsParams.payloadKeyCount,
    ];

    for (final (label, names) in [
      ('event', events),
      ('param', params),
      ('screen', EcScreens.byRoute.values),
    ]) {
      test('every $label name is legal for Firebase', () {
        for (final name in names) {
          expect(legal.hasMatch(name), isTrue, reason: name);
          for (final prefix in reservedPrefixes) {
            expect(name.startsWith(prefix), isFalse, reason: name);
          }
        }
      });

      test('no two ${label}s share a name', () {
        expect(names.toSet().length, names.length);
      });
    }

    test('every screen name is prefixed man_', () {
      for (final name in EcScreens.byRoute.values) {
        expect(name, startsWith('man_'));
      }
    });

    test('an unmapped route reports nothing', () {
      expect(EcScreens.of('/khong-co-trong-bang'), isNull);
      expect(EcScreens.of(null), isNull);
      expect(EcScreens.of('/record'), 'man_ghi_hinh');
    });
  });
}
