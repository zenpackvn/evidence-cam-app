import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // Ba kênh liên hệ (Facebook, Zalo, gọi điện) đã gỡ khỏi app 09/09 và chỉ còn
  // trên web. Bài này canh việc chúng không lặng lẽ quay lại — cụm bong bóng
  // nổi đó từng chiếm góc phải màn Tài khoản, và thêm lại nó là một dòng.
  //
  // Đọc THẲNG mã nguồn: không có màn nào để dựng lên mà đo "thứ không tồn tại",
  // và một bài widget khẳng định `findsNothing` sẽ xanh cả khi màn hỏng hoàn
  // toàn không vẽ được gì.
  test('app KHÔNG còn cụm liên hệ nổi, và không còn địa chỉ liên hệ cứng', () {
    final man = File(
      'packages/features/account/lib/src/ec_flow4.dart',
    ).readAsStringSync();
    expect(
      man.contains('_SupportContactColumn'),
      isFalse,
      reason: 'cụm bong bóng liên hệ đã quay lại màn Tài khoản',
    );
    expect(man.contains('_SupportBubble'), isFalse);

    final vo = File('lib/ec_app.dart').readAsStringSync();
    for (final dia in ['zalo.me/', 'facebook.com/zenpack', 'tel:0']) {
      expect(
        vo.contains(dia),
        isFalse,
        reason:
            'còn "$dia" trong app — địa chỉ liên hệ nay chỉ ở web, giữ bản sao '
            'ở đây là để nó lỗi thời trong im lặng',
      );
    }
  });
}
