/// Hai phép tính của zoom, tách khỏi màn hình để đo được.
///
/// Nằm riêng vì chúng là chỗ dễ sai mà khó thấy: một bước zoom chốt cứng thì
/// sai ở CẢ HAI đầu dải, và một cái nhãn sai định dạng thì người dùng đọc mãi
/// không hiểu mình đang ở mức nào.
library;

import 'dart:math' as math;

/// Bước zoom cho MỘT lần bấm nút.
///
/// Chia dải làm mười nhịp, nhưng không nhỏ hơn 0.2x.
///
/// Vì sao không chốt cứng một bước: dải zoom khác nhau cả chục lần giữa các
/// máy. Máy có ống tele cho dải 1–10, chốt bước 0.2x thì phải bấm bốn mươi lăm
/// lần mới hết đường. Webcam cho dải 1–2, chốt bước 1x thì hai lần bấm là hết.
/// Chia theo dải thì cả hai đều mất mười nhịp.
///
/// Sàn 0.2x là để dải cực hẹp không sinh ra bước nhỏ tới mức bấm không thấy
/// hình đổi — người dùng sẽ kết luận nút hỏng.
double ecBuocZoom(double minZoom, double maxZoom) =>
    math.max(0.2, (maxZoom - minZoom) / 10);

/// Nhãn mức zoom: `1x`, `1.8x`.
///
/// Bỏ đuôi `.0` vì `1.0x` đọc như một con số đang chờ nhập tiếp, còn `1x` là
/// một mức đã chốt. Một chữ số thập phân là đủ: `1.83x` không giúp gì cho việc
/// soi một thùng hàng, mà làm nhãn dài thêm và nhảy số liên tục.
String ecNhanZoom(double zoom) {
  final tron = zoom.toStringAsFixed(1);
  final goc = tron.endsWith('.0') ? tron.substring(0, tron.length - 2) : tron;
  return '${goc}x';
}

/// Máy này có zoom được không.
///
/// `maxZoom <= minZoom` nghĩa là một mức duy nhất — nhiều webcam và vài camera
/// trước là như vậy. Lúc đó cột nút KHÔNG hiện: bày một cặp nút xám vĩnh viễn
/// trên khung ngắm là chiếm chỗ để nói một câu vô ích.
bool ecZoomDuoc(double minZoom, double maxZoom) => maxZoom > minZoom;
