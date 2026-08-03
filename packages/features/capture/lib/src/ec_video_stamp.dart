/// Đóng dấu thông tin đơn lên góc trái trên của clip khi xuất ra ngoài app.
///
/// Clip tải về máy hay gửi cho sàn thường rời khỏi mọi ngữ cảnh của app: người
/// nhận chỉ có một file mp4, không biết nó của đơn nào, quay lúc nào, chặng
/// nào. Dấu này gắn ba thông tin đó vào chính khung hình nên không tách rời
/// được — đúng yêu cầu của một bằng chứng.
///
/// Chỉ chạy lúc **xuất**, không đụng bản gốc trong app: bản gốc phải giữ
/// nguyên vẹn cho chuỗi bảo quản chứng cứ (FR-07).
library;

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ffmpeg_kit_extended_flutter/ffmpeg_kit_extended_flutter.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

import 'ec_video_faststart.dart' show FfmpegRunner;

class EcVideoStampService {
  EcVideoStampService({
    @visibleForTesting FfmpegRunner? runner,
    @visibleForTesting Directory? outputDirectory,
  }) : _runner = runner,
       _outputDirectory = outputDirectory;

  final FfmpegRunner? _runner;
  final Directory? _outputDirectory;

  static Future<void>? _ready;

  Future<void> _ensureReady() => _runner != null
      ? Future<void>.value()
      : (_ready ??= FFmpegKitExtended.initialize());

  /// Lề của khối chữ so với mép khung hình, tính bằng pixel.
  ///
  /// Phải là số NGUYÊN: `overlay` của ffmpeg không nhận `24.0`, lệnh hỏng và
  /// hàm fail-safe lặng lẽ trả lại bản chưa đóng dấu — tải về vẫn chạy, chỉ là
  /// không có chữ nào, rất khó lần ra.
  static const _margin = 24;

  /// Trả về đường dẫn bản đã đóng dấu, hoặc [inputPath] nguyên vẹn nếu bất kỳ
  /// bước nào hỏng.
  ///
  /// Fail-safe có chủ đích: người dùng đang muốn cầm được file về tay, một cái
  /// dấu không lên được không đáng để mất luôn bản tải về.
  Future<String> stamp(
    String inputPath, {
    required List<String> lines,
  }) async {
    if (lines.isEmpty || !File(inputPath).existsSync()) return inputPath;
    String? overlayPath;
    try {
      await _ensureReady();
      overlayPath = await _renderOverlay(lines);
      if (overlayPath == null) return inputPath;
      final outputPath = await _outputPathFor();
      // `overlay` là bộ lọc nên hình buộc phải mã hoá lại — không có đường
      // `-c copy` ở đây. Dùng CRF 23/veryfast để đổi một chút dung lượng lấy
      // thời gian chờ, vì người dùng đang đứng nhìn thanh tiến trình.
      //
      // `-an`: clip quay ra vốn không có tiếng (xem `enableAudio: false`), khai
      // báo thẳng để ffmpeg khỏi đi tìm luồng không tồn tại.
      final ok = await _run(
        '-y -i "$inputPath" -i "$overlayPath" '
        '-filter_complex overlay=$_margin:$_margin '
        '-c:v libx264 -preset veryfast -crf 23 -an '
        '-movflags +faststart "$outputPath"',
      );
      if (!ok || !File(outputPath).existsSync()) return inputPath;
      return outputPath;
    } on Object {
      return inputPath;
    } finally {
      if (overlayPath != null) await _deleteQuietly(overlayPath);
    }
  }

  /// Vẽ khối chữ ra PNG trong suốt.
  ///
  /// Vẽ bằng Flutter chứ không dùng `drawtext` của ffmpeg: `drawtext` đòi một
  /// file font nằm sẵn trên đĩa, mà app không đóng gói font nào — còn cách này
  /// dùng luôn bộ chữ hệ thống và hiện được tiếng Việt có dấu.
  Future<String?> _renderOverlay(List<String> lines) async {
    final painters = <TextPainter>[];
    for (final line in lines) {
      painters.add(
        TextPainter(
          text: TextSpan(
            text: line,
            style: const TextStyle(
              fontSize: 34,
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.w700,
              // Nền video là cảnh đóng gói, sáng tối thất thường — viền tối
              // dưới chữ giữ cho nó đọc được trên cả hai.
              shadows: [
                Shadow(color: Color(0xCC000000), blurRadius: 6),
                Shadow(color: Color(0x99000000), offset: Offset(0, 1)),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(),
      );
    }
    const gap = 8.0;
    final width = painters
        .map((p) => p.width)
        .reduce((a, b) => a > b ? a : b);
    final height =
        painters.map((p) => p.height).reduce((a, b) => a + b) +
        gap * (painters.length - 1);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    var dy = 0.0;
    for (final p in painters) {
      p.paint(canvas, Offset(0, dy));
      dy += p.height + gap;
    }
    final image = await recorder.endRecording().toImage(
      width.ceil(),
      height.ceil(),
    );
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return null;
      final dir = _outputDirectory ?? await getTemporaryDirectory();
      final file = File(
        '${dir.path}/stamp_${DateTime.now().microsecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      return file.path;
    } finally {
      image.dispose();
    }
  }

  Future<String> _outputPathFor() async {
    final dir = _outputDirectory ?? await getTemporaryDirectory();
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return '${dir.path}/evidence_stamped_$stamp.mp4';
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      await File(path).delete();
    } on Object {
      // Đã biến mất, hoặc không phải của mình — không có gì để dọn.
    }
  }

  Future<bool> _run(String command) {
    final injected = _runner;
    if (injected != null) return injected(command);
    final completer = Completer<bool>();
    FFmpegKit.executeAsync(
      command,
      onComplete: (session) {
        var success = false;
        try {
          success = ReturnCode.isSuccess(session.getReturnCode());
        } on Object {
          success = false;
        }
        if (!completer.isCompleted) completer.complete(success);
      },
    );
    return completer.future;
  }
}
