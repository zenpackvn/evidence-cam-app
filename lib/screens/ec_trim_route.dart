/// Màn cắt đầu/cuối một clip ĐÃ NIÊM PHONG, để gửi ra ngoài một đoạn ngắn.
///
/// Thứ được cắt là bản đã tải về máy, không phải bằng chứng trên máy chủ: bản
/// gốc vẫn nguyên, vẫn giữ vân tay và link kiểm chứng. Và vì bản tải về là bản
/// đã nung, đoạn cắt ra vẫn mang dấu giờ + mã vận đơn trên hình.
library;

import 'dart:async';
import 'dart:io';

import 'package:app_platform/app_platform.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material;
import 'package:localization/localization.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

/// Kết quả trả về cho bên gọi: đường dẫn bản đã cắt trên máy.
typedef EcTrimResult = String;

class EcTrimRoute extends StatefulWidget {
  const EcTrimRoute({
    required this.sourcePath,
    required this.tracking,
    required this.player,
    this.trimmer,
    this.onSave,
    super.key,
  });

  /// Bản đầy đủ đã tải về máy — KHÔNG bị xoá hay ghi đè, mọi lượt cắt đều đẻ
  /// ra tệp mới.
  final String sourcePath;

  /// Mã vận đơn, hiện ngay trên cùng: một màn cắt không nói rõ đang cắt clip
  /// của đơn nào là chỗ rất dễ gửi nhầm bằng chứng sang đơn khác.
  final String tracking;

  final VideoPlayerService player;
  final EcVideoTrimService? trimmer;

  /// Nhận đường dẫn bản đã cắt. Màn này không tự quyết chia sẻ hay lưu về máy
  /// — đó là việc của bên gọi, nơi đã có sẵn dịch vụ chia sẻ và thư viện ảnh.
  final Future<void> Function(String path)? onSave;

  @override
  State<EcTrimRoute> createState() => _EcTrimRouteState();
}

class _EcTrimRouteState extends State<EcTrimRoute> {
  late final AppVideoPlayerController _controller = widget.player.file(
    File(widget.sourcePath),
  );
  late final EcVideoTrimService _trimmer =
      widget.trimmer ?? EcVideoTrimService();

  Duration _total = Duration.zero;
  Duration _start = Duration.zero;
  Duration _end = Duration.zero;
  List<File> _frames = const [];

  /// Dải ảnh dựng MỘT lần cho mỗi bộ ảnh, rồi truyền nguyên thực thể đó xuống
  /// mỗi lượt dựng. Xem [_Filmstrip.strip].
  Widget _strip = const ColoredBox(color: Color(0xFF1B2748));
  bool _ready = false;
  bool _saving = false;
  int? _sourceBytes;

  /// Đoạn ngắn nhất giữ lại được. Dưới một giây thì bản cắt ra gần như không
  /// còn khung hình nào sau khi bám về khung khoá.
  static const _minSpan = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _sourceBytes = EcVideoTrimService.sizeOf(widget.sourcePath);
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(looping: false);
      _controller.valueListenable.addListener(_watchPlayhead);
      final total = _controller.value.duration;
      if (!mounted) return;
      setState(() {
        _total = total;
        _start = Duration.zero;
        _end = total;
        _ready = true;
      });
      final frames = await _trimmer.filmstrip(
        inputPath: widget.sourcePath,
        duration: total,
      );
      if (mounted) {
        setState(() {
          _frames = frames;
          _strip = _buildStrip(frames);
        });
      }
    } on Object {
      if (mounted) setState(() => _ready = true);
    }
  }

  @override
  void dispose() {
    _controller.valueListenable.removeListener(_watchPlayhead);
    _controller.dispose();
    super.dispose();
  }

  /// Dải ảnh nền của thanh thời gian. Gọi một lần cho mỗi bộ ảnh.
  static Widget _buildStrip(List<File> frames) {
    if (frames.isEmpty) return const ColoredBox(color: Color(0xFF1B2748));
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          for (final frame in frames)
            Expanded(
              child: Image.file(
                frame,
                fit: BoxFit.cover,
                height: _Filmstrip._height,
                // Ảnh gốc cao 360 vì ô xem trước cần nét; giải mã nguyên cỡ
                // cho 24 ô cao 64 là ném vài chục MB vào bộ nhớ ảnh cho thứ
                // không ai nhìn rõ. Cỡ này đủ cho màn 3x.
                cacheHeight: (_Filmstrip._height * 3).round(),
                gaplessPlayback: true,
              ),
            ),
        ],
      ),
    );
  }

  Duration get _span => _end - _start;

  /// Cỡ bản cắt, ước lượng theo tỉ lệ thời lượng.
  ///
  /// Là ƯỚC LƯỢNG, và nói thẳng ra như vậy trên màn: bitrate không đều nhau
  /// giữa các đoạn, nên con số thật chỉ biết sau khi cắt xong.
  String get _estimatedSize {
    final bytes = _sourceBytes;
    if (bytes == null || _total.inMilliseconds == 0) return '—';
    final ratio = _span.inMilliseconds / _total.inMilliseconds;
    return EcVideoTrimService.formatSize((bytes * ratio).round());
  }

  /// Dừng ngay khi chạm tay kéo cuối.
  ///
  /// Trình phát không biết gì về đoạn đã chọn — thả nó ra là nó chạy tới hết
  /// clip, tức phát cả phần người dùng vừa cắt bỏ. Canh vị trí ở đây là cách
  /// duy nhất để "xem thử" đúng nghĩa xem thử đoạn sẽ lưu.
  void _watchPlayhead() {
    final position = _controller.value.position;
    if (_controller.value.isPlaying && position >= _end) {
      unawaited(_controller.pause());
      unawaited(_controller.seekTo(_start));
    }
    if (mounted) setState(() {});
  }

  /// Đang có ngón tay trên thanh thời gian.
  bool _scrubbing = false;
  Duration _scrubTarget = Duration.zero;
  bool _seeking = false;
  Duration? _pendingSeek;

  /// Video đang chạy lúc ngón tay vừa chạm thanh. Kéo kim của một clip đang
  /// phát thì nó phải phát tiếp từ chỗ mới ngay trong lúc kéo — dừng lại chờ
  /// thả tay là bắt người dùng kéo mù, không nghe không thấy đoạn mình chọn.
  bool _playingWhenScrubStarted = false;

  /// Ảnh gần nhất trong dải phim ứng với mốc [at].
  File? _frameAt(Duration at) {
    if (_frames.isEmpty || _total.inMilliseconds == 0) return null;
    final index =
        (at.inMilliseconds / _total.inMilliseconds * (_frames.length - 1))
            .round()
            .clamp(0, _frames.length - 1);
    return _frames[index];
  }

  void _onScrub(Duration position) {
    // Chỉ đọc ở lần chạm ĐẦU của một lượt kéo: các lần gọi sau đó là ngón tay
    // đang di chuyển, lúc ấy trạng thái phát đã là hệ quả của chính lượt kéo
    // này chứ không còn là ý định ban đầu của người dùng.
    if (!_scrubbing) _playingWhenScrubStarted = _controller.value.isPlaying;
    setState(() {
      _scrubbing = true;
      _scrubTarget = position;
    });
    // KHÔNG dừng khi đang phát: kéo tới đâu video chạy tiếp từ đó. Mỗi lệnh
    // tua lúc đang phát tốn hơn lúc dừng, nhưng `_seekQueued` đã gộp chúng lại
    // còn một lệnh đang bay nên chi phí đó có trần.
    unawaited(_seekQueued(position));
  }

  void _onScrubEnd() {
    if (!mounted) return;
    setState(() => _scrubbing = false);
    unawaited(
      _seekQueued(_scrubTarget).then((_) {
        // Một số nền tảng tự dừng khi nhận lệnh tua. Đang phát trước lúc kéo
        // thì phải còn phát sau khi thả tay — thả tay xong video đứng im là
        // người dùng phải bấm phát lại cho mỗi lần chỉnh.
        if (!mounted || !_playingWhenScrubStarted) return;
        if (!_controller.value.isPlaying) unawaited(_controller.play());
      }),
    );
  }

  /// Mỗi lúc chỉ một lệnh tua đang bay, mốc mới đè lên mốc đang chờ.
  ///
  /// Thanh kéo bắn sự kiện mỗi khung hình; gửi thẳng ngần ấy lệnh xuống nền
  /// tảng là xếp hàng cả trăm lệnh, thả tay rồi video vẫn còn chạy đuổi theo
  /// những mốc đã cũ.
  Future<void> _seekQueued(Duration target) async {
    if (_seeking) {
      _pendingSeek = target;
      return;
    }
    _seeking = true;
    var next = target;
    while (true) {
      await _controller.seekTo(next);
      final queued = _pendingSeek;
      if (queued == null) break;
      _pendingSeek = null;
      next = queued;
    }
    _seeking = false;
    // Hàng tua đã cạn nghĩa là trình phát đã đứng đúng khung hình người dùng
    // chỉ tới. Dựng lại để ô xem trước bỏ ảnh dải phim và trả về hình nét.
    if (mounted) setState(() {});
  }

  /// Bấm phát/tạm dừng như trình phát thường: đang chạy thì dừng tại chỗ, đang
  /// dừng thì chạy tiếp. Chỉ nhảy về đầu đoạn khi kim đang nằm ngoài đoạn —
  /// dừng giữa chừng rồi bấm tiếp mà bị kéo về đầu là mất chỗ đang xem.
  Future<void> _togglePlay() async {
    if (_controller.value.isPlaying) {
      await _controller.pause();
      if (mounted) setState(() {});
      return;
    }
    final position = _controller.value.position;
    if (position < _start || position >= _end) await _controller.seekTo(_start);
    await _controller.play();
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _controller.pause();
      final path = await _trimmer.trim(
        inputPath: widget.sourcePath,
        start: _start,
        end: _end,
      );
      if (!mounted) return;
      if (path == null) {
        _toast(context.l10n.trimFailed);
        return;
      }
      await widget.onSave?.call(path);
      if (mounted) Navigator.of(context).pop(path);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String message) => showCupertinoDialog<void>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.commonClose),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0E1730),
      child: SafeArea(
        child: Column(
          children: [
            _TrimHeader(
              tracking: widget.tracking,
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Center(
                child: _ready
                    ? _Preview(
                        controller: _controller,
                        // Ảnh dải phim chỉ đắp vào lúc trình phát CHƯA theo
                        // kịp: nó nằm sẵn trong bộ nhớ nên đổi tức thì, còn
                        // lệnh tua phải giải mã thật nên chậm sau ngón tay
                        // vài trăm mili giây. Nhưng nó là ảnh nhỏ, phóng lên
                        // cỡ này thì nhoè — nên hàng tua vừa cạn là bỏ ngay
                        // để trả về hình nét, và lúc đang phát thì không đắp
                        // nữa vì trình phát đã tự ra khung hình liên tục.
                        scrubFrame: _scrubbing && _seeking
                            ? _frameAt(_scrubTarget)
                            : null,
                      )
                    : const CupertinoActivityIndicator(
                        color: Color(0xFFBFD0FF),
                      ),
              ),
            ),
            if (_ready && _total > Duration.zero) ...[
              _Filmstrip(
                strip: _strip,
                total: _total,
                start: _start,
                end: _end,
                playhead: _controller.value.position,
                playing: _controller.value.isPlaying,
                onChanged: (start, end) {
                  setState(() {
                    _start = start;
                    _end = end;
                  });
                  unawaited(_controller.seekTo(start));
                },
                onScrub: _onScrub,
                onScrubEnd: _onScrubEnd,
                minSpan: _minSpan,
              ),
              _TrimFooter(
                start: _start,
                end: _end,
                playhead: _controller.value.position,
                sizeLabel: _estimatedSize,
                saving: _saving,
                playing: _controller.value.isPlaying,
                onPlay: _togglePlay,
                onSave: _save,
                saveLabel: l10n.trimSave,
                sizeCaption: l10n.trimEstimatedSize,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrimHeader extends StatelessWidget {
  const _TrimHeader({required this.tracking, required this.onClose});

  final String tracking;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
    child: Row(
      children: [
        CupertinoButton(
          padding: const EdgeInsets.all(10),
          minimumSize: Size.zero,
          onPressed: onClose,
          child: const Icon(LucideIcons.x, size: 22, color: Color(0xFFE7EDFF)),
        ),
        Expanded(
          child: Text(
            tracking,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFE7EDFF),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 42),
      ],
    ),
  );
}

class _Preview extends StatelessWidget {
  const _Preview({required this.controller, this.scrubFrame});

  final AppVideoPlayerController controller;

  /// Ảnh dải phim hiện thay cho khung hình trình phát trong lúc kéo.
  final File? scrubFrame;

  @override
  Widget build(BuildContext context) {
    final raw = controller.rawController;
    if (raw == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: scrubFrame == null
              ? VideoPlayer(raw)
              : Image.file(
                  scrubFrame!,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
        ),
      ),
    );
  }
}

/// Dải ảnh nhỏ kèm hai tay kéo — chọn đoạn giữ lại.
class _Filmstrip extends StatelessWidget {
  const _Filmstrip({
    required this.strip,
    required this.total,
    required this.start,
    required this.end,
    required this.playhead,
    required this.playing,
    required this.onChanged,
    required this.onScrub,
    required this.onScrubEnd,
    required this.minSpan,
  });

  /// Dải ảnh dựng sẵn ở màn cha và giữ nguyên một thực thể giữa các lượt dựng.
  ///
  /// Kim chạy thì cả màn này dựng lại theo nhịp trình phát; dựng lại luôn 24
  /// `Image.file` ngần ấy lần một giây là chỗ giật rõ nhất khi kéo. Nhận vào
  /// một widget đã dựng sẵn thì Flutter thấy đúng thực thể cũ và bỏ qua cả
  /// nhánh đó.
  final Widget strip;
  final Duration total;
  final Duration start;
  final Duration end;

  /// Kim chỉ chỗ video đang phát tới — và cũng là chỗ KÉO ĐƯỢC: kéo kim tới
  /// đâu thì video nhảy tới đó. Luôn vẽ, kể cả lúc dừng, vì lúc dừng mới là
  /// lúc người ta cần dò tìm đúng khung hình để đặt điểm cắt.
  final Duration playhead;
  final bool playing;
  final void Function(Duration start, Duration end) onChanged;

  /// Nhảy tới một mốc trong đoạn đang chọn.
  final void Function(Duration position) onScrub;

  /// Ngón tay rời thanh thời gian.
  final VoidCallback onScrubEnd;
  final Duration minSpan;

  static const _height = 64.0;
  static const _handle = 14.0;

  /// Bề rộng vùng chạm của kim. Vạch vẽ ra chỉ 2 điểm ảnh, mà ngón tay thì
  /// không bấm trúng 2 điểm ảnh bao giờ.
  static const _playhead = 28.0;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        Duration atX(double x) => Duration(
          milliseconds: (x.clamp(0, width) / width * total.inMilliseconds)
              .round(),
        );
        double xOf(Duration d) =>
            d.inMilliseconds / total.inMilliseconds * width;
        // Tua chỉ trong đoạn đang giữ lại: kéo ra ngoài là xem thứ sắp bị cắt
        // bỏ, mà cả màn này sinh ra để xem trước thứ sẽ lưu.
        Duration clamp(Duration d) => d < start ? start : (d > end ? end : d);
        final left = xOf(start);
        final right = xOf(end);
        return SizedBox(
          height: _height,
          child: Stack(
            children: [
              Positioned.fill(child: strip),
              // Hai đầu bị bỏ đi phủ mờ: người dùng thấy ngay phần nào mất.
              Positioned(
                left: 0,
                width: left,
                top: 0,
                bottom: 0,
                child: const ColoredBox(color: Color(0xB30E1730)),
              ),
              Positioned(
                left: right,
                right: 0,
                top: 0,
                bottom: 0,
                child: const ColoredBox(color: Color(0xB30E1730)),
              ),
              // Chạm hoặc kéo bất kỳ đâu trên dải ảnh là nhảy tới đó. Nằm
              // DƯỚI hai tay kéo trong Stack nên vùng chạm của chúng vẫn được
              // ưu tiên — kéo mép đoạn không bị hiểu nhầm thành tua.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) => onScrub(clamp(atX(d.localPosition.dx))),
                  onHorizontalDragStart: (d) =>
                      onScrub(clamp(atX(d.localPosition.dx))),
                  onHorizontalDragUpdate: (d) =>
                      onScrub(clamp(atX(d.localPosition.dx))),
                  onHorizontalDragEnd: (_) => onScrubEnd(),
                  onHorizontalDragCancel: onScrubEnd,
                  onTapUp: (_) => onScrubEnd(),
                ),
              ),
              Positioned(
                left: (xOf(playhead) - _playhead / 2).clamp(
                  0.0,
                  width - _playhead,
                ),
                top: 0,
                bottom: 0,
                width: _playhead,
                // `height` phải khai rõ: trong `Center` thì ràng buộc là lỏng,
                // mà một `SizedBox` chỉ đặt bề rộng sẽ lấy chiều cao của con —
                // `ColoredBox` rỗng nên chiều cao bằng 0, và vạch biến mất.
                child: const Center(
                  child: SizedBox(
                    width: 2,
                    height: double.infinity,
                    child: ColoredBox(color: Color(0xFFFFFFFF)),
                  ),
                ),
              ),
              _Handle(
                x: left,
                onDrag: (dx) {
                  final next = atX(left + dx);
                  if (end - next >= minSpan) onChanged(next, end);
                },
              ),
              _Handle(
                x: right - _handle,
                onDrag: (dx) {
                  final next = atX(right + dx);
                  if (next - start >= minSpan) onChanged(start, next);
                },
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _Handle extends StatelessWidget {
  const _Handle({required this.x, required this.onDrag});

  final double x;
  final void Function(double dx) onDrag;

  @override
  Widget build(BuildContext context) => Positioned(
    left: x,
    top: 0,
    bottom: 0,
    width: _Filmstrip._handle,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
      child: Center(
        child: Container(
          width: _Filmstrip._handle,
          decoration: BoxDecoration(
            color: const Color(0xFF2FD3E8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            LucideIcons.gripVertical,
            size: 12,
            color: Color(0xFF07223A),
          ),
        ),
      ),
    ),
  );
}

class _TrimFooter extends StatelessWidget {
  const _TrimFooter({
    required this.start,
    required this.end,
    required this.playhead,
    required this.sizeLabel,
    required this.saving,
    required this.playing,
    required this.onPlay,
    required this.onSave,
    required this.saveLabel,
    required this.sizeCaption,
  });

  final Duration start;
  final Duration end;

  /// Chỗ video đang phát tới — chạy theo video, để người xem biết mình đang ở
  /// đâu trong đoạn chứ không phải chỉ biết đoạn dài bao nhiêu.
  final Duration playhead;
  final String sizeLabel;
  final bool saving;
  final bool playing;
  final VoidCallback onPlay;
  final VoidCallback onSave;
  final String saveLabel;
  final String sizeCaption;

  static String _clock(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final tenths = (d.inMilliseconds.remainder(1000) / 100).floor();
    return '${two(d.inMinutes)}:${two(d.inSeconds.remainder(60))}.$tenths';
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
    child: Row(
      children: [
        CupertinoButton(
          padding: const EdgeInsets.all(12),
          minimumSize: Size.zero,
          color: const Color(0xFF1B2748),
          borderRadius: BorderRadius.circular(999),
          onPressed: onPlay,
          child: Icon(
            playing ? LucideIcons.pause : LucideIcons.play,
            size: 18,
            color: const Color(0xFFE7EDFF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dòng trên chạy theo video (đang ở đâu / hết đoạn), dòng dưới
              // nói đoạn sẽ lưu là từ đâu tới đâu và nặng bao nhiêu.
              Text(
                '${_clock(playhead)} / ${_clock(end)}',
                style: const TextStyle(
                  color: Color(0xFFE7EDFF),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_clock(start)} → ${_clock(end)} · $sizeCaption $sizeLabel',
                style: const TextStyle(
                  color: Color(0xFF9FB0D9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Material chỉ để nút có gợn chạm giống các nút chính khác của app.
        Material(
          color: const Color(0x00000000),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
            minimumSize: Size.zero,
            color: const Color(0xFFF2F5FF),
            borderRadius: BorderRadius.circular(999),
            onPressed: saving ? null : onSave,
            child: saving
                ? const CupertinoActivityIndicator()
                : Text(
                    saveLabel,
                    style: const TextStyle(
                      color: Color(0xFF0E1730),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    ),
  );
}
