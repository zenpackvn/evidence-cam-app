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
import 'dart:developer' as developer;
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

  /// Bộ mã hoá thử theo thứ tự cho tới khi có cái chạy được.
  ///
  /// KHÔNG được dùng `libx264` làm lựa chọn đầu: app đóng gói ffmpeg bản
  /// `base` + `gpl: false` (xem `ffmpeg_kit_extended_config` trong
  /// `pubspec.yaml`), mà x264 là thư viện GPL chỉ có ở bản `video`/`full`.
  /// Gọi nó trên máy thật là `Unknown encoder 'libx264'`, và vì [stamp]
  /// fail-safe nên hỏng đó chỉ hiện ra thành "clip tải về mất chữ".
  ///
  /// Bộ mã hoá phần cứng của hệ điều hành thì có sẵn ngay trong bản `base`,
  /// không ràng buộc GPL, không làm phình app, và nhanh hơn hẳn trên điện
  /// thoại. Chúng không nhận `-crf` nên phải khai bitrate; 4 Mbps đủ cho mức
  /// 720p mà màn ghi hình quay ra.
  ///
  /// Hai lựa chọn cuối là lưới an toàn: `libx264` cho ngày ai đó nâng bundle
  /// lên, còn `mpeg4` là bộ mã hoá nội tại của ffmpeg, luôn có mặt.
  static List<_Encoder> get _encoders => [
    if (Platform.isAndroid) const _Encoder('h264_mediacodec', '-b:v 4M'),
    if (Platform.isIOS || Platform.isMacOS)
      // `-allow_sw 1`: máy ảo và vài đời máy không cho encode phần cứng, cứ
      // để VideoToolbox tự lùi về đường phần mềm còn hơn hỏng cả lượt.
      const _Encoder('h264_videotoolbox', '-b:v 4M -allow_sw 1'),
    const _Encoder('libx264', '-preset veryfast -crf 23'),
    const _Encoder('mpeg4', '-q:v 4'),
  ];

  /// Cạnh tối đa của ảnh dấu, pixel.
  ///
  /// Ảnh dấu là một texture GPU; vượt giới hạn phần cứng là `toImage` ném hoặc
  /// trả về ảnh rỗng. 8192 là mức mọi thiết bị chạy được app này đều chịu
  /// được. Clip dài quá mức lát được ô sẽ rơi về dấu tĩnh thay vì hỏng hẳn.
  static const _maxSpriteEdge = 8192;

  /// Trả về đường dẫn bản đã đóng dấu, hoặc [inputPath] nguyên vẹn nếu bất kỳ
  /// bước nào hỏng.
  ///
  /// [lines] là khối chữ tĩnh. Truyền thêm [clockStart] và [clockSeconds] thì
  /// dòng ở vị trí [clockLine] chạy theo từng giây của clip, đúng như đồng hồ
  /// người quay nhìn thấy lúc quay và người xem lại thấy lúc phát.
  ///
  /// Fail-safe có chủ đích: người dùng đang muốn cầm được file về tay, một cái
  /// dấu không lên được không đáng để mất luôn bản tải về.
  Future<String> stamp(
    String inputPath, {
    required List<String> lines,
    DateTime? clockStart,
    int? clockSeconds,
    int clockLine = 1,
  }) async {
    if (lines.isEmpty || !File(inputPath).existsSync()) {
      _log('bỏ qua: không có chữ để đóng, hoặc không thấy file "$inputPath"');
      return inputPath;
    }
    final frames = _clockFrames(
      lines,
      clockStart,
      clockSeconds,
      clockLine,
    );
    String? spritePath;
    String? graphPath;
    // Bản dở dang của một lượt encode hỏng: phải dọn, không thì nó nằm lại
    // trong thư mục tạm với kích thước bằng cả clip mà không ai biết để xoá.
    String? partialPath;
    try {
      await _ensureReady();
      final sprite = await _renderSprite(frames);
      if (sprite == null) {
        _log('hỏng ở bước vẽ ảnh dấu (${frames.length} ô) — trả lại bản gốc');
        return inputPath;
      }
      spritePath = sprite.path;
      final outputPath = await _outputPathFor();
      partialPath = outputPath;
      graphPath = await _writeGraph(sprite);
      // `overlay` là bộ lọc nên hình buộc phải mã hoá lại — không có đường
      // `-c copy` ở đây.
      //
      // `-an`: clip quay ra vốn không có tiếng (xem `enableAudio: false`), khai
      // báo thẳng để ffmpeg khỏi đi tìm luồng không tồn tại.
      //
      // `-loop 1` cho ảnh dấu: `crop` chỉ đổi ô theo `t` khi đầu vào là một
      // luồng có nhiều khung, ảnh tĩnh một khung thì đồng hồ đứng im.
      var ok = false;
      for (final encoder in _encoders) {
        ok = await _run(
          '-y -i "$inputPath" -loop 1 -i "$spritePath" '
          '-filter_complex_script "$graphPath" -map [out] '
          '-c:v ${encoder.name} ${encoder.quality} -an '
          '-movflags +faststart "$outputPath"',
        );
        if (ok && File(outputPath).existsSync()) break;
        ok = false;
      }
      if (!ok) {
        _log('không bộ mã hoá nào chạy được — trả lại bản gốc');
        await _logAvailableEncoders();
        return inputPath;
      }
      partialPath = null;
      return outputPath;
    } on Object catch (e, s) {
      _log('hỏng khi đóng dấu — trả lại bản gốc', e, s);
      return inputPath;
    } finally {
      if (spritePath != null) await _deleteQuietly(spritePath);
      if (graphPath != null) await _deleteQuietly(graphPath);
      if (partialPath != null) await _deleteQuietly(partialPath);
    }
  }

  /// Khối chữ cho từng giây của clip; một phần tử nghĩa là dấu đứng im.
  ///
  /// Ngày được tính lại ở mỗi giây chứ không chép từ [lines]: ca đóng hàng đêm
  /// có clip vắt qua nửa đêm, lúc đó ngày phải nhảy theo.
  List<List<String>> _clockFrames(
    List<String> lines,
    DateTime? start,
    int? seconds,
    int clockLine,
  ) {
    if (start == null ||
        seconds == null ||
        seconds <= 0 ||
        clockLine < 0 ||
        clockLine >= lines.length) {
      return [lines];
    }
    String two(int n) => n.toString().padLeft(2, '0');
    return [
      for (var s = 0; s < seconds; s++)
        [
          for (var i = 0; i < lines.length; i++)
            if (i != clockLine)
              lines[i]
            else
              () {
                final at = start.add(Duration(seconds: s));
                return '${two(at.hour)}:${two(at.minute)}:${two(at.second)}';
              }(),
        ],
    ];
  }

  /// Vẽ mọi khung chữ vào một ảnh duy nhất, xếp lưới.
  ///
  /// Vẽ bằng Flutter chứ không dùng `drawtext` của ffmpeg: `drawtext` đòi một
  /// file font nằm sẵn trên đĩa, mà app không đóng gói font nào — còn cách này
  /// dùng luôn bộ chữ hệ thống và hiện được tiếng Việt có dấu. Đổi lại, chữ
  /// động phải vẽ sẵn hết rồi để ffmpeg cắt đúng ô theo thời gian.
  ///
  /// Xếp lưới chứ không xếp một cột dài: một cột 900 giây cao hơn giới hạn
  /// texture của GPU, còn lưới vuông thì cả hai cạnh đều nhỏ.
  Future<_Sprite?> _renderSprite(List<List<String>> frames) async {
    final painters = [
      for (final lines in frames) [for (final line in lines) _painter(line)],
    ];
    const gap = 8.0;
    var cellWidth = 0.0;
    var cellHeight = 0.0;
    for (final cell in painters) {
      var width = 0.0;
      var height = gap * (cell.length - 1);
      for (final p in cell) {
        if (p.width > width) width = p.width;
        height += p.height;
      }
      if (width > cellWidth) cellWidth = width;
      if (height > cellHeight) cellHeight = height;
    }
    final cw = cellWidth.ceil();
    final ch = cellHeight.ceil();
    if (cw <= 0 || ch <= 0) return null;

    // Số cột lấy hết bề ngang cho phép, rồi mới tính số hàng — cách này cho
    // nhiều ô nhất trong cùng một giới hạn cạnh.
    final columns = frames.length == 1
        ? 1
        : (_maxSpriteEdge ~/ cw).clamp(1, frames.length);
    final rows = (frames.length + columns - 1) ~/ columns;
    if (rows * ch > _maxSpriteEdge) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    for (var i = 0; i < painters.length; i++) {
      final originX = (i % columns) * cw.toDouble();
      var dy = (i ~/ columns) * ch.toDouble();
      for (final p in painters[i]) {
        p.paint(canvas, Offset(originX, dy));
        dy += p.height + gap;
      }
    }
    final image = await recorder.endRecording().toImage(
      columns * cw,
      rows * ch,
    );
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return null;
      final dir = _outputDirectory ?? await getTemporaryDirectory();
      final file = File(
        '${dir.path}/stamp_${DateTime.now().microsecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      return _Sprite(
        path: file.path,
        cellWidth: cw,
        cellHeight: ch,
        columns: columns,
        count: frames.length,
      );
    } finally {
      image.dispose();
    }
  }

  TextPainter _painter(String line) => TextPainter(
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
  )..layout();

  /// Ghi filtergraph ra file rồi nạp bằng `-filter_complex_script`.
  ///
  /// KHÔNG truyền thẳng trên dòng lệnh: FFmpegKit tự tách chuỗi lệnh và bóc
  /// dấu nháy, mà biểu thức ở đây có dấu phẩy — bóc nháy xong ffmpeg đọc dấu
  /// phẩy đó thành dấu ngăn giữa hai bộ lọc và cả câu lệnh hỏng. Hỏng kiểu này
  /// lại rơi vào nhánh fail-safe nên rất khó lần ra: file tải về vẫn có, chỉ
  /// là không có chữ nào.
  Future<String> _writeGraph(_Sprite sprite) async {
    final dir = _outputDirectory ?? await getTemporaryDirectory();
    final file = File(
      '${dir.path}/stamp_${DateTime.now().microsecondsSinceEpoch}.txt',
    );
    // `min(...)` giữ ô cuối đứng lại thay vì cắt ra ngoài ảnh khi clip dài hơn
    // số giây đã vẽ (làm tròn thời lượng, hoặc khung cuối lố một nhịp).
    final index = 'min(floor(t),${sprite.count - 1})';
    final x = "'mod($index,${sprite.columns})*${sprite.cellWidth}'";
    final y = "'floor($index/${sprite.columns})*${sprite.cellHeight}'";
    // `shortest=1` là thứ THẬT SỰ chốt clip, không phải `-shortest` trên dòng
    // lệnh: `-loop 1` cho ảnh dấu là một luồng vô hạn, mà `-shortest` không
    // ràng buộc được luồng đi qua `filter_complex`. Thiếu nó, ffmpeg encode
    // mãi không dừng — đo được ở đây: clip vào 5 giây, sau 20 giây đã đẻ ra 41
    // phút hình và vẫn chạy tiếp cho tới lúc đầy đĩa. Trên máy người dùng, cái
    // hỏng đó rơi vào fail-safe nên chỉ hiện ra thành "clip tải về mất chữ".
    await file.writeAsString(
      '[1:v]crop=${sprite.cellWidth}:${sprite.cellHeight}:$x:$y[stamp];'
      '[0:v][stamp]overlay=$_margin:$_margin:shortest=1[out]',
      flush: true,
    );
    return file.path;
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
        // Lời than của chính ffmpeg là thứ duy nhất nói được vì sao dấu không
        // lên. Không có nó thì mọi kiểu hỏng — thiếu font, sai biểu thức, hết
        // đĩa — đều hiện ra giống hệt nhau: một clip không có chữ.
        if (!success) {
          var output = '';
          try {
            output = session.getOutput() ?? '';
          } on Object {
            output = '(không đọc được log ffmpeg)';
          }
          _log(
            'ffmpeg lỗi.\nlệnh: $command\n'
            'log: ${output.length > 2000 ? output.substring(output.length - 2000) : output}',
          );
        }
        if (!completer.isCompleted) completer.complete(success);
      },
    );
    return completer.future;
  }

  /// Hỏi thẳng ffmpeg trong app xem nó mã hoá H.264 bằng gì được.
  ///
  /// Chạy đúng lúc đã hỏng hết, nên không tốn gì của đường chạy bình thường.
  /// Đây là câu trả lời dứt điểm cho kiểu bug đã ăn mất mấy vòng thử: bản
  /// ffmpeg nhúng trong app không phải bản ffmpeg trên máy người viết code, mà
  /// khác nhau ở chỗ nào thì không nhìn từ ngoài mà biết được. Danh sách rỗng
  /// nghĩa là ffmpeg trong app không chạy được lệnh nào cả — hỏng nặng hơn
  /// nhiều so với thiếu một bộ mã hoá.
  Future<void> _logAvailableEncoders() async {
    if (_runner != null) return;
    try {
      final completer = Completer<String>();
      // Kết quả về qua `onComplete`, không qua Future trả ra — chờ ở đây là
      // treo luôn.
      unawaited(
        FFmpegKit.executeAsync(
          '-hide_banner -encoders',
          onComplete: (session) {
            if (completer.isCompleted) return;
            try {
              completer.complete(session.getOutput() ?? '');
            } on Object {
              completer.complete('');
            }
          },
        ),
      );
      final output = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => '(quá hạn)',
      );
      final h264 = output
          .split('\n')
          .where((line) => line.contains('264') || line.contains('mpeg4'))
          .join('\n');
      _log(
        'bộ mã hoá ffmpeg trong app có:\n${h264.isEmpty ? '(không có)' : h264}',
      );
    } on Object catch (e) {
      _log('không hỏi được danh sách bộ mã hoá', e);
    }
  }

  /// Vì sao clip ra không có chữ — câu hỏi mà trước đây không chỗ nào trả lời
  /// được. [stamp] cố tình nuốt mọi lỗi để người dùng vẫn cầm được file, nên
  /// nếu ở đây cũng im nốt thì hỏng chỉ hiện ra trên máy người dùng dưới dạng
  /// "clip tải về mất chữ" và không lần được về nguyên nhân nào.
  void _log(String message, [Object? error, StackTrace? stack]) =>
      developer.log(
        message,
        name: 'evidencecam.stamp',
        level: 900,
        error: error,
        stackTrace: stack,
      );
}

/// Một bộ mã hoá hình kèm tham số chất lượng của riêng nó.
class _Encoder {
  const _Encoder(this.name, this.quality);

  final String name;

  /// Tham số chất lượng phải đi cùng bộ mã hoá: bộ phần cứng chỉ hiểu bitrate,
  /// x264 hiểu CRF, `mpeg4` hiểu thang `-q:v`. Trộn nhầm là ffmpeg bỏ lệnh.
  final String quality;
}

/// Ảnh dấu đã lát ô, kèm số đo để dựng biểu thức `crop`.
class _Sprite {
  const _Sprite({
    required this.path,
    required this.cellWidth,
    required this.cellHeight,
    required this.columns,
    required this.count,
  });

  final String path;
  final int cellWidth;
  final int cellHeight;
  final int columns;

  /// Số ô đã vẽ; bằng số giây của clip, hoặc 1 khi dấu đứng im.
  final int count;
}
