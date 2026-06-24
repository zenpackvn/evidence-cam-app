import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

/// Records the Idempotency-Key header seen on each request and echoes 200.
class _RecordingAdapter implements HttpClientAdapter {
  final List<String?> keysSeen = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    keysSeen.add(options.headers[IdempotencyInterceptor.headerName] as String?);
    return ResponseBody.fromBytes(
      Uint8List.fromList(utf8.encode('{}')),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _RecordingAdapter adapter;
  late Dio dio;

  setUp(() {
    adapter = _RecordingAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(IdempotencyInterceptor());
  });

  test('adds an Idempotency-Key to POST', () async {
    await dio.post<dynamic>('/things', data: {'a': 1});

    expect(adapter.keysSeen.single, isNotNull);
    expect(adapter.keysSeen.single, hasLength(32)); // 16 bytes hex
  });

  test('does not add a key to GET', () async {
    await dio.get<dynamic>('/things');

    expect(adapter.keysSeen.single, isNull);
  });

  test('gives distinct keys to distinct POSTs', () async {
    await dio.post<dynamic>('/things', data: {'a': 1});
    await dio.post<dynamic>('/things', data: {'a': 2});

    expect(adapter.keysSeen[0], isNot(adapter.keysSeen[1]));
  });

  test('reuses the key when the same request options are re-sent', () async {
    // Simulate a retry: re-fetch the SAME RequestOptions instance, as the
    // retry interceptor does via dio.fetch(options).
    final options = RequestOptions(path: '/things', method: 'POST');
    await dio.fetch<dynamic>(options);
    await dio.fetch<dynamic>(options);

    expect(adapter.keysSeen[0], isNotNull);
    expect(adapter.keysSeen[0], adapter.keysSeen[1]);
  });
}
