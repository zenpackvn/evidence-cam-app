import 'dart:io';

import 'package:feature_capture/feature_capture.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dấu đóng vào clip hỏng theo kiểu KHÔNG ai thấy: `stamp` fail-safe nên lệnh
/// ffmpeg sai chỉ làm file tải về mất chữ, không mất file. Đã có hai lần hỏng
/// đúng kiểu đó (lề ghi thành `24.0`, và dấu nháy bị FFmpegKit bóc mất làm dấu
/// phẩy trong biểu thức biến thành dấu ngăn bộ lọc), nên những gì đưa cho
/// ffmpeg phải được kiểm ở đây chứ không phải trên máy người dùng.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late List<String> commands;
  late List<String> graphs;
  late EcVideoStampService service;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('stamp_test');
    commands = [];
    graphs = [];
    service = EcVideoStampService(
      outputDirectory: dir,
      runner: (command) async {
        commands.add(command);
        // Đọc filtergraph NGAY tại đây: `stamp` dọn file tạm trong `finally`,
        // xong lệnh là nó không còn nữa.
        final graph = RegExp(
          r'-filter_complex_script "([^"]+)"',
        ).firstMatch(command);
        if (graph != null) {
          graphs.add(File(graph.group(1)!).readAsStringSync());
        }
        // Giả lập ffmpeg chạy xong: `stamp` chỉ trả về bản mới khi file có
        // thật, nên phải tạo ra nó.
        final match = RegExp(r'"([^"]*evidence_stamped_[^"]*)"').firstMatch(
          command,
        );
        if (match != null) File(match.group(1)!).writeAsStringSync('x');
        return true;
      },
    );
  });

  tearDown(() => dir.deleteSync(recursive: true));

  File input() => File('${dir.path}/in.mp4')..writeAsStringSync('video');

  test('đóng dấu tĩnh khi không biết thời lượng', () async {
    final out = await service.stamp(input().path, lines: ['04/08/2026', 'A1']);

    expect(out, isNot(input().path));
    // Một ô duy nhất: chỉ số luôn kẹp về 0 nên đồng hồ đứng im.
    expect(graphs.single, contains('min(floor(t),0)'));
  });

  test('vẽ một ô cho mỗi giây và cắt theo thời gian', () async {
    await service.stamp(
      input().path,
      lines: ['04/08/2026', '14:23:07', 'SPXVN024567890'],
      clockStart: DateTime(2026, 8, 4, 14, 23, 7),
      clockSeconds: 5,
      clockLine: 1,
    );

    final graph = graphs.single;
    // Ô cuối là chỉ số 4 — kẹp ở đó thay vì cắt ra ngoài ảnh khi clip lố nhịp.
    expect(graph, contains('min(floor(t),4)'));
    expect(graph, contains('crop='));
    expect(graph, contains('overlay=24:24'));
    // Không có `shortest=1` thì ffmpeg encode vô tận: ảnh dấu `-loop 1` là
    // luồng vô hạn và `-shortest` trên dòng lệnh không chặn được luồng đi qua
    // `filter_complex`. Đo thật: clip vào 5 giây → 41 phút hình sau 20 giây
    // chạy, và vẫn chưa dừng.
    expect(graph, contains('shortest=1'));
    // Lề phải là số nguyên: `overlay=24.0:24.0` bị ffmpeg từ chối, và vì
    // fail-safe nên hỏng đó không nổi lên ở đâu cả.
    expect(graph, isNot(contains('.0')));
  });

  test('ảnh dấu và filtergraph nạp từ file, không nằm trên dòng lệnh', () async {
    await service.stamp(
      input().path,
      lines: ['04/08/2026', '14:23:07', 'A1'],
      clockStart: DateTime(2026, 8, 4, 14, 23, 7),
      clockSeconds: 3,
    );

    final command = commands.single;
    // Dấu phẩy của biểu thức không được xuất hiện trên dòng lệnh — đó chính là
    // thứ ffmpeg đọc nhầm thành dấu ngăn giữa hai bộ lọc.
    expect(command, isNot(contains('crop=')));
    expect(command, contains('-filter_complex_script'));
    // Ảnh tĩnh phải được lặp thành luồng, không thì `t` không chạy và đồng hồ
    // đứng im dù đã vẽ đủ ô.
    expect(command, contains('-loop 1'));
    // Bộ mã hoá phải là thứ có thật trong bản ffmpeg app đóng gói (`base`,
    // không GPL). `libx264` không nằm trong đó — gọi nó là hỏng cả lượt đóng
    // dấu trên máy thật, mà fail-safe lại giấu mất lỗi.
    expect(command, isNot(contains('-c:v libx264')));
  });

  test('giữ nguyên bản gốc khi ffmpeg hỏng', () async {
    final failing = EcVideoStampService(
      outputDirectory: dir,
      runner: (_) async => false,
    );

    final path = input().path;
    expect(await failing.stamp(path, lines: ['A1']), path);
  });

  test('không đụng gì khi thiếu chữ hoặc thiếu file', () async {
    expect(await service.stamp(input().path, lines: []), input().path);
    expect(commands, isEmpty);
  });
}
