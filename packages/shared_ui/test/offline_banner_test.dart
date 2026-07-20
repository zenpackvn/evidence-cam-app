import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_ui/shared_ui.dart';

const _label = 'Đang xem ngoại tuyến';

// AppTheme.light() registers the SemanticColors extension the banner reads.
Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('OfflineBanner', () {
    testWidgets('renders nothing while online', (tester) async {
      await _pump(tester, const OfflineBanner(isOffline: false, label: _label));

      expect(find.text(_label), findsNothing);
      expect(tester.getSize(find.byType(OfflineBanner)), Size.zero);
    });

    testWidgets('shows the offline notice when offline', (tester) async {
      await _pump(tester, const OfflineBanner(isOffline: true, label: _label));

      expect(find.text(_label), findsOneWidget);
    });

    testWidgets('sits in the layout flow above the content it annotates '
        '(SM-004 BR-07)', (tester) async {
      await _pump(
        tester,
        const Column(
          children: [
            OfflineBanner(isOffline: true, label: _label),
            Text('Nội dung chính'),
          ],
        ),
      );

      // Both are laid out; the banner takes vertical space rather than
      // overlaying the content below it.
      final banner = tester.getRect(find.byType(OfflineBanner));
      final content = tester.getRect(find.text('Nội dung chính'));
      expect(banner.height, greaterThan(0));
      expect(banner.bottom, lessThanOrEqualTo(content.top));
    });

    testWidgets('takes its copy from the label parameter', (tester) async {
      await _pump(
        tester,
        const OfflineBanner(isOffline: true, label: 'Mất kết nối'),
      );

      expect(find.text('Mất kết nối'), findsOneWidget);
      expect(find.text(_label), findsNothing);
    });
  });
}
