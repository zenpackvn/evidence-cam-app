// Nhãn của một bằng chứng `upload_status = 'error'` KHÔNG được đổ lỗi cho máy
// chủ.
//
// Trạng thái đó chỉ do lượt tải lên TỪ MÁY chưa xong. Ba đường duy nhất dẫn tới
// nó, cả ba đều nằm ở phía thiết bị:
//
//   * `sweepAbandonedUploads` — người quay đóng app hoặc mất mạng giữa chừng,
//     bản ghi đã xin khoá nhưng không bao giờ `completeUpload`;
//   * tệp vượt trần dung lượng — máy gửi lên một clip quá lớn;
//   * client tự gọi huỷ lượt multipart.
//
// Câu cũ là "Lỗi xử lý phía máy chủ". Người bán mở đơn ra, đọc đúng câu đó, rồi
// báo ZenPack hỏng — trong khi việc cần làm nằm ở máy của họ (quay lại, hoặc
// mở hàng đợi thử lại). Một nhãn chỉ sai địa chỉ thôi cũng đủ làm cả một lượt
// hỗ trợ đi nhầm hướng.
//
// Quét từ điển chứ không dựng màn: đây là một chuỗi, và thứ cần khoá là NỘI
// DUNG của nó ở mọi ngôn ngữ.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String code) =>
    jsonDecode(
          File(
            'packages/localization/lib/l10n/app_$code.arb',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

const _locales = [
  'vi',
  'en',
  'th',
  'de',
  'it',
  'es',
  'fil',
  'id',
  'fr',
  'ms',
];

void main() {
  test('nhãn upload lỗi không nhắc tới máy chủ', () {
    // Những chữ chỉ về phía máy chủ, ở đúng những thứ tiếng ta có.
    final blamesServer = RegExp(
      'máy chủ|server|เซิร์ฟเวอร์|serveur|servidor|servidore|pelayan',
      caseSensitive: false,
    );
    for (final code in _locales) {
      final value = _arb(code)['uploadStatusError'] as String;
      expect(
        blamesServer.hasMatch(value),
        isFalse,
        reason: 'app_$code.arb đổ lỗi cho máy chủ: $value',
      );
      expect(value.trim(), isNotEmpty, reason: 'app_$code.arb để trống');
    }
  });

  // Hàng đợi phải nói NGÀY lẫn giờ. Nó giữ clip qua đêm khi mạng chập hoặc hết
  // hạn mức, nên một cột chỉ có giờ thì "09:12" của hôm nay và "09:12" của ba
  // hôm trước trông y hệt nhau — đúng lúc người bán cần biết clip nào kẹt lâu.
  test('hàng đợi upload dựng nhãn từ cả ngày lẫn giờ', () {
    final source = File('lib/ec_app.dart').readAsStringSync();
    expect(
      source.contains(
        r"when: '${_dayLabelOf(task.createdAt)} ${_hhmm(task.createdAt)}'",
      ),
      isTrue,
      reason: 'hàng đợi lại chỉ mang giờ, không mang ngày',
    );
  });

  // Giờ theo đồng hồ 24 tiếng: `_hhmm` lấy thẳng `d.hour` (0–23) chứ không quy
  // về 12 giờ, và không có AM/PM nào được ghép vào.
  test('giờ hiển thị theo đồng hồ 24 tiếng', () {
    final source = File('lib/ec_app.dart').readAsStringSync();
    final start = source.indexOf('String _hhmm(DateTime d) {');
    expect(start, greaterThan(-1));
    final body = source.substring(start, start + 200);
    expect(body.contains('d.hour'), isTrue);
    expect(body.contains('AM'), isFalse);
    expect(body.contains('PM'), isFalse);
  });
}
