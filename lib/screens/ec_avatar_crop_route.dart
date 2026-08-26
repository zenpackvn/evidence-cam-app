/// Màn kéo–phóng để chọn phần ảnh sẽ thành ảnh đại diện.
///
/// Đặt ở `lib/screens/` theo đúng tiền lệ của màn cắt video: đây là một màn
/// biên tập toàn màn hình, đẩy lên rồi trả kết quả về bằng `pop`, và nó cần
/// `ImagePicker` cùng thư mục tạm — hai thứ sống ở app shell, không ở gói tính
/// năng.
///
/// Trước đây ảnh chọn xong bị cắt thẳng bằng `BoxFit.cover`: máy tự quyết giữ
/// phần giữa, nên ảnh chụp nghiêng hay ảnh có người đứng lệch đều bị cắt mất
/// đúng cái đáng giữ. Giờ người dùng tự quyết, và thứ họ thấy trong khung tròn
/// chính xác là thứ được lưu.
library;

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:localization/localization.dart';
import 'package:path_provider/path_provider.dart';

import '../data/ec_avatar_crop.dart';

/// Chữ ký của bước cắt, tách ra làm chỗ nối cho test.
typedef EcAvatarCropper =
    Future<String?> Function({
      required String sourcePath,
      required Rect sourceRect,
      required Future<Uint8List> Function(String path) readBytes,
      required Future<String> Function(String name, Uint8List bytes) writeBytes,
      int maxSide,
    });

/// Kéo và phóng [sourcePath] trong một khung tròn; `pop` trả về đường dẫn tệp
/// PNG đã cắt, hoặc `null` khi người dùng thoát ra.
class EcAvatarCropRoute extends StatefulWidget {
  const EcAvatarCropRoute({
    required this.sourcePath,
    this.cropper = ecWriteCroppedAvatar,
    super.key,
  });

  final String sourcePath;
  final EcAvatarCropper cropper;

  @override
  State<EcAvatarCropRoute> createState() => _EcAvatarCropRouteState();
}

class _EcAvatarCropRouteState extends State<EcAvatarCropRoute> {
  final _controller = TransformationController();

  /// Kích thước thật của ảnh nguồn, tính bằng pixel. `null` = chưa đọc xong.
  Size? _source;
  bool _busy = false;

  /// Cạnh khung ở lượt dựng gần nhất — cần để đổi ma trận sang vùng ảnh gốc.
  double _viewport = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_readSourceSize());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _readSourceSize() async {
    ui.Image? image;
    try {
      final codec = await ui.instantiateImageCodec(
        await File(widget.sourcePath).readAsBytes(),
      );
      image = (await codec.getNextFrame()).image;
      if (!mounted) return;
      setState(
        () => _source = Size(
          image!.width.toDouble(),
          image.height.toDouble(),
        ),
      );
    } on Object {
      // Không đọc được ảnh thì đóng màn luôn, thay vì để người dùng ngồi trước
      // một khung trống không bao giờ hiện gì.
      if (mounted) Navigator.of(context).pop();
    } finally {
      image?.dispose();
    }
  }

  Future<void> _confirm() async {
    final source = _source;
    if (source == null || _busy || _viewport <= 0) return;
    setState(() => _busy = true);
    final path = await widget.cropper(
      sourcePath: widget.sourcePath,
      sourceRect: ecAvatarSourceRect(
        source: source,
        viewport: _viewport,
        matrix: _controller.value,
      ),
      readBytes: (p) => File(p).readAsBytes(),
      writeBytes: _writeToTemp,
      maxSide: 512,
    );
    if (!mounted) return;
    if (path == null) {
      setState(() => _busy = false);
      ecToast(context, context.l10n.avatarCropFailed);
      return;
    }
    Navigator.of(context).pop(path);
  }

  Future<String> _writeToTemp(String name, Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final source = _source;
    return PenScreen(
      // `false` là BẮT BUỘC: mặc định `PenScreen` bọc con trong một
      // `SingleChildScrollView`, và nó nuốt sạch cử chỉ kéo dọc — đúng thứ màn
      // này sống bằng.
      scrollable: false,
      bottomBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: PenPrimaryButton(
          label: l10n.avatarCropConfirm,
          onPressed: source == null || _busy ? null : _confirm,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: PenHeader(
              title: l10n.avatarCropTitle,
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PenText(
              l10n.avatarCropHint,
              size: 14,
              color: PenColors.mut,
              align: TextAlign.center,
              lineHeight: 1.4,
            ),
          ),
          Expanded(
            child: Center(
              child: source == null
                  ? const SizedBox.shrink()
                  : _CropViewport(
                      source: source,
                      controller: _controller,
                      onViewport: (side) => _viewport = side,
                      path: widget.sourcePath,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Khung tròn và ảnh kéo được bên trong nó.
class _CropViewport extends StatelessWidget {
  const _CropViewport({
    required this.source,
    required this.controller,
    required this.onViewport,
    required this.path,
  });

  final Size source;
  final TransformationController controller;
  final ValueChanged<double> onViewport;
  final String path;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final side = math.max(
        // 0 (int) khiến math.max suy ra num, gán vào double là lỗi biên dịch.
        // ignore: prefer_int_literals
        0.0,
        math.min(constraints.maxWidth, constraints.maxHeight) - 40,
      );
      onViewport(side);
      // Đặt ma trận khởi đầu ngay khi biết cạnh khung, và CHỈ khi nó còn là ma
      // trận đơn vị — đặt lại ở mỗi lượt dựng sẽ giật phăng ảnh về giữa ngay
      // giữa lúc người dùng đang kéo.
      if (controller.value == Matrix4.identity() && side > 0) {
        controller.value = ecAvatarInitialMatrix(source, side);
      }
      final cover = ecAvatarCoverSize(source, side);
      return ClipOval(
        child: SizedBox.square(
          dimension: side,
          child: InteractiveViewer(
            transformationController: controller,
            // `false` để con được PHÉP lớn hơn khung trên trục dài — đó chính
            // là phần ảnh người dùng kéo qua kéo lại.
            constrained: false,
            // Không cho kéo hở mép: khung tròn luôn phải đầy ảnh.
            boundaryMargin: EdgeInsets.zero,
            // 1.0 = đúng khung "phủ kín" ban đầu, nên không bao giờ thu nhỏ
            // được tới mức lòi nền ra.
            minScale: 1,
            maxScale: 8,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: cover.width,
              height: cover.height,
              child: Image.file(File(path), fit: BoxFit.fill),
            ),
          ),
        ),
      );
    },
  );
}
