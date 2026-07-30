/// Renders every screen generated from the Pencil design file at the design's
/// own artboard size (390x844) so the port can be compared against the design.
///
/// Goldens are the verification artefact for "matches the design file"; run
/// `fvm flutter test test/design --update-goldens` after re-running
/// `tool/pen2dart.py` and diff the images.
///
/// Inter is not bundled in the app (it comes from `google_fonts` at runtime),
/// so the test loads a local copy when `EC_INTER_TTF` points at one. Without
/// it the goldens render in the test fallback face and only geometry — not
/// glyphs — is meaningful.
library;

import 'dart:async';
import 'dart:io';

import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

const _designSize = Size(390, 844);

/// Decodes every artwork the design file uses so the first paint has it.
Future<void> _warmDesignArtwork() async {
  final dir = Directory('packages/ec_ui/assets/design');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.png'));
  for (final file in files) {
    final done = Completer<void>();
    final stream = AssetImage(
      file.path.replaceFirst('packages/ec_ui/', ''),
      package: 'ec_ui',
    ).resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;
    void finish() {
      stream.removeListener(listener);
      if (!done.isCompleted) done.complete();
    }

    listener = ImageStreamListener(
      (_, _) => finish(),
      onError: (_, _) => finish(),
    );
    stream.addListener(listener);
    await done.future;
  }
}

Future<void> _loadInter() async {
  final path = Platform.environment['EC_INTER_TTF'];
  if (path == null || !File(path).existsSync()) return;
  final bytes = File(path).readAsBytesSync().buffer.asByteData();
  await (FontLoader('Inter')..addFont(Future.value(bytes))).load();
}

/// Goldens are pixel comparisons against a specific typeface, so they only
/// mean anything when the real Inter is loaded. Without `EC_INTER_TTF` the run
/// would diff design pixels against the test fallback font, so skip instead.
final _hasInter = () {
  final path = Platform.environment['EC_INTER_TTF'];
  return path != null && File(path).existsSync();
}();

void main() {
  setUpAll(_loadInter);

  final screens = <String, Widget>{
    'f1_01_splash': const PenF101(),
    'f1_02_login': const PenF102(),
    'f1_03_register': const PenF103(),
    'f1_04_forgot': const PenF104(),
    'f1_05_choose_shop': const PenF105(),
    'f1_06_no_shop': const PenF106(),
    'f1_07_create_shop': const PenF107(),
    'f1_08_shop_mgmt': const PenF108(),
    'f1_09_shop_detail': const PenF109(),
    'f1_10_create_type': const PenF110(),
    'f1_11_delete_type': const PenF111(),
    'f1_12_orders_tab': const PenF112(),
    'f2_01_orders': const PenF201(),
    'f2_02_evidence': const PenF202(),
    'f2_03_video_detail': const PenF203(),
    'f3_01_idle': const PenF301(),
    'f3_02_code': const PenF302(),
    'f3_03_rec': const PenF303(),
    'f3_04_saved': const PenF304(),
    'f3_05_ceiling': const PenF305(),
    'f3_06_queue': const PenF306(),
    'f3_07_return': const PenF307(),
    'f3_08_mismatch': const PenF308(),
    'f3_09_pick_type': const PenF309(),
    'f3_10_new_type': const PenF310(),
    'f4_01_account': const PenF401(),
    'f4_02_profile': const PenF402(),
    'f4_03_language': const PenF403(),
    'f4_04_quota': const PenF404(),
    'f4_05_password': const PenF405(),
    'f4_06_delete': const PenF406(),
  };

  screens.forEach((name, screen) {
    testWidgets(
      'design $name',
      // Decoded artwork is cached by the image cache for the whole run, which
      // the leak tracker reads as a leak; these tests only render.
      skip: !_hasInter,
      experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
      (tester) async {
        tester.view
          ..physicalSize = _designSize
          ..devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // Image fills decode asynchronously; without this the artboard paints
        // its frames before any artwork lands and the golden shows holes.
        await tester.runAsync(_warmDesignArtwork);

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: _designSize),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: DefaultTextStyle(
                style: const TextStyle(fontFamily: 'Inter'),
                child: RepaintBoundary(
                  key: const Key('artboard'),
                  child: SizedBox.fromSize(size: _designSize, child: screen),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byKey(const Key('artboard')),
          matchesGoldenFile('goldens/$name.png'),
        );
      },
    );
  });
}
