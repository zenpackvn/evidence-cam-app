import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Hướng màn hình khai trong `Info.plist` — hai nền, hai luật khác nhau.
///
/// iPhone chỉ portrait: toàn bộ thiết kế của app dựng theo chiều dọc.
///
/// iPad thì PHẢI khai đủ bốn. Đó không phải sơ suất mà là commit `758a8881`
/// làm có chủ đích: iPadOS đòi đủ bốn hướng thì mới cho app tham gia Split
/// View / Slide Over, và thiếu nó là một mục Apple bắt sửa khi duyệt.
///
/// Cái giữ cho giao diện đứng dọc không phải bản khai này mà là
/// `SystemChrome.setPreferredOrientations` trong `lib/main.dart` — riêng màn
/// quay tự gỡ khoá để khung hình theo được cách người dùng cầm máy. Nên siết
/// bản khai iPad về portrait là vừa gãy đa nhiệm vừa chẳng thêm được gì.
///
/// Bản trước của test này đòi iPad cũng chỉ portrait, nên nó đỏ kể từ
/// `758a8881` — mã đi đúng hướng, test đứng yên. Nằm im được vì bộ test gốc
/// lúc đó đã có 43 đỏ thường trực (C-03).
void main() {
  test('iPhone chỉ dọc, iPad khai đủ bốn hướng cho đa nhiệm', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    expect(
      _plistArray(plist, 'UISupportedInterfaceOrientations'),
      ['UIInterfaceOrientationPortrait'],
    );
    expect(_plistArray(plist, 'UISupportedInterfaceOrientations~ipad'), [
      'UIInterfaceOrientationPortrait',
      'UIInterfaceOrientationPortraitUpsideDown',
      'UIInterfaceOrientationLandscapeLeft',
      'UIInterfaceOrientationLandscapeRight',
    ]);
  });
}

List<String> _plistArray(String plist, String key) {
  final match = RegExp(
    '<key>${RegExp.escape(key)}</key>\\s*<array>(.*?)</array>',
    dotAll: true,
  ).firstMatch(plist);
  if (match == null) return const [];

  return RegExp(
    '<string>(.*?)</string>',
  ).allMatches(match.group(1)!).map((m) => m.group(1)!).toList();
}
