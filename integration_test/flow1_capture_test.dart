// Design-fidelity capture for Flow 1 (Khởi đầu). Renders every Flow-1 gallery
// entry at the design frame size (940×1672 @2x, matching flow1/*.png) on the
// real engine (`-d macos` → real Google Fonts + assets) and writes each to
// build/flow1-shots/, so the actual UI can be diffed against the design export.
//
//   fvm flutter test integration_test/flow1_capture_test.dart -d macos
//
// Output PNGs land in build/flow1-shots/ (gitignored). Not a behaviour test —
// it asserts only that each frame captured.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_starter_template/preview/preview_fakes.dart';
import 'package:flutter_starter_template/preview/preview_gallery.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:shared_ui/shared_ui.dart';

// Design frames in pencil-new.pen are 393×852 (iPhone logical). Capture at
// that logical size; DPR 3 → 1179×2556 crisp output.
const _logical = Size(393, 852);
const _dpr = 3.0;
const _outDir =
    '/private/tmp/claude-501/-Users-sontruong-workspace-aktech-stampmail/af9e1a47-c54f-4de5-ab5b-955fe52eaf41/scratchpad/flow1-shots';

void main() {
  late AuthBloc authBloc;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = true; // real fonts on -d macos
    registerPreviewFakes();
    authBloc = buildPreviewAuthBloc();
    Directory(_outDir).createSync(recursive: true);
  });

  testWidgets('capture Flow 1 frames', (tester) async {
    tester.view
      ..physicalSize = _logical * _dpr
      ..devicePixelRatio = _dpr;
    addTearDown(tester.view.reset);

    // Optional filter: --dart-define=ONLY=F01-S01 captures just that entry.
    const only = String.fromEnvironment('ONLY');
    // Which gallery section (flow) to capture: --dart-define=FLOW=1 → Flow 2.
    const flowIndex = int.fromEnvironment('FLOW');

    final flow = buildGallerySections()[flowIndex];
    // ignore: avoid_print
    print('SECTION $flowIndex · ${flow.title}');
    for (final (i, entry) in flow.entries.indexed) {
      if (only.isNotEmpty && !entry.code.contains(only)) continue;
      if (entry.build == null) continue; // missing/placeholder entries
      // Reset switches, then apply this entry's overrides (mirrors the gallery).
      previewSwitches
        ..emptyStamps = false
        ..emptyLetters = false
        ..quotaReached = false
        ..loginFails = false
        ..loginLocked = false;
      entry.prepare?.call(previewSwitches);

      final key = GlobalKey();
      await tester.pumpWidget(
        _App(authBloc: authBloc, boundaryKey: key, child: entry.build!),
      );

      // Let Google Fonts fetch, assets decode, and fake latency resolve.
      // Bounded pumping (not pumpAndSettle — loading spinners never settle).
      for (var t = 0; t < 8; t++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 350)),
        );
        await tester.pump(const Duration(milliseconds: 350));
      }

      final slug = entry.code.replaceAll(RegExp('[^A-Za-z0-9]+'), '-');
      final name = '${(i + 1).toString().padLeft(2, '0')}_$slug';
      await _capture(key, name);
      // ignore: avoid_print
      print('CAPTURED $name  ←  ${entry.code} · ${entry.title}');
    }
  });
}

Future<void> _capture(GlobalKey key, String name) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: _dpr);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = data!.buffer.asUint8List();
  File('$_outDir/$name.png').writeAsBytesSync(bytes);
}

class _App extends StatelessWidget {
  const _App({
    required this.authBloc,
    required this.boundaryKey,
    required this.child,
  });

  final AuthBloc authBloc;
  final GlobalKey boundaryKey;
  final WidgetBuilder child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authBloc,
      child: SessionScope(
        session: FakeSession(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('vi'), Locale('en')],
          locale: const Locale('vi'),
          home: RepaintBoundary(key: boundaryKey, child: Builder(builder: child)),
        ),
      ),
    );
  }
}
