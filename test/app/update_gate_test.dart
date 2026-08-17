import 'package:config/config.dart';
import 'package:evidence_cam/app/di/injection.dart';
import 'package:evidence_cam/app/update_gate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Serves a canned payload; the fetch is already done so the gate never waits.
class _FakeRemoteConfig implements RemoteConfigService {
  _FakeRemoteConfig(this._payload);

  final String _payload;

  @override
  Future<void> init() async {}

  @override
  Future<void> get fetched async {}

  @override
  String getString(String key) => key == appUpdateBlobKey ? _payload : '';

  @override
  bool getBool(String key) => false;

  @override
  int getInt(String key) => 0;

  @override
  double getDouble(String key) => 0;

  @override
  bool isEnabled(FeatureFlag flag) => flag.defaultValue;
}

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'ZenPack',
      packageName: 'vn.aktech.zenpack',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  tearDown(getIt.reset);

  Future<void> pumpGate(WidgetTester tester, String payload) async {
    getIt.registerSingleton<RemoteConfigService>(_FakeRemoteConfig(payload));
    await tester.pumpWidget(
      const CupertinoApp(
        locale: Locale('vi'),
        supportedLocales: [Locale('vi'), Locale('en')],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: UpdateGate(child: Text('app')),
      ),
    );
    await tester.pumpAndSettle();
  }

  String payload({required bool force}) =>
      '{"updatePopupEnabled": true, '
      '"androidLatestVersion": "2.0.0", "androidIsForceUpdate": $force, '
      '"androidStoreUrl": "https://example.com", '
      '"androidUpdateMessage": "Có bản mới", '
      '"iosLatestVersion": "2.0.0", "iosIsForceUpdate": $force, '
      '"iosStoreUrl": "https://example.com", '
      '"iosUpdateMessage": "Có bản mới"}';

  testWidgets('renders the prompt over the app once config asks for it', (
    tester,
  ) async {
    await pumpGate(tester, payload(force: false));

    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.text('Có bản mới'), findsOneWidget);
    // Falls back to the localized title, since the payload supplies none.
    expect(find.text('Đã có phiên bản mới'), findsOneWidget);
    expect(find.text('Để sau'), findsOneWidget);
  });

  testWidgets('a forced prompt offers no way out but the store', (
    tester,
  ) async {
    await pumpGate(tester, payload(force: true));

    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.text('Để sau'), findsNothing);
    expect(find.text('Cập nhật'), findsOneWidget);
  });

  testWidgets('dismissing a soft prompt returns to the app', (tester) async {
    await pumpGate(tester, payload(force: false));

    await tester.tap(find.text('Để sau'));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoAlertDialog), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('stays out of the way when no update is configured', (
    tester,
  ) async {
    await pumpGate(tester, '');

    expect(find.byType(CupertinoAlertDialog), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });
}
