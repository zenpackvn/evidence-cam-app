import 'dart:io';
import 'dart:typed_data';

import 'package:ec_data/ec_data.dart';
import 'package:evidence_cam/data/ec_uploader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart'
    show Dio, Headers, HttpClientAdapter, RequestOptions, ResponseBody;

/// Canned Dio adapter: records each request and returns a scripted body.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.onFetch);
  final ResponseBody Function(RequestOptions) onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => onFetch(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(String body) => ResponseBody.fromString(
  body,
  200,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

void main() {
  test('ApiEvidenceUploader runs findOrCreate -> presign -> PUT -> complete', () async {
    final calls = <String>[];
    final apiDio = Dio()
      ..httpClientAdapter = _StubAdapter((o) {
        calls.add('${o.method} ${o.path}');
        if (o.path.endsWith('/uploads/presign')) {
          return _json(
            '{"evidenceId":"ev1","key":"r2/ev1.mp4",'
            '"uploadUrl":"https://r2.example/put?sig=1"}',
          );
        }
        if (o.path.endsWith('/complete')) return _json('{"status":"stored"}');
        // findOrCreateOrder
        return _json('{"id":"ord1","tracking_raw":"SPX1","created_at":0}');
      });
    final r2Dio = Dio()
      ..httpClientAdapter = _StubAdapter((o) {
        calls.add('PUT r2');
        return ResponseBody.fromString('', 200);
      });

    final dir = Directory.systemTemp.createTempSync('ec_uploader');
    addTearDown(() => dir.deleteSync(recursive: true));
    final clip = File('${dir.path}/clip.mp4')..writeAsStringSync('video-bytes');

    final uploader = ApiEvidenceUploader(EcApi(apiDio), r2Dio: r2Dio);
    final key = await uploader.upload(
      clip,
      tracking: 'SPX1',
      type: 'Đóng hàng',
      shopId: 's1',
    );

    expect(key, 'r2/ev1.mp4');
    expect(calls, [
      'POST /api/shops/s1/orders',
      'POST /api/shops/s1/orders/ord1/uploads/presign',
      'PUT r2',
      'POST /api/shops/s1/orders/ord1/uploads/ev1/complete',
    ]);
  });

  test('ApiEvidenceUploader throws without a shopId', () async {
    final dir = Directory.systemTemp.createTempSync('ec_uploader');
    addTearDown(() => dir.deleteSync(recursive: true));
    final clip = File('${dir.path}/c.mp4')..writeAsStringSync('x');

    final uploader = ApiEvidenceUploader(EcApi(Dio()));
    expect(
      () => uploader.upload(clip, tracking: 'X', type: 'Y'),
      throwsStateError,
    );
  });
}
