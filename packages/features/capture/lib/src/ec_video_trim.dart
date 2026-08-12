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

/// Một ảnh xem trước kèm mốc thời gian nó được trích ra.
class EcFilmstripFrame {
  const EcFilmstripFrame({required this.at, required this.file});

  final Duration at;
  final File file;
}

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
  /// 24 khung chứ không 10: dải này không chỉ để nhìn cho đẹp, nó còn là thứ
  /// hiện lên ô xem trước trong lúc người dùng kéo — lệnh tua của trình phát
  /// quá chậm để bám theo ngón tay. Càng nhiều khung thì lúc kéo càng sát.
  ///
  /// Hỏng thì trả danh sách rỗng và thanh thời gian rơi về nền trơn — mất một
  /// thứ để nhìn cho dễ, không mất chức năng nào.
  /// [height] là 360 chứ không phải cỡ của dải: cùng bộ ảnh này còn được phóng
  /// lên ô xem trước cỡ gần nửa màn hình trong lúc kéo, và ảnh cao 96 phóng lên
  /// đó thì nhoè tới mức không đọc được dấu giờ nung trên hình. Dải thời gian
  /// tự thu nhỏ khi vẽ nên nó không thiệt gì.
  Future<List<File>> filmstrip({
    required String inputPath,
    required Duration duration,
    int count = 24,
    int height = 360,
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

  /// Trích [count] ảnh rải đều clip, mỗi ảnh một lượt ffmpeg riêng.
  ///
  /// Khác [filmstrip] ở chỗ đọc được cả **URL** chứ không chỉ tệp trên máy:
  /// `-ss` đứng trước `-i` nên ffmpeg nhảy thẳng tới mốc cần bằng một yêu cầu
  /// dải byte, tải vài chục KB quanh mốc đó thay vì kéo cả clip về. Đó là lý do
  /// phải chạy nhiều lượt: một lượt duy nhất với bộ lọc `fps` buộc ffmpeg đọc
  /// tuần tự từ đầu đến cuối, tức tải nguyên tệp.
  ///
  /// Đổi lại là chậm — mỗi mốc một vòng mạng. Dành cho việc chạy ngầm sau khi
  /// màn đã mở, không phải thứ chặn người dùng chờ.
  ///
  /// [onFrame] được gọi sau MỖI ảnh, để màn hình dùng được ảnh đầu tiên ngay
  /// thay vì ngồi đợi đủ bộ. Hỏng một mốc thì bỏ mốc đó và đi tiếp: thiếu vài
  /// ảnh thì dải thưa hơn, còn dừng cả loạt thì mất sạch.
  /// Mỗi ảnh đi kèm MỐC của chính nó chứ không suy ra từ vị trí trong danh
  /// sách: một mốc hỏng là bị bỏ qua, và lúc đó chỉ số thứ i không còn ứng với
  /// khoảng thứ i nữa — dò theo chỉ số sẽ hiện sai khung hình.
  Future<List<EcFilmstripFrame>> sparseFilmstrip({
    required String input,
    required Duration duration,
    int count = 16,
    int height = 360,
    void Function(List<EcFilmstripFrame> frames)? onFrame,
    bool Function()? cancelled,
  }) async {
    if (duration <= Duration.zero || count <= 0) return [];
    final frames = <EcFilmstripFrame>[];
    try {
      await _ensureReady();
      final dir = Directory(await _outputPathFor(''))..createSync();
      for (var i = 0; i < count; i++) {
        if (cancelled?.call() ?? false) break;
        // Lấy mốc GIỮA mỗi khoảng, không lấy mốc đầu: mốc 0 của nhiều clip là
        // một khung đen trước khi cảm biến ổn định.
        final at = duration * ((i + 0.5) / count);
        final path = '${dir.path}/${i.toString().padLeft(3, '0')}.jpg';
        final ok = await _run(
          '-y -ss ${at.inMilliseconds / 1000} -i "$input" '
          '-frames:v 1 -vf "scale=-2:$height" "$path"',
        );
        if (!ok || !File(path).existsSync()) continue;
        frames.add(EcFilmstripFrame(at: at, file: File(path)));
        onFrame?.call(List.unmodifiable(frames));
      }
      return frames;
    } on Object {
      return frames;
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
