import 'dart:io';
import 'dart:typed_data';

import 'package:ec_data/ec_data.dart';
import 'package:evidence_cam/data/ec_uploader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart'
    show
        Dio,
        DioException,
        DioExceptionType,
        Headers,
        HttpClientAdapter,
        RequestOptions,
        Response,
        ResponseBody;

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
  test(
    'ApiEvidenceUploader runs findOrCreate -> presign -> PUT -> complete',
    () async {
      final calls = <String>[];
      final bodies = <String, Object?>{};
      final apiDio = Dio()
        ..httpClientAdapter = _StubAdapter((o) {
          calls.add('${o.method} ${o.path}');
          bodies[o.path] = o.data;
          if (o.path.endsWith('/video-types')) {
            return _json(
              '[{"id":"vt-pack","name":"Đóng hàng","is_default":1},'
              ' {"id":"vt-return","name":"Trả hàng","is_default":1}]',
            );
          }
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
      final clip = File('${dir.path}/clip.mp4')
        ..writeAsStringSync('video-bytes');

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
        'GET /api/shops/s1/video-types',
        'POST /api/shops/s1/orders/ord1/uploads/presign',
        'PUT r2',
        'POST /api/shops/s1/orders/ord1/uploads/ev1/complete',
      ]);
      expect(
        (bodies['/api/shops/s1/orders']! as Map<String, dynamic>)['capturedAt'],
        isA<int>(),
      );
      expect(
        (bodies['/api/shops/s1/orders/ord1/uploads/presign']!
            as Map<String, dynamic>)['videoTypeId'],
        'vt-pack',
      );
    },
  );

  test(
    'ApiEvidenceUploader uploads attachment photos as photo evidence',
    () async {
      final calls = <String>[];
      final bodies = <String, Object?>{};
      final r2Headers = <String, Object?>{};
      final apiDio = Dio()
        ..httpClientAdapter = _StubAdapter((o) {
          calls.add('${o.method} ${o.path}');
          bodies[o.path] = o.data;
          if (o.path.endsWith('/uploads/presign')) {
            return _json(
              '{"evidenceId":"ev-photo","key":"r2/ev-photo.jpg",'
              '"uploadUrl":"https://r2.example/photo?sig=1"}',
            );
          }
          if (o.path.endsWith('/complete')) return _json('{"status":"stored"}');
          return _json('{"id":"ord1","tracking_raw":"SPX1","created_at":0}');
        });
      final r2Dio = Dio()
        ..httpClientAdapter = _StubAdapter((o) {
          calls.add('PUT r2');
          r2Headers.addAll(o.headers);
          return ResponseBody.fromString('', 200);
        });

      final dir = Directory.systemTemp.createTempSync('ec_uploader_photo');
      addTearDown(() => dir.deleteSync(recursive: true));
      final photo = File('${dir.path}/proof.jpg')
        ..writeAsStringSync('jpeg-bytes');

      final uploader = ApiEvidenceUploader(EcApi(apiDio), r2Dio: r2Dio);
      final key = await uploader.upload(
        photo,
        tracking: 'SPX1',
        type: 'Ảnh đính kèm',
        shopId: 's1',
      );

      expect(key, 'r2/ev-photo.jpg');
      expect(calls, [
        'POST /api/shops/s1/orders',
        'POST /api/shops/s1/orders/ord1/uploads/presign',
        'PUT r2',
        'POST /api/shops/s1/orders/ord1/uploads/ev-photo/complete',
      ]);
      final presign =
          bodies['/api/shops/s1/orders/ord1/uploads/presign']!
              as Map<String, dynamic>;
      expect(presign['kind'], 'photo');
      expect(presign.containsKey('videoTypeId'), isFalse);
      expect(r2Headers[Headers.contentTypeHeader], 'image/jpeg');
    },
  );

  test('ApiEvidenceUploader uses multipart upload for larger clips', () async {
    final calls = <String>[];
    final bodies = <String, Object?>{};
    final apiDio = Dio()
      ..httpClientAdapter = _StubAdapter((o) {
        calls.add('${o.method} ${o.path}');
        bodies[o.path] = o.data;
        if (o.path.endsWith('/video-types')) {
          return _json('[{"id":"vt-pack","name":"Đóng hàng","is_default":1}]');
        }
        if (o.path.endsWith('/uploads/multipart')) {
          return _json(
            '{"evidenceId":"evm","key":"r2/evm.mp4","uploadId":"up1"}',
          );
        }
        if (o.path.endsWith('/multipart/parts')) {
          return _json(
            '{"parts":['
            '{"partNumber":1,"uploadUrl":"https://r2.example/p1"},'
            '{"partNumber":2,"uploadUrl":"https://r2.example/p2"},'
            '{"partNumber":3,"uploadUrl":"https://r2.example/p3"}'
            ']}',
          );
        }
        if (o.path.endsWith('/multipart/complete')) {
          return _json('{"status":"done"}');
        }
        return _json('{"id":"ord1","tracking_raw":"SPX1","created_at":0}');
      });
    final r2Dio = Dio()
      ..httpClientAdapter = _StubAdapter((o) {
        calls.add('PUT ${o.uri}');
        return ResponseBody.fromString(
          '',
          200,
          headers: {
            'etag': ['etag-${o.uri.pathSegments.last}'],
          },
        );
      });

    final dir = Directory.systemTemp.createTempSync('ec_uploader_multipart');
    addTearDown(() => dir.deleteSync(recursive: true));
    final clip = File('${dir.path}/clip.mp4')
      ..writeAsBytesSync(List<int>.generate(11, (i) => i));

    final uploader = ApiEvidenceUploader(
      EcApi(apiDio),
      r2Dio: r2Dio,
      multipartThresholdBytes: 10,
      multipartPartSizeBytes: 4,
    );

    final key = await uploader.upload(
      clip,
      tracking: 'SPX1',
      type: 'Đóng hàng',
      shopId: 's1',
      capturedAt: 123,
    );

    expect(key, 'r2/evm.mp4');
    expect(calls, [
      'POST /api/shops/s1/orders',
      'GET /api/shops/s1/video-types',
      'POST /api/shops/s1/orders/ord1/uploads/multipart',
      'POST /api/shops/s1/orders/ord1/uploads/evm/multipart/parts',
      'PUT https://r2.example/p1',
      'PUT https://r2.example/p2',
      'PUT https://r2.example/p3',
      'POST /api/shops/s1/orders/ord1/uploads/evm/multipart/complete',
    ]);
    expect(
      bodies['/api/shops/s1/orders/ord1/uploads/evm/multipart/parts'],
      {
        'uploadId': 'up1',
        'partNumbers': [1, 2, 3],
      },
    );
    expect(
      bodies['/api/shops/s1/orders/ord1/uploads/evm/multipart/complete'],
      {
        'uploadId': 'up1',
        'parts': [
          {'partNumber': 1, 'etag': 'etag-p1'},
          {'partNumber': 2, 'etag': 'etag-p2'},
          {'partNumber': 3, 'etag': 'etag-p3'},
        ],
      },
    );
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

  test(
    'ApiEvidenceUploader surfaces quota_hold as a quota wait failure',
    () async {
      final apiDio = Dio()
        ..httpClientAdapter = _StubAdapter((o) {
          if (o.path.endsWith('/uploads/presign')) {
            return _json(
              '{"evidenceId":"ev1","key":"r2/ev1.mp4",'
              '"uploadUrl":"https://r2.example/put?sig=1"}',
            );
          }
          if (o.path.endsWith('/complete')) {
            return _json('{"status":"quota_hold"}');
          }
          return _json('{"id":"ord1","tracking_raw":"SPX1","created_at":0}');
        });
      final r2Dio = Dio()
        ..httpClientAdapter = _StubAdapter((_) {
          return ResponseBody.fromString('', 200);
        });
      final dir = Directory.systemTemp.createTempSync('ec_uploader_quota');
      addTearDown(() => dir.deleteSync(recursive: true));
      final clip = File('${dir.path}/clip.mp4')..writeAsStringSync('video');

      final uploader = ApiEvidenceUploader(EcApi(apiDio), r2Dio: r2Dio);

      expect(
        () => uploader.upload(
          clip,
          tracking: 'SPX1',
          type: 'Đóng hàng',
          shopId: 's1',
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'quota_exceeded',
          ),
        ),
      );
    },
  );

  test(
    'ApiEvidenceUploader retries a transient R2 PUT failure and succeeds',
    () async {
      final apiDio = Dio()
        ..httpClientAdapter = _StubAdapter((o) {
          if (o.path.endsWith('/uploads/presign')) {
            return _json(
              '{"evidenceId":"ev1","key":"r2/ev1.mp4",'
              '"uploadUrl":"https://r2.example/put?sig=1"}',
            );
          }
          if (o.path.endsWith('/complete')) return _json('{"status":"stored"}');
          return _json('{"id":"ord1","tracking_raw":"SPX1","created_at":0}');
        });
      var putAttempts = 0;
      final r2Dio = Dio()
        ..httpClientAdapter = _StubAdapter((o) {
          putAttempts++;
          // First attempt drops mid-request (dead wifi handoff, etc.) — the
          // regression this guards: before the fix, one blip failed the
          // whole clip instead of retrying.
          if (putAttempts == 1) {
            throw DioException(
              requestOptions: o,
              type: DioExceptionType.connectionError,
            );
          }
          return ResponseBody.fromString('', 200);
        });

      final dir = Directory.systemTemp.createTempSync('ec_uploader_retry');
      addTearDown(() => dir.deleteSync(recursive: true));
      final clip = File('${dir.path}/clip.mp4')
        ..writeAsStringSync('video-bytes');

      final uploader = ApiEvidenceUploader(EcApi(apiDio), r2Dio: r2Dio);
      final key = await uploader.upload(
        clip,
        tracking: 'SPX1',
        type: 'Đóng hàng',
        shopId: 's1',
      );

      expect(key, 'r2/ev1.mp4');
      expect(putAttempts, 2);
    },
  );

  test(
    'ApiEvidenceUploader does not retry a non-transient R2 rejection',
    () async {
      final apiDio = Dio()
        ..httpClientAdapter = _StubAdapter((o) {
          if (o.path.endsWith('/uploads/presign')) {
            return _json(
              '{"evidenceId":"ev1","key":"r2/ev1.mp4",'
              '"uploadUrl":"https://r2.example/put?sig=1"}',
            );
          }
          return _json('{"id":"ord1","tracking_raw":"SPX1","created_at":0}');
        });
      var putAttempts = 0;
      final r2Dio = Dio()
        ..httpClientAdapter = _StubAdapter((o) {
          putAttempts++;
          // Expired/invalid signature — retrying identically can never
          // succeed, so it should fail fast instead of burning 4 attempts.
          throw DioException(
            requestOptions: o,
            type: DioExceptionType.badResponse,
            response: Response<void>(requestOptions: o, statusCode: 403),
          );
        });

      final dir = Directory.systemTemp.createTempSync(
        'ec_uploader_no_retry',
      );
      addTearDown(() => dir.deleteSync(recursive: true));
      final clip = File('${dir.path}/clip.mp4')
        ..writeAsStringSync('video-bytes');

      final uploader = ApiEvidenceUploader(EcApi(apiDio), r2Dio: r2Dio);

      await expectLater(
        uploader.upload(
          clip,
          tracking: 'SPX1',
          type: 'Đóng hàng',
          shopId: 's1',
        ),
        throwsA(isA<DioException>()),
      );
      expect(putAttempts, 1);
    },
  );

  test(
    'ApiEvidenceUploader retries a single multipart part without redoing '
    'the others',
    () async {
      final apiDio = Dio()
        ..httpClientAdapter = _StubAdapter((o) {
          if (o.path.endsWith('/uploads/multipart')) {
            return _json(
              '{"evidenceId":"evm","key":"r2/evm.mp4","uploadId":"up1"}',
            );
          }
          if (o.path.endsWith('/multipart/parts')) {
            return _json(
              '{"parts":['
              '{"partNumber":1,"uploadUrl":"https://r2.example/p1"},'
              '{"partNumber":2,"uploadUrl":"https://r2.example/p2"}'
              ']}',
            );
          }
          if (o.path.endsWith('/multipart/complete')) {
            return _json('{"status":"done"}');
          }
          return _json('{"id":"ord1","tracking_raw":"SPX1","created_at":0}');
        });
      final partAttempts = <String, int>{};
      final r2Dio = Dio()
        ..httpClientAdapter = _StubAdapter((o) {
          final part = o.uri.pathSegments.last;
          final attempt = (partAttempts[part] ?? 0) + 1;
          partAttempts[part] = attempt;
          // Only part 2's first attempt fails — part 1 must not be re-sent.
          if (part == 'p2' && attempt == 1) {
            throw DioException(
              requestOptions: o,
              type: DioExceptionType.sendTimeout,
            );
          }
          return ResponseBody.fromString(
            '',
            200,
            headers: {
              'etag': ['etag-$part'],
            },
          );
        });

      final dir = Directory.systemTemp.createTempSync(
        'ec_uploader_multipart_retry',
      );
      addTearDown(() => dir.deleteSync(recursive: true));
      final clip = File('${dir.path}/clip.mp4')
        ..writeAsBytesSync(List<int>.generate(8, (i) => i));

      final uploader = ApiEvidenceUploader(
        EcApi(apiDio),
        r2Dio: r2Dio,
        multipartThresholdBytes: 6,
        multipartPartSizeBytes: 4,
      );

      final key = await uploader.upload(
        clip,
        tracking: 'SPX1',
        type: 'Đóng hàng',
        shopId: 's1',
        capturedAt: 123,
      );

      expect(key, 'r2/evm.mp4');
      expect(partAttempts, {'p1': 1, 'p2': 2});
    },
  );
}
