import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Empty imageUrl renders AppNetworkImage's error state synchronously — no
// network fetch, no pending timers — so the widget tests stay hermetic.
Stamp _stamp() => Stamp(
  id: 's1',
  imageUrl: '',
  source: StampSource.created,
  createdAt: DateTime(2026, 7),
);

Widget _host(Widget child) => MaterialApp(theme: AppTheme.light(), home: child);

void main() {
  group('ShareStampScreen (SM-025)', () {
    testWidgets('shows the mandatory watermark and both format options',
        (tester) async {
      await tester.pumpWidget(
        _host(ShareStampScreen(stamp: _stamp(), onShareImage: (_) async {})),
      );

      // BR-06 / AC-03: the StampMail watermark is always present.
      expect(find.text('StampMail'), findsOneWidget);
      // BR-04: both aspect-ratio options are offered.
      expect(find.text('Dọc 9:16'), findsOneWidget);
      expect(find.text('Vuông 1:1'), findsOneWidget);
      expect(find.text('Chia sẻ'), findsOneWidget);
    });

    testWidgets('switching to 1:1 keeps the watermark (AC-03/AC-05)',
        (tester) async {
      await tester.pumpWidget(
        _host(ShareStampScreen(stamp: _stamp(), onShareImage: (_) async {})),
      );

      await tester.tap(find.text('Vuông 1:1'));
      await tester.pump();

      expect(find.text('StampMail'), findsOneWidget);
    });

    testWidgets('tapping share invokes onShareImage with PNG bytes (AC-01)',
        (tester) async {
      Uint8List? shared;
      await tester.pumpWidget(
        _host(
          ShareStampScreen(
            stamp: _stamp(),
            onShareImage: (png) async => shared = png,
          ),
        ),
      );

      // RepaintBoundary.toImage needs the real async + a rendered frame, so
      // drive it inside runAsync.
      await tester.runAsync(() async {
        await tester.tap(find.text('Chia sẻ'));
        await tester.pump();
        // Give the capture + onShareImage a moment to complete.
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });

      expect(shared, isNotNull);
      expect(shared!.isNotEmpty, isTrue);
    });
  });
}
