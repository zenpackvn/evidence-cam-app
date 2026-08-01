import 'package:analytics/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

void main() {
  group('AnalyticsRouteObserver', () {
    late MockAnalyticsService analytics;
    late AnalyticsRouteObserver observer;

    setUp(() {
      analytics = MockAnalyticsService();
      stubAnalyticsService(analytics);
      observer = AnalyticsRouteObserver(analytics);
    });

    test('reports a route path under its Vietnamese screen name', () {
      final route = MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/home'),
        builder: (_) => const SizedBox.shrink(),
      );

      observer.didPush(route, null);

      verify(
        () => analytics.logScreenView(screenName: 'man_van_don'),
      ).called(1);
    });

    test('ignores unnamed page routes', () {
      final route = MaterialPageRoute<void>(
        builder: (_) => const SizedBox.shrink(),
      );

      observer.didPush(route, null);

      verifyNever(
        () => analytics.logScreenView(screenName: any(named: 'screenName')),
      );
    });

    test('never reports a raw path for a route outside the table', () {
      final route = MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/mot-man-chua-dat-ten'),
        builder: (_) => const SizedBox.shrink(),
      );

      observer.didPush(route, null);

      verifyNever(
        () => analytics.logScreenView(screenName: any(named: 'screenName')),
      );
    });
  });
}
