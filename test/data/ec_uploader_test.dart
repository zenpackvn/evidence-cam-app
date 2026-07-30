import 'dart:io';
import 'dart:typed_data';

import 'package:ec_data/ec_data.dart';
import 'package:evidence_cam/data/ec_uploader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart'
    show Dio, Headers, HttpClientAdapter, RequestOptions, ResponseBody;

/// Canned Dio adapter: records each request and returns a scripted body. Only
/// the EC API leg still goes through Dio — the R2 leg is a [_FakeR2].
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

/// One recorded PUT to R2.
typedef _PutCall = ({String url, String contentType, R2ByteRange? range});

/// Stands in for the `background_downloader` transport so the upload flow is
/// testable without a platform channel. [onPut] returns the ETag to report, or
/// throws an [R2PutException] to simulate a rejected/dropped PUT.
class _FakeR2 {
  _FakeR2(this.onPut);

  final String? Function(_PutCall call) onPut;
  final List<_PutCall> calls = [];

  Future<String?> put(
    String url,
    File file, {
    required String contentType,
    R2ByteRange? range,
    void Function(double progress)? onProgress,
  }) async {
    final call = (url: url, contentType: contentType, range: range);
    calls.add(call);
    return onPut(call);
  }
}

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
      final r2 = _FakeR2((_) {
        calls.add('PUT r2');
        return 'etag-whole';
      });

      final dir = Directory.systemTemp.createTempSync('ec_uploader');
      addTearDown(() => dir.deleteSync(recursive: true));
      final clip = File('${dir.path}/clip.mp4')
        ..writeAsStringSync('video-bytes');

      final uploader = ApiEvidenceUploader(EcApi(apiDio), put: r2.put);
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
      // A whole-file PUT must not be sliced.
      expect(r2.calls.single.url, 'https://r2.example/put?sig=1');
      expect(r2.calls.single.range, isNull);
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
      final r2 = _FakeR2((_) {
        calls.add('PUT r2');
        return 'etag-photo';
      });

      final dir = Directory.systemTemp.createTempSync('ec_uploader_photo');
      addTearDown(() => dir.deleteSync(recursive: true));
      final photo = File('${dir.path}/proof.jpg')
        ..writeAsStringSync('jpeg-bytes');

      final uploader = ApiEvidenceUploader(EcApi(apiDio), put: r2.put);
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
      expect(r2.calls.single.contentType, 'image/jpeg');
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
          final partNumber =
              ((o.data! as Map<String, dynamic>)['partNumbers']
                      as List<dynamic>)
                  .single;
          return _json(
            '{"parts":['
            '{"partNumber":$partNumber,'
            '"uploadUrl":"https://r2.example/p$partNumber"}'
            ']}',
          );
        }
        if (o.path.endsWith('/multipart/complete')) {
          return _json('{"status":"done"}');
        }
        return _json('{"id":"ord1","tracking_raw":"SPX1","created_at":0}');
      });
    final r2 = _FakeR2((call) {
      calls.add('PUT ${call.url}');
      return 'etag-${Uri.parse(call.url).pathSegments.last}';
    });

    final dir = Directory.systemTemp.createTempSync('ec_uploader_multipart');
    addTearDown(() => dir.deleteSync(recursive: true));
    final clip = File('${dir.path}/clip.mp4')
      ..writeAsBytesSync(List<int>.generate(11, (i) => i));

    final uploader = ApiEvidenceUploader(
      EcApi(apiDio),
      put: r2.put,
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
      'POST /api/shops/s1/orders/ord1/uploads/evm/multipart/parts',
      'PUT https://r2.example/p2',
      'POST /api/shops/s1/orders/ord1/uploads/evm/multipart/parts',
      'PUT https://r2.example/p3',
      'POST /api/shops/s1/orders/ord1/uploads/evm/multipart/complete',
    ]);
    // The parts must together cover all 11 bytes exactly once, with no gap or
    // overlap — the transport slices by end-inclusive Range now rather than by
    // an end-exclusive byte stream, so an off-by-one here would silently
    // corrupt or truncate the assembled clip.
    expect(r2.calls.map((c) => c.range).toList(), [
      (start: 0, endInclusive: 3),
      (start: 4, endInclusive: 7),
      (start: 8, endInclusive: 10),
    ]);
    // Each part is signed individually, right before its own PUT — proves
    // the fix: no single upfront call carries every part number.
    expect(
      bodies['/api/shops/s1/orders/ord1/uploads/evm/multipart/parts'],
      {
        'uploadId': 'up1',
        'partNumbers': [3],
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

    final uploader = ApiEvidenceUploader(
      EcApi(Dio()),
      put: _FakeR2((_) => 'unused').put,
    );
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
      final dir = Directory.systemTemp.createTempSync('ec_uploader_quota');
      addTearDown(() => dir.deleteSync(recursive: true));
      final clip = File('${dir.path}/clip.mp4')..writeAsStringSync('video');

      final uploader = ApiEvidenceUploader(
        EcApi(apiDio),
        put: _FakeR2((_) => 'etag-1').put,
      );

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
      final r2 = _FakeR2((_) {
        putAttempts++;
        // First attempt drops mid-request (dead wifi handoff, etc.) — no HTTP
        // status at all. The regression this guards: before the fix, one blip
        // failed the whole clip instead of retrying.
        if (putAttempts == 1) throw R2PutException('connection closed');
        return 'etag-1';
      });

      final dir = Directory.systemTemp.createTempSync('ec_uploader_retry');
      addTearDown(() => dir.deleteSync(recursive: true));
      final clip = File('${dir.path}/clip.mp4')
        ..writeAsStringSync('video-bytes');

      final uploader = ApiEvidenceUploader(EcApi(apiDio), put: r2.put);
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
      final r2 = _FakeR2((_) {
        putAttempts++;
        // Expired/invalid signature — retrying identically can never
        // succeed, so it should fail fast instead of burning 4 attempts.
        throw R2PutException('SignatureDoesNotMatch', statusCode: 403);
      });

      final dir = Directory.systemTemp.createTempSync('ec_uploader_no_retry');
      addTearDown(() => dir.deleteSync(recursive: true));
      final clip = File('${dir.path}/clip.mp4')
        ..writeAsStringSync('video-bytes');

      final uploader = ApiEvidenceUploader(EcApi(apiDio), put: r2.put);

      // upload() rewraps every DioException and R2PutException into an
      // UploadFailureException with a message already safe to show a seller —
      // see ec_uploader.dart.
      await expectLater(
        uploader.upload(
          clip,
          tracking: 'SPX1',
          type: 'Đóng hàng',
          shopId: 's1',
        ),
        throwsA(isA<UploadFailureException>()),
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
            final partNumber =
                ((o.data! as Map<String, dynamic>)['partNumbers']
                        as List<dynamic>)
                    .single;
            return _json(
              '{"parts":['
              '{"partNumber":$partNumber,'
              '"uploadUrl":"https://r2.example/p$partNumber"}'
              ']}',
            );
          }
          if (o.path.endsWith('/multipart/complete')) {
            return _json('{"status":"done"}');
          }
          return _json('{"id":"ord1","tracking_raw":"SPX1","created_at":0}');
        });
      final partAttempts = <String, int>{};
      final r2 = _FakeR2((call) {
        final part = Uri.parse(call.url).pathSegments.last;
        final attempt = (partAttempts[part] ?? 0) + 1;
        partAttempts[part] = attempt;
        // Only part 2's first attempt fails — part 1 must not be re-sent.
        if (part == 'p2' && attempt == 1) {
          throw R2PutException('send timeout');
        }
        return 'etag-$part';
      });

      final dir = Directory.systemTemp.createTempSync(
        'ec_uploader_multipart_retry',
      );
      addTearDown(() => dir.deleteSync(recursive: true));
      final clip = File('${dir.path}/clip.mp4')
        ..writeAsBytesSync(List<int>.generate(8, (i) => i));

      final uploader = ApiEvidenceUploader(
        EcApi(apiDio),
        put: r2.put,
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
