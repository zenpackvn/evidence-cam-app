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
      if (mounted) setState(() => _frames = frames);
    } on Object {
      if (mounted) setState(() => _ready = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  Future<void> _playSelection() async {
    await _controller.seekTo(_start);
    await _controller.play();
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
                    ? _Preview(controller: _controller)
                    : const CupertinoActivityIndicator(color: Color(0xFFBFD0FF)),
              ),
            ),
            if (_ready && _total > Duration.zero) ...[
              _Filmstrip(
                frames: _frames,
                total: _total,
                start: _start,
                end: _end,
                onChanged: (start, end) {
                  setState(() {
                    _start = start;
                    _end = end;
                  });
                  unawaited(_controller.seekTo(start));
                },
                minSpan: _minSpan,
              ),
              _TrimFooter(
                start: _start,
                end: _end,
                sizeLabel: _estimatedSize,
                saving: _saving,
                onPlay: _playSelection,
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
  const _Preview({required this.controller});

  final AppVideoPlayerController controller;

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
          child: VideoPlayer(raw),
        ),
      ),
    );
  }
}

/// Dải ảnh nhỏ kèm hai tay kéo — chọn đoạn giữ lại.
class _Filmstrip extends StatelessWidget {
  const _Filmstrip({
    required this.frames,
    required this.total,
    required this.start,
    required this.end,
    required this.onChanged,
    required this.minSpan,
  });

  final List<File> frames;
  final Duration total;
  final Duration start;
  final Duration end;
  final void Function(Duration start, Duration end) onChanged;
  final Duration minSpan;

  static const _height = 64.0;
  static const _handle = 14.0;

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
        double xOf(Duration d) => d.inMilliseconds / total.inMilliseconds * width;
        final left = xOf(start);
        final right = xOf(end);
        return SizedBox(
          height: _height,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: frames.isEmpty
                      ? const ColoredBox(color: Color(0xFF1B2748))
                      : Row(
                          children: [
                            for (final frame in frames)
                              Expanded(
                                child: Image.file(
                                  frame,
                                  fit: BoxFit.cover,
                                  height: _height,
                                  gaplessPlayback: true,
                                ),
                              ),
                          ],
                        ),
                ),
              ),
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
    required this.sizeLabel,
    required this.saving,
    required this.onPlay,
    required this.onSave,
    required this.saveLabel,
    required this.sizeCaption,
  });

  final Duration start;
  final Duration end;
  final String sizeLabel;
  final bool saving;
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
          child: const Icon(
            LucideIcons.play,
            size: 18,
            color: Color(0xFFE7EDFF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_clock(start)}  →  ${_clock(end)}',
                style: const TextStyle(
                  color: Color(0xFFE7EDFF),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$sizeCaption $sizeLabel',
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
