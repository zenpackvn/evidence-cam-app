/// Browser preview of every screen transcribed from the Pencil design file.
///
/// The full app cannot build for web: ObjectBox reaches `dart:ffi`, and the
/// camera / MLKit / video-thumbnail plugins have no web implementation. The
/// `ec_ui` design system has none of those dependencies, so this entry point
/// renders the generated screens on their own — enough to eyeball type scale
/// and density in a browser.
///
///     fvm flutter run -d chrome -t lib/main_web_preview.dart
library;

import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The design file's artboard. F1-09 is a scrolling screen drawn full-height,
/// so it gets its real height instead of being crushed into 844.
const _artboard = Size(390, 844);
const _heightOverrides = <String, double>{'f1_09_shop_detail': 1037};

const _screens = <String, Widget>{
  'f1_01_splash': PenF101(),
  'f1_02_login': PenF102(),
  'f1_03_register': PenF103(),
  'f1_04_forgot': PenF104(),
  'f1_05_choose_shop': PenF105(),
  'f1_06_no_shop': PenF106(),
  'f1_07_create_shop': PenF107(),
  'f1_08_shop_mgmt': PenF108(),
  'f1_09_shop_detail': PenF109(),
  'f1_10_create_type': PenF110(),
  'f1_11_delete_type': PenF111(),
  'f1_12_orders_tab': PenF112(),
  'f2_01_orders': PenF201(),
  'f2_02_evidence': PenF202(),
  'f2_03_video_detail': PenF203(),
  'f3_01_idle': PenF301(),
  'f3_02_code': PenF302(),
  'f3_03_rec': PenF303(),
  'f3_04_saved': PenF304(),
  'f3_05_ceiling': PenF305(),
  'f3_06_queue': PenF306(),
  'f3_07_return': PenF307(),
  'f3_08_mismatch': PenF308(),
  'f3_09_pick_type': PenF309(),
  'f3_10_new_type': PenF310(),
  'f4_01_account': PenF401(),
  'f4_02_profile': PenF402(),
  'f4_03_language': PenF403(),
  'f4_04_quota': PenF404(),
  'f4_05_password': PenF405(),
  'f4_06_delete': PenF406(),
};

void main() => runApp(const _PreviewApp());

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EvidenceCam — design preview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.interTextTheme()),
      home: const _PreviewGrid(),
    );
  }
}

class _PreviewGrid extends StatelessWidget {
  const _PreviewGrid();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE9E9EC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            for (final entry in _screens.entries)
              _Artboard(name: entry.key, child: entry.value),
          ],
        ),
      ),
    );
  }
}

class _Artboard extends StatelessWidget {
  const _Artboard({required this.name, required this.child});

  final String name;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            name,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B6B70)),
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            boxShadow: [
              BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: SizedBox(
            width: _artboard.width,
            height: _heightOverrides[name] ?? _artboard.height,
            child: child,
          ),
        ),
      ],
    );
  }
}
