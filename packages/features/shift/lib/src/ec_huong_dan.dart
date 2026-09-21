import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// Mọi màn có hướng dẫn. Liệt kê tường minh để [EcHuongDanKho.quenHet] xoá
/// được sạch mà không phải quét khoá theo tiền tố — quét tiền tố là kiểu dọn
/// dẹp nuốt nhầm đúng một lần rồi không ai truy ra được.
enum EcMan {
  home,
  record,
  order,
  queue,
  claims,
  claimDetail,
  shops,
  quota,

  /// Màn tạo cửa hàng.
  createShop,

  /// Màn "chưa có cửa hàng nào" — màn ĐẦU TIÊN của người vừa lập tài khoản.
  /// Chỗ cần hướng dẫn nhất, và là chỗ tôi quên đầu tiên.
  noShop,

  /// Màn Tài khoản: gói cước, ngôn ngữ, cách đăng nhập.
  account,

  /// Màn Chi tiết cửa hàng: loại video và thành viên.
  shopDetail,
}

/// Nơi nhớ "đã xem hướng dẫn màn nào".
///
/// Là một giao diện chứ không đọc thẳng SharedPreferences trong widget: widget
/// nằm trong gói giao diện, mà gói đó không được biết gì về tầng lưu trữ. Bản
/// thật gắn ở tầng app; bản giả trong test chỉ là một Map.
abstract class EcHuongDanKho {
  bool daXem(EcMan man);
  Future<void> danhDau(EcMan man);
  Future<void> quenHet();

  /// Đã xem ba màn giới thiệu lúc mở app lần đầu chưa.
  ///
  /// Cấp MÁY, không gắn uid — khác hẳn [daXem]. Giới thiệu chạy TRƯỚC lúc đăng
  /// nhập, nên lúc đó chưa có ai để gắn vào. Và nó nói về sản phẩm chứ không
  /// nói về tài khoản: bắt người thứ hai trên cùng máy xem lại phần giới thiệu
  /// sản phẩm là thừa.
  bool daXemGioiThieu();
  Future<void> danhDauGioiThieu();
}

/// Kho TẮT hẳn: mọi màn đều coi như đã xem, nên không tấm nào bật lên.
///
/// Là mặc định khi bên gọi không đưa kho vào — tức trong bộ kiểm thử. Không
/// dùng [EcHuongDanKhoTam] làm mặc định: nó coi mọi màn là CHƯA xem, nên tấm
/// hướng dẫn bật lên che mất thứ mà bài kiểm thử đang tìm, và hàng chục bài
/// không liên quan gì tới hướng dẫn cùng đỏ một lúc.
///
/// Mặc định tắt là chọn có chủ ý: thà tính năng phụ không hiện còn hơn nó chen
/// ngang vào một màn mà bên gọi chưa kịp nghĩ tới.
class EcHuongDanKhoTat implements EcHuongDanKho {
  const EcHuongDanKhoTat();

  @override
  bool daXem(EcMan man) => true;

  @override
  Future<void> danhDau(EcMan man) async {}

  @override
  Future<void> quenHet() async {}

  @override
  bool daXemGioiThieu() => true;

  @override
  Future<void> danhDauGioiThieu() async {}
}

/// Bản nhớ trong bộ nhớ — dùng cho test và cho lúc chưa gắn kho thật.
class EcHuongDanKhoTam implements EcHuongDanKho {
  final _daXem = <EcMan>{};

  @override
  bool daXem(EcMan man) => _daXem.contains(man);

  @override
  Future<void> danhDau(EcMan man) async {
    _daXem.add(man);
  }

  @override
  Future<void> quenHet() async => _daXem.clear();

  bool _gioiThieu = false;

  @override
  bool daXemGioiThieu() => _gioiThieu;

  @override
  Future<void> danhDauGioiThieu() async => _gioiThieu = true;
}

/// Thẻ hướng dẫn hiện MỘT LẦN, lần đầu người này vào màn này.
///
/// **Không chặn màn hình.** Đây là thẻ nằm trong luồng nội dung, không phải hộp
/// thoại. Người đang vội đóng đơn lờ nó đi và làm việc được; người mới thì đọc.
/// Một hộp thoại chặn ngang ở mọi màn sẽ bị bấm-cho-xong từ màn thứ hai, và khi
/// đó nó không dạy được gì nữa.
///
/// **Nhớ theo TỪNG NGƯỜI**, không theo máy — xem [EcHuongDanKho] ở tầng app.
/// Điện thoại đóng gói là máy dùng chung ca, nhớ theo máy thì chỉ người đầu
/// tiên thấy hướng dẫn.
class EcHuongDan extends StatefulWidget {
  const EcHuongDan({
    required this.kho,
    required this.man,
    required this.tieuDe,
    required this.cacY,
    super.key,
  });

  final EcHuongDanKho kho;
  final EcMan man;
  final String tieuDe;

  /// Mỗi ý một dòng. Ba ý là vừa; nhiều hơn thì không ai đọc.
  final List<String> cacY;

  @override
  State<EcHuongDan> createState() => _EcHuongDanState();
}

class _EcHuongDanState extends State<EcHuongDan> {
  late bool _hien = !widget.kho.daXem(widget.man);

  Future<void> _dong() async {
    await widget.kho.danhDau(widget.man);
    if (mounted) setState(() => _hien = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hien) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      // Nền XÁM, không nhuốm màu thương hiệu.
      //
      // Luật của app (design-dna-app.md §1): "a faint fill is grey, never a
      // washed brand hue". Bản đầu tôi làm nền nhuốm màu primary — vi phạm
      // đúng luật đó, và nhìn ra là một mảng màu lạ giữa màn toàn xám trắng.
      // Màu thương hiệu ở app này chỉ dùng để TÔ ĐẶC nút chính, không dùng làm
      // nền nhạt.
      decoration: BoxDecoration(
        color: PenColors.soft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PenColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.lightbulb, size: 17, color: PenColors.mut),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tieuDe,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: PenColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                for (final y in widget.cacY) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chấm VẼ RA, không phải ký tự.
                        //
                        // Trước đây là '·' (U+00B7). Phông của app không có
                        // ký tự đó nên hệ thống thay bằng glyph dự phòng —
                        // một ô vuông hoặc dấu hỏi màu mực, đứng lù lù đầu
                        // mỗi dòng. Một hình vẽ thì không bao giờ phụ thuộc
                        // vào việc phông có chứa ký tự nào.
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(top: 7, right: 9),
                          decoration: BoxDecoration(
                            color: PenColors.mut,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            y,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.4,
                              color: PenColors.mut,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                TextButton(
                  onPressed: _dong,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 34),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(l10n.hdDaHieu),
                ),
              ],
            ),
          ),
          // Nút X làm ĐÚNG việc của nút "Đã hiểu": đóng và không hiện lại. Hai
          // cách đóng mà một cách quay lại sau khi mở lại app là thứ người dùng
          // đọc ra là lỗi.
          IconButton(
            onPressed: _dong,
            tooltip: l10n.hdDong,
            icon: Icon(LucideIcons.x, size: 16, color: PenColors.mut),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
