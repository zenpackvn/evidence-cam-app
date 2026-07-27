/// Widget previews for the EvidenceCam screens.
///
/// Run `fvm flutter widget-preview start` to open a live grid of these; edits
/// hot-reload on save without launching the full app. Camera screens aren't
/// previewed here (they need a real camera).
library;

import 'package:app_ui/app_ui.dart';
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Wraps a screen in the app theme so previews match the real look.
Widget _framed(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  home: child,
);

@Preview(name: 'Splash')
Widget splashPreview() => _framed(const EcSplashScreen());

@Preview(name: 'Vận đơn — search + filter')
Widget homeOrdersPreview() => _framed(
  const EcHomeOrdersScreen(
    shopName: 'Shop',
    queueCount: 4,
    orders: [
      EcOrderRow(
        code: 'TRACKING-001',
        time: '10:23',
        type: 'Đóng hàng đi',
        videoCount: 3,
      ),
      EcOrderRow(
        code: 'TRACKING-002',
        time: '10:55',
        type: 'Trả hàng',
        videoCount: 1,
        errorCount: 1,
      ),
    ],
  ),
);
