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
// Gắn tag `golden` — đúng quy ước sẵn có của kho này.
//
// Trước đây tệp này KHÔNG mang tag nào, nên nó không bị `--exclude-tags golden`
// loại ra; nó tự bỏ qua vì một lý do khác hẳn (thiếu biến môi trường
// EC_INTER_TTF). Nay lý do đó đã gỡ, nếu không gắn tag thì 62 ca chạy trong job
// CI trên Ubuntu — mà ảnh gốc sinh trên macOS, tức đỏ vì SAI NỀN TẢNG chứ không
// vì thiết kế trôi. Xem thẻ D-07.
@Tags(['golden'])
library;

import 'dart:async';
import 'dart:io';

import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

import 'inter_font.dart';

const _designSize = Size(390, 844);

/// Khung nào trong file design cao hơn artboard điện thoại thì dựng đúng chiều
/// cao thật của nó. F1-09 là màn cuộn, khung vẽ liền 1037pt; ép xuống 844 thì
/// ảnh tham chiếu chỉ còn vạch tràn vàng-đen đè lên phần cần đối chiếu.
/// Nới ràng buộc cho mọi màn thì không được: chiều cao vô hạn làm vỡ
/// `Expanded`/`Spacer` ở 27 màn còn lại.
/// 1037 → 1120 (17/09): ngày 01/08 thiết kế thêm hàng "Dung lượng/tệp" + dòng
/// ghi chú dưới nó, khung cao thêm ~60pt và tràn khỏi 1037 (ảnh gốc từ đó chỉ
/// còn vạch vàng-đen ở đáy). Đo nội dung thật: dòng cuối ở 1095pt.
const _designHeightOverrides = <String, double>{'f1_09_shop_detail': 1120};

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

void main() {
  setUpAll(() async {
    // Ảnh gốc là ARTBOARD (390×844, pixel-true). App vẽ qua hai núm nén
    // 0,72/0,85 — với golden thiết kế thì phải tắt chúng, nếu không là so
    // thiết kế với một bản đã nén và kết luận nhầm "thiết kế trôi" (D-07).
    PenScale.pixelTrue();
    await napInter();
  });

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
      skip: !coInter,
      experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
      (tester) async {
        final artboard = Size(
          _designSize.width,
          _designHeightOverrides[name] ?? _designSize.height,
        );
        tester.view
          ..physicalSize = artboard
          ..devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // Image fills decode asynchronously; without this the artboard paints
        // its frames before any artwork lands and the golden shows holes.
        await tester.runAsync(_warmDesignArtwork);

        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(size: artboard),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: DefaultTextStyle(
                style: const TextStyle(fontFamily: 'Inter'),
                child: RepaintBoundary(
                  key: const Key('artboard'),
                  child: SizedBox.fromSize(size: artboard, child: screen),
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
