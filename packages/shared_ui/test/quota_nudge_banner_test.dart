import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:shared_ui/shared_ui.dart';

QuotaNudgeLabels _labels({String? upgradeCta, String? lastSyncedLabel}) =>
    QuotaNudgeLabels(
      stampRemaining: (n) => 'Còn $n tem trong tháng này',
      letterRemaining: (n) => 'Còn $n thư trong tháng này',
      offlineMessage: 'Không có kết nối. Vui lòng thử lại khi có mạng.',
      lastSyncedLabel: lastSyncedLabel,
      upgradeCta: upgradeCta,
    );

// AppTheme.light() registers the SemanticColors extension the banner reads.
Future<void> _pump(
  WidgetTester tester,
  Widget child,
) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('QuotaNudgeBanner', () {
    testWidgets('is hidden when both resources have headroom', (tester) async {
      await _pump(
        tester,
        QuotaNudgeBanner(
          quota: const QuotaRemaining(stamps: 30, letters: 10),
          labels: _labels(),
        ),
      );
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('is hidden for unlimited (Premium) quota', (tester) async {
      await _pump(
        tester,
        QuotaNudgeBanner(
          quota: QuotaRemaining.unlimited,
          labels: _labels(),
        ),
      );
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('warns when letters drop under the threshold (AC-01)', (
      tester,
    ) async {
      await _pump(
        tester,
        QuotaNudgeBanner(
          quota: const QuotaRemaining(stamps: 30, letters: 1),
          labels: _labels(),
        ),
      );
      expect(find.text('Còn 1 thư trong tháng này'), findsOneWidget);
      // Stamps still have headroom, so no stamp line.
      expect(find.textContaining('tem trong tháng này'), findsNothing);
    });

    testWidgets('warns when stamps drop under the threshold', (tester) async {
      await _pump(
        tester,
        QuotaNudgeBanner(
          quota: const QuotaRemaining(stamps: 5, letters: 10),
          labels: _labels(),
        ),
      );
      expect(find.text('Còn 5 tem trong tháng này'), findsOneWidget);
      expect(find.textContaining('thư trong tháng này'), findsNothing);
    });

    testWidgets('shows both lines when both resources are low', (tester) async {
      await _pump(
        tester,
        QuotaNudgeBanner(
          quota: const QuotaRemaining(stamps: 5, letters: 1),
          labels: _labels(),
        ),
      );
      expect(find.text('Còn 5 tem trong tháng này'), findsOneWidget);
      expect(find.text('Còn 1 thư trong tháng này'), findsOneWidget);
    });

    testWidgets('appends the offline note and cached counts when offline '
        '(AC-06/AC-07)', (tester) async {
      await _pump(
        tester,
        QuotaNudgeBanner(
          quota: const QuotaRemaining(stamps: 5, letters: 1),
          labels: _labels(lastSyncedLabel: 'Đồng bộ lần cuối hôm nay'),
          isOffline: true,
        ),
      );
      // Cached counts still visible (BR-06 — no blank).
      expect(find.text('Còn 5 tem trong tháng này'), findsOneWidget);
      expect(find.text('Còn 1 thư trong tháng này'), findsOneWidget);
      // Offline note + last-synced caption.
      expect(
        find.text('Không có kết nối. Vui lòng thử lại khi có mạng.'),
        findsOneWidget,
      );
      expect(find.text('Đồng bộ lần cuối hôm nay'), findsOneWidget);
    });

    testWidgets('does not show the offline note when online', (tester) async {
      await _pump(
        tester,
        QuotaNudgeBanner(
          quota: const QuotaRemaining(stamps: 5, letters: 10),
          labels: _labels(),
        ),
      );
      expect(
        find.text('Không có kết nối. Vui lòng thử lại khi có mạng.'),
        findsNothing,
      );
    });

    testWidgets('renders the upgrade CTA and fires onUpgrade on tap', (
      tester,
    ) async {
      var tapped = false;
      await _pump(
        tester,
        QuotaNudgeBanner(
          quota: const QuotaRemaining(stamps: 5, letters: 10),
          labels: _labels(upgradeCta: 'Nâng cấp Premium'),
          onUpgrade: () => tapped = true,
        ),
      );
      final cta = find.text('Nâng cấp Premium');
      expect(cta, findsOneWidget);
      await tester.tap(cta);
      expect(tapped, isTrue);
    });

    testWidgets('omits the upgrade CTA when no label is supplied', (
      tester,
    ) async {
      await _pump(
        tester,
        QuotaNudgeBanner(
          quota: const QuotaRemaining(stamps: 5, letters: 10),
          labels: _labels(),
        ),
      );
      expect(find.text('Nâng cấp Premium'), findsNothing);
    });
  });
}
