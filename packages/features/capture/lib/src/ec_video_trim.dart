/// Cắt đầu/cuối một clip ĐÃ NIÊM PHONG để gửi ra ngoài.
///
/// Bản gốc trên máy chủ không bị đụng tới — đây là thao tác trên một bản đã
/// tải về máy. Đó là cả điểm của cách làm này: bằng chứng gốc vẫn nguyên vẹn,
/// vẫn giữ vân tay và link kiểm chứng, còn thứ người bán gửi cho sàn là một
/// đoạn ngắn cắt ra từ chính bản **đã nung dấu giờ và mã vận đơn lên hình**.
/// Cắt trước khi tải lên thì ngược lại: bằng chứng mất đoạn, và đoạn mất đi ấy
/// không lấy lại được.
///
/// `-c copy`: không mã hoá lại. Nhanh (dưới một giây cho clip vài chục MB),
/// không nóng máy, và quan trọng hơn cả là **từng điểm ảnh giữ nguyên** —
/// đoạn cắt ra vẫn là đúng những khung hình máy chủ đã đóng dấu, chỉ ít khung
/// hơn. Cái giá: chỗ cắt bám vào khung khoá gần nhất nên có thể lệch một hai
/// giây so với chỗ người dùng kéo. Cắt đúng từng khung thì phải mã hoá lại,
/// tức là nén hình một lần nữa — đắt hơn nhiều so với thứ nhận lại được.
library;

// The constructor binds public named params to private fields, which
// prefer_initializing_formals can't express (named params can't be private).
// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_extended_flutter/ffmpeg_kit_extended_flutter.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path_provider/path_provider.dart';

import 'ec_video_faststart.dart' show FfmpegRunner;

/// Tiền tố của mọi tệp do màn cắt sinh ra — bản cắt lẫn ảnh xem trước trên
/// thanh thời gian. Nằm ở thư mục tạm của hệ điều hành nên hệ tự dọn, nhưng
/// tiền tố chung cho phép dọn chủ động khi cần.
const String evidenceTrimPrefix = 'evidence_trim_';

class EcVideoTrimService {
  EcVideoTrimService({
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

  /// Cắt [inputPath] lấy đoạn từ [start] tới [end]. Trả `null` nếu hỏng — bên
  /// gọi giữ nguyên bản đầy đủ chứ không mất gì.
  ///
  /// `-ss` đứng TRƯỚC `-i` để ffmpeg nhảy thẳng tới chỗ cần thay vì đọc từ đầu
  /// tệp, và dùng `-t` (độ dài) thay cho `-to` (mốc kết thúc) vì sau một lần
  /// nhảy như vậy thì mốc thời gian đã được đặt lại về 0.
  Future<String?> trim({
    required String inputPath,
    required Duration start,
    required Duration end,
  }) async {
    if (!File(inputPath).existsSync()) return null;
    final duration = end - start;
    if (duration <= Duration.zero) return null;
    try {
      await _ensureReady();
      final outputPath = await _outputPathFor('.mp4');
      final ok = await _run(
        '-y -ss ${_seconds(start)} -i "$inputPath" -t ${_seconds(duration)} '
        '-c copy -movflags +faststart "$outputPath"',
      );
      if (!ok || !File(outputPath).existsSync()) return null;
      return outputPath;
    } on Object {
      return null;
    }
  }

  /// Dải ảnh nhỏ chạy dọc thanh thời gian — [count] khung hình rải đều.
  ///
  /// Một lần gọi ffmpeg duy nhất cho cả dải: gọi từng khung một là [count] lần
  /// khởi động tiến trình, và trên máy yếu thì màn cắt đứng hình chờ nó.
  ///
  /// Hỏng thì trả danh sách rỗng và thanh thời gian rơi về nền trơn — mất một
  /// thứ để nhìn cho dễ, không mất chức năng nào.
  Future<List<File>> filmstrip({
    required String inputPath,
    required Duration duration,
    int count = 10,
    int height = 96,
  }) async {
    if (!File(inputPath).existsSync() || duration <= Duration.zero) return [];
    try {
      await _ensureReady();
      final dir = Directory(await _outputPathFor(''))..createSync();
      // `fps` nhỏ hơn 1 nghĩa là "mỗi ngần này giây một khung" — rải đều cả
      // clip mà không phải tính từng mốc.
      final fps = count / duration.inMilliseconds * 1000;
      final ok = await _run(
        '-y -i "$inputPath" -vf "fps=$fps,scale=-2:$height" -vsync 0 '
        '-frames:v $count "${dir.path}/%03d.jpg"',
      );
      if (!ok) return [];
      final frames = dir.listSync().whereType<File>().toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      return frames;
    } on Object {
      return [];
    }
  }

  /// Cỡ tệp, tính bằng byte. `null` khi tệp không còn đó.
  static int? sizeOf(String path) {
    try {
      return File(path).lengthSync();
    } on Object {
      return null;
    }
  }

  /// "12,4 MB" — đơn vị người bán đọc được, không phải số byte trần.
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1).replaceAll('.', ',')} MB';
  }

  Future<String> _outputPathFor(String extension) async {
    final dir = _outputDirectory ?? await getTemporaryDirectory();
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return '${dir.path}/$evidenceTrimPrefix$stamp$extension';
  }

  static String _seconds(Duration d) =>
      (d.inMilliseconds / 1000).toStringAsFixed(3);

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
