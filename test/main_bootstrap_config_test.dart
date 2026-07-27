import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('main bootstrap passes auth into the API repository', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains('repo: buildRepository(auth: ecAuth),'));
  });
}
