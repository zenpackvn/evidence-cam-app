import 'package:ec_data/ec_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Không còn nguồn dữ liệu thay thế: URL rỗng là build sai cấu hình, phải nổ
  // ngay chứ không được chạy tiếp bằng dữ liệu bịa.
  test('no URL → throws instead of falling back to stand-in data', () {
    expect(() => buildRepository(url: ''), throwsStateError);
  });

  test('a URL → live remote repository', () {
    expect(
      buildRepository(url: 'https://api.example.workers.dev'),
      isA<RemoteEcRepository>(),
    );
  });
}
