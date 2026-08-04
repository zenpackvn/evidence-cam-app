import 'package:ec_data/ec_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('đọc đủ trường của một lần thanh toán web', () {
    final p = PaymentDto.fromJson(const {
      'id': '900001',
      'source': 'payos',
      'plan_code': 'basic',
      'term': '6m',
      'days': 180,
      'amount': 819000,
      'status': 'paid',
      'created_at': 1700000000000,
      'paid_at': 1700000060000,
      'sandbox': false,
    });

    expect(p.id, '900001');
    expect(p.source, 'payos');
    expect(p.term, '6m');
    expect(p.amount, 819000);
    expect(p.status, 'paid');
    expect(p.paidAt, 1700000060000);
    expect(p.sandbox, isFalse);
  });

  // Mua trong ứng dụng không có giá: App Store giữ điểm giá theo từng SKU.
  // Đổi null thành 0 ở tầng này là biến "không biết" thành "miễn phí".
  test('giữ nguyên amount null thay vì rơi về 0', () {
    final p = PaymentDto.fromJson(const {
      'id': 'tx-1',
      'source': 'appstore',
      'plan_code': 'premium',
      'term': null,
      'days': 30,
      'amount': null,
      'status': 'paid',
      'created_at': 1700000000000,
      'paid_at': 1700000000000,
      'sandbox': true,
    });

    expect(p.amount, isNull);
    expect(p.term, isNull);
    expect(p.days, 30);
    expect(p.sandbox, isTrue);
  });

  // Backend cũ hoặc phản hồi lạ không được làm sập màn hình lịch sử.
  test('thiếu trường thì rơi về mặc định an toàn, không ném', () {
    final p = PaymentDto.fromJson(const {'id': 'x'});

    expect(p.id, 'x');
    expect(p.source, 'payos');
    expect(p.status, 'pending');
    expect(p.amount, isNull);
    expect(p.sandbox, isFalse);
  });
}
