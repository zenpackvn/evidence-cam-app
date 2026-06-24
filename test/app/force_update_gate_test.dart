import 'package:config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_template/app/widgets/force_update_gate.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal in-memory config: only the min-version string matters here.
class _FakeRemoteConfig implements RemoteConfigService {
  _FakeRemoteConfig(this._minVersion);
  final String _minVersion;

  @override
  String getString(String key) =>
      key == minSupportedVersionKey ? _minVersion : '';

  @override
  Future<void> init() async {}
  @override
  bool getBool(String key) => false;
  @override
  int getInt(String key) => 0;
  @override
  double getDouble(String key) => 0;
  @override
  bool isEnabled(FeatureFlag flag) => flag.defaultValue;
}

Future<void> _pump(WidgetTester tester, {required String min, required String current}) {
  return tester.pumpWidget(
    MaterialApp(
      home: ForceUpdateGate(
        remoteConfig: _FakeRemoteConfig(min),
        currentVersionOverride: current,
        child: const Scaffold(body: Text('app content')),
      ),
    ),
  );
}

void main() {
  group('compareVersions', () {
    test('orders by numeric segments', () {
      expect(compareVersions('1.7.0', '1.8.0') < 0, isTrue);
      expect(compareVersions('2.0.0', '1.9.9') > 0, isTrue);
      expect(compareVersions('1.7.0', '1.7.0'), 0);
    });

    test('treats missing trailing segments as zero', () {
      expect(compareVersions('1.7', '1.7.0'), 0);
      expect(compareVersions('1.7.1', '1.7') > 0, isTrue);
    });

    test('ignores build and pre-release suffixes', () {
      expect(compareVersions('1.7.0+42', '1.7.0'), 0);
      expect(compareVersions('1.7.0-beta', '1.7.0'), 0);
    });
  });

  group('ForceUpdateGate', () {
    testWidgets('blocks when current version is below the minimum', (tester) async {
      await _pump(tester, min: '2.0.0', current: '1.7.0');
      await tester.pumpAndSettle();

      expect(find.text('Update required'), findsOneWidget);
    });

    testWidgets('stays out of the way when up to date', (tester) async {
      await _pump(tester, min: '1.7.0', current: '1.7.0');
      await tester.pumpAndSettle();

      expect(find.text('Update required'), findsNothing);
      expect(find.text('app content'), findsOneWidget);
    });

    testWidgets('does nothing when no minimum is configured', (tester) async {
      await _pump(tester, min: '', current: '0.0.1');
      await tester.pumpAndSettle();

      expect(find.text('Update required'), findsNothing);
    });
  });
}
