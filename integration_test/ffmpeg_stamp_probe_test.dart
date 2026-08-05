/// Chạy trên MÁY THẬT để trả lời một câu duy nhất: bản ffmpeg nhúng trong app
/// làm được những gì.
///
/// Cần có vì bản ffmpeg trên máy dev (Homebrew, đầy đủ) khác hẳn bản nhúng
/// trong app (`type: "base"`, `gpl: false`) — mọi lệnh thử ở máy dev đều chạy
/// được trong khi máy thật thì không, và `EcVideoStampService` lại fail-safe
/// nên hỏng chỉ hiện ra thành "clip tải về mất chữ".
///
/// ```bash
/// fvm flutter test integration_test/ffmpeg_stamp_probe_test.dart -d <device>
/// ```
library;

import 'dart:async';
import 'dart:io';

import 'package:feature_capture/feature_capture.dart';
import 'package:ffmpeg_kit_extended_flutter/ffmpeg_kit_extended_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

/// Chạy một lệnh ffmpeg, trả về (thành công, log).
Future<(bool, String)> run(String command) {
  final completer = Completer<(bool, String)>();
  unawaited(
    FFmpegKit.executeAsync(
      command,
      onComplete: (session) {
        var ok = false;
        var output = '';
        try {
          ok = ReturnCode.isSuccess(session.getReturnCode());
        } on Object {
          ok = false;
        }
        try {
          output = session.getOutput() ?? '';
        } on Object {
          output = '(không đọc được log)';
        }
        if (!completer.isCompleted) completer.complete((ok, output));
      },
    ),
  );
  return completer.future;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ffmpeg trong app: chạy được không, có bộ mã hoá nào', (
    tester,
  ) async {
    await FFmpegKitExtended.initialize();

    final (versionOk, version) = await run('-hide_banner -version');
    print('=== ffmpeg -version (ok=$versionOk) ===');
    print(version.split('\n').take(3).join('\n'));

    final (_, encoders) = await run('-hide_banner -encoders');
    final relevant = encoders
        .split('\n')
        .where(
          (l) =>
              l.contains('264') || l.contains('mpeg4') || l.contains('toolbox'),
        )
        .join('\n');
    print('=== bộ mã hoá liên quan ===');
    print(relevant.isEmpty ? '(KHÔNG CÓ CÁI NÀO)' : relevant);

    expect(
      versionOk,
      isTrue,
      reason: 'ffmpeg trong app không chạy nổi -version',
    );
  });

  testWidgets('đóng dấu thật lên một clip thật', (tester) async {
    await FFmpegKitExtended.initialize();
    final dir = await getTemporaryDirectory();
    final source = '${dir.path}/probe_src.mp4';

    // Tự dựng clip nguồn bằng chính ffmpeg của app — không cần asset đi kèm, và
    // nếu bước này hỏng thì đã biết ngay là hỏng ở khâu mã hoá chứ không phải
    // khâu đóng dấu.
    final (madeSource, sourceLog) = await run(
      '-y -f lavfi -i testsrc2=s=640x360:r=30:d=3 '
      '-c:v h264_videotoolbox -b:v 2M -allow_sw 1 -an "$source"',
    );
    print('=== dựng clip nguồn (ok=$madeSource) ===');
    if (!madeSource) {
      print(
        sourceLog.length > 3000
            ? sourceLog.substring(sourceLog.length - 3000)
            : sourceLog,
      );
    }
    expect(madeSource, isTrue, reason: 'không mã hoá nổi clip thử');

    final before = File(source).lengthSync();
    final stamped = await EcVideoStampService().stamp(
      source,
      lines: ['05/08/2026', '09:30:00', 'SPXVN0123456789'],
      clockStart: DateTime(2026, 8, 5, 9, 30),
      clockSeconds: 3,
    );
    print('=== kết quả đóng dấu ===');
    print('vào : $source ($before bytes)');
    print(
      'ra  : $stamped '
      '(${File(stamped).existsSync() ? File(stamped).lengthSync() : 0} bytes)',
    );

    expect(
      stamped,
      isNot(source),
      reason:
          'stamp trả lại bản gốc — dấu KHÔNG lên (xem log evidencecam.stamp)',
    );
  });
}
