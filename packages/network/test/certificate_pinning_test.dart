import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

void main() {
  group('applyCertificatePinning', () {
    test('is a no-op when no pins are configured', () {
      final dio = Dio();
      final adapter = IOHttpClientAdapter();
      dio.httpClientAdapter = adapter;

      applyCertificatePinning(dio, const []);

      // Adapter hooks remain untouched, so OS validation stays in force.
      expect(adapter.validateCertificate, isNull);
      expect(adapter.createHttpClient, isNull);
    });

    test('installs the validation hooks when pins are configured', () {
      final dio = Dio();
      final adapter = IOHttpClientAdapter();
      dio.httpClientAdapter = adapter;

      applyCertificatePinning(dio, const ['deadbeef']);

      expect(adapter.validateCertificate, isNotNull);
      expect(adapter.createHttpClient, isNotNull);
    });
  });
}
