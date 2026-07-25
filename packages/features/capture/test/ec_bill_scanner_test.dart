import 'dart:io';

import 'package:app_platform/app_platform.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('requests the MLKit-friendly image format per platform', () {
    // NV21 on Android, BGRA8888 elsewhere (iOS + the test host).
    final expected = Platform.isAndroid
        ? ImageFormatGroup.nv21
        : ImageFormatGroup.bgra8888;
    expect(BillScanner.imageFormatGroup, expected);
  });
}
