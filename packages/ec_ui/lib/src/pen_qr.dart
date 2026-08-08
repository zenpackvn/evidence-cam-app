import 'package:ec_ui/src/pen_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Mã QR trên nền thẻ trắng, đúng khuôn của bộ giao diện.
///
/// Nền trắng và viền trắng KHÔNG phải trang trí: máy quét cần vùng lặng quanh
/// mã, và nền màu của app đủ tối để làm hỏng tương phản. Vẽ ngay trên máy chứ
/// không xin ảnh từ máy chủ — mã này thường được chìa ra giữa lúc mạng kém,
/// đúng lúc không được phép chờ một lượt tải về.
class PenQrCard extends StatelessWidget {
  const PenQrCard({required this.data, this.size = 220, super.key});

  /// Nội dung mã hoá vào mã — thường là một link.
  final String data;

  /// Cạnh của phần mã, chưa tính viền trắng.
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: PenColors.line),
    ),
    child: QrImageView(
      data: data,
      size: size,
      // Nền trong suốt: thẻ bên ngoài đã lo phần trắng, tô hai lần thì viền bo
      // của thẻ bị một hình vuông đè lên.
      backgroundColor: const Color(0x00000000),
      // `L` đủ cho một link ngắn và cho mã thưa hơn — dễ quét hơn ở khoảng
      // cách xa, thứ luôn xảy ra khi hai người chìa điện thoại cho nhau.
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    ),
  );
}
