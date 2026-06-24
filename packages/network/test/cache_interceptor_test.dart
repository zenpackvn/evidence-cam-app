import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

/// Counts adapter hits and always returns a cacheable response carrying an
/// ETag and a Cache-Control max-age, so the cache interceptor stores and then
/// reuses it.
class _CountingAdapter implements HttpClientAdapter {
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    final body = utf8.encode(jsonEncode({'value': 'hello'}));
    return ResponseBody.fromBytes(
      Uint8List.fromList(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        'cache-control': ['max-age=60'],
        'etag': ['"v1"'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('serves a repeat GET from cache without hitting the network', () async {
    final adapter = _CountingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(cacheInterceptor());

    final first = await dio.get<Map<String, dynamic>>('/thing');
    final second = await dio.get<Map<String, dynamic>>('/thing');

    expect(first.data, {'value': 'hello'});
    expect(second.data, {'value': 'hello'});
    // Second read came from the in-memory cache, not the adapter.
    expect(adapter.calls, 1);
  });
}
