// Nút "Tải bằng chứng" trong hồ sơ khiếu nại phải có ĐỦ chuỗi lùi như nút
// "Tải về máy" ở màn chi tiết bằng chứng.
//
// Trang hồ sơ chạy trong WebView và gọi ngược ra app qua kênh `EcSave`; app
// tải tệp rồi tìm chỗ giao nó cho người dùng. Đường đó từng là bản chép rút
// gọn của `_downloadAndShareVideo` và làm rơi mất hai bước lùi: không vào được
// thư viện máy là nhảy thẳng sang câu "tải thất bại" — trong khi tệp đã tải
// xong và đang nằm trong thư mục của app.
//
// Hậu quả: trên MỌI máy chưa cấp quyền thêm ảnh vào thư viện, nút này luôn
// đọc ra "lỗi". Đó là lỗi người bán báo.
//
// Quét mã nguồn chứ không dựng màn: đường này cần một WebView thật, một kênh
// JavaScript và quyền hệ thống — dựng đủ ngần ấy để kiểm ba nhánh rẽ là đắt
// hơn thứ nó bảo vệ, và vẫn không chạm được vào nhánh "người dùng từ chối
// quyền" nếu không có máy thật.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File('lib/ec_app.dart').readAsStringSync();
  });

  /// Thân hàm `_save` của `_ClaimPageScreenState` — cắt từ chữ ký tới hàm kế.
  String saveBody() {
    const start = 'Future<void> _save(BuildContext context, String payload)';
    final i = source.indexOf(start);
    expect(i, greaterThan(-1), reason: 'không tìm thấy _save của trang hồ sơ');
    final j = source.indexOf('_decodeSaveRequest(String payload)', i);
    expect(j, greaterThan(i), reason: 'không tìm thấy mốc kết thúc');
    return source.substring(i, j);
  }

  test('không vào được thư viện thì còn đường chia sẻ, không báo lỗi ngay', () {
    final body = saveBody();
    expect(
      body.contains('_maybeGetIt<ShareService>()'),
      isTrue,
      reason: 'mất bước lùi ra khay chia sẻ',
    );
    expect(
      body.contains('share.shareFiles('),
      isTrue,
      reason: 'có tra ShareService nhưng không dùng',
    );
  });

  test('không có cả khay chia sẻ thì chép đường dẫn tệp', () {
    final body = saveBody();
    expect(
      body.contains('Clipboard.setData'),
      isTrue,
      reason: 'mất bước lùi cuối — chép đường dẫn',
    );
    expect(body.contains('toastVideoDownloadedCopied'), isTrue);
  });

  // Câu "tải thất bại" chỉ được nói khi thật sự có gì đó NÉM. Nói nó ở nhánh
  // "quyền bị từ chối" là đổi một lượt tải thành công thành một lỗi.
  test('câu tải thất bại chỉ nằm ở nhánh bắt lỗi', () {
    final body = saveBody();
    final failAt = body.indexOf('toastVideoDownloadFailed');
    final catchAt = body.indexOf('} on Object {');
    expect(failAt, greaterThan(-1));
    expect(catchAt, greaterThan(-1));
    expect(
      failAt,
      greaterThan(catchAt),
      reason: 'còn một câu "tải thất bại" nằm ngoài nhánh bắt lỗi',
    );
  });
}
