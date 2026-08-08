import 'dart:io';

import 'package:feature_capture/feature_capture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late Directory source;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('ec_preview_test');
    source = Directory.systemTemp.createTempSync('ec_preview_src');
    debugPreviewDir = dir;
  });

  tearDown(() {
    debugPreviewDir = null;
    dir.deleteSync(recursive: true);
    if (source.existsSync()) source.deleteSync(recursive: true);
  });

  File clip(String name) =>
      File('${source.path}/$name')..writeAsStringSync('video-bytes');

  test('giữ bản tạm dưới tên evidence_id, và tìm lại được bằng id đó', () async {
    final file = clip('raw.mp4');

    await ecKeepPreview('ev-1', file.path);

    // Dời chứ không chép: bản cũ phải biến mất.
    expect(file.existsSync(), isFalse);
    final found = await ecPreviews();
    expect(found.keys, ['ev-1']);
    expect(File(found['ev-1']!).readAsStringSync(), 'video-bytes');
    // Phần mở rộng của clip gốc được giữ lại — trình phát cần nó để đoán codec.
    expect(found['ev-1'], endsWith('.mp4'));
  });

  test('không giữ gì khi thiếu evidence_id hoặc tệp đã biến mất', () async {
    await ecKeepPreview('', clip('a.mp4').path);
    await ecKeepPreview('ev-2', '${source.path}/khong-ton-tai.mp4');

    expect(await ecPreviews(), isEmpty);
  });

  test('xoá đúng bản của một evidence, không đụng bản khác', () async {
    await ecKeepPreview('ev-1', clip('a.mp4').path);
    await ecKeepPreview('ev-2', clip('b.mp4').path);

    await ecDropPreview('ev-1');

    expect((await ecPreviews()).keys, ['ev-2']);
  });

  test('quét theo tuổi chỉ dọn bản quá hạn', () async {
    await ecKeepPreview('cu', clip('a.mp4').path);
    await ecKeepPreview('moi', clip('b.mp4').path);
    // Đẩy lùi mốc sửa của bản "cũ" ra ngoài trần tuổi.
    File((await ecPreviews())['cu']!).setLastModifiedSync(
      DateTime.now().subtract(ecPreviewMaxAge * 2),
    );

    await ecSweepPreviews();

    expect((await ecPreviews()).keys, ['moi']);
  });
}
