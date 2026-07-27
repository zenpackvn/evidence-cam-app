import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS app supports portrait orientation only', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    expect(
      _plistArray(plist, 'UISupportedInterfaceOrientations'),
      ['UIInterfaceOrientationPortrait'],
    );
    expect(
      _plistArray(plist, 'UISupportedInterfaceOrientations~ipad'),
      ['UIInterfaceOrientationPortrait'],
    );
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
