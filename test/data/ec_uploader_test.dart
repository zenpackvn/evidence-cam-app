import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show sha256;
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

ResponseBody _json(String body, [int status = 200]) => ResponseBody.fromString(
  body,
  status,
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
  // Tệp vượt trần bị từ chối ở bước `complete`, tức là SAU khi byte đã lên
  // kho. Người bán phải đọc được việc cần làm, không phải "máy chủ báo lỗi
  // (mã 400) — thử lại sau": thử lại cùng một tệp thì mãi mãi cùng dung lượng.
  test('tệp vượt trần: báo đúng việc cần làm, không xui thử lại', () async {
    final apiDio = Dio()
      ..httpClientAdapter = _StubAdapter((o) {
        if (o.path.endsWith('/uploads/presign')) {
          return _json(
            '{"evidenceId":"ev1","key":"r2/ev1.mp4",'
            '"uploadUrl":"https://r2.example/put?sig=1"}',
          );
        }
        if (o.path.endsWith('/complete')) {
          return _json('{"error":"file_too_large"}', 400);
        }
        return _json('{"id":"ord1","tracking_raw":"SPX1","created_at":0}');
      });
    final r2 = _FakeR2((_) => 'etag-whole');

    final dir = Directory.systemTemp.createTempSync('ec_uploader_too_large');
    addTearDown(() => dir.deleteSync(recursive: true));
    final clip = File('${dir.path}/clip.mp4')..writeAsStringSync('video-bytes');

    final uploader = ApiEvidenceUploader(EcApi(apiDio), put: r2.put);
    await expectLater(
      uploader.upload(clip, tracking: 'SPX1', type: 'Đóng hàng', shopId: 's1'),
      throwsA(
        isA<UploadFailureException>()
            .having((e) => e.message, 'message', contains('quá nặng'))
            .having((e) => e.message, 'message', contains('vẫn còn'))
            .having(
              (e) => e.message,
              'message',
              isNot(contains('thử lại sau')),
            ),
      ),
    );
    // Bản trên máy KHÔNG được đụng tới — hàng lỗi còn trỏ vào đúng tệp này.
    expect(clip.existsSync(), isTrue);
  });

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
      final evidenceId = await uploader.upload(
        clip,
        tracking: 'SPX1',
        type: 'Đóng hàng',
        shopId: 's1',
      );

      // `upload` trả về EVIDENCE ID, không phải khoá R2 — đổi có chủ đích ngày
      // 08/08 (41d3bde3). Lý do nằm ở `ec_uploader.dart`: evidenceId là thứ duy
      // nhất khớp được clip trên máy với dòng bằng chứng của máy chủ, và hàng
      // đợi cần nó để đặt tên bản xem tạm. Khoá R2 không xuất hiện ở API nào
      // khác nên không đối chiếu được với gì cả.
      //
      // Bảy khẳng định trong file này còn chờ `'r2/….mp4'` cho tới 10/08, tức
      // là chúng đỏ suốt hai ngày mà không ai thấy — bộ test gốc lúc đó đã có
      // 43 đỏ thường trực nên một lỗi thật lẫn vào là mất tăm (C-03).
      expect(evidenceId, 'ev1');
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
      final evidenceId = await uploader.upload(
        photo,
        tracking: 'SPX1',
        type: 'Ảnh đính kèm',
        shopId: 's1',
      );

      expect(evidenceId, 'ev-photo');
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

    final evidenceId = await uploader.upload(
      clip,
      tracking: 'SPX1',
      type: 'Đóng hàng',
      shopId: 's1',
      capturedAt: 123,
    );

    expect(evidenceId, 'evm');
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
    final completeBody =
        bodies['/api/shops/s1/orders/ord1/uploads/evm/multipart/complete']!
            as Map<String, Object?>;
    expect(completeBody['uploadId'], 'up1');
    expect(completeBody['parts'], [
      {'partNumber': 1, 'etag': 'etag-p1'},
      {'partNumber': 2, 'etag': 'etag-p2'},
      {'partNumber': 3, 'etag': 'etag-p3'},
    ]);
    // The evidence fingerprint rides along on the same call — asserted by shape
    // rather than value so the clip's contents stay free to change.
    expect(completeBody['sha256'], matches(RegExp(r'^[0-9a-f]{64}$')));
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
      final evidenceId = await uploader.upload(
        clip,
        tracking: 'SPX1',
        type: 'Đóng hàng',
        shopId: 's1',
      );

      expect(evidenceId, 'ev1');
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

      final evidenceId = await uploader.upload(
        clip,
        tracking: 'SPX1',
        type: 'Đóng hàng',
        shopId: 's1',
        capturedAt: 123,
      );

      expect(evidenceId, 'evm');
      expect(partAttempts, {'p1': 1, 'p2': 2});
    },
  );

  group('poster frame', () {
    /// Backend that hands back a poster URL alongside the clip's own.
    Dio posterApi() => Dio()
      ..httpClientAdapter = _StubAdapter((o) {
        if (o.path.endsWith('/video-types')) return _json('[]');
        if (o.path.endsWith('/uploads/presign')) {
          return _json(
            '{"evidenceId":"ev1","key":"r2/ev1.mp4",'
            '"uploadUrl":"https://r2.example/clip?sig=1",'
            '"thumbUploadUrl":"https://r2.example/thumb?sig=2"}',
          );
        }
        if (o.path.endsWith('/complete')) return _json('{"status":"stored"}');
        return _json('{"id":"ord1","tracking_raw":"SPX1","created_at":0}');
      });

    (Directory, File) tempClip() {
      final dir = Directory.systemTemp.createTempSync('ec_uploader_poster');
      addTearDown(() => dir.deleteSync(recursive: true));
      return (
        dir,
        File('${dir.path}/clip.mp4')..writeAsStringSync('video-bytes'),
      );
    }

    test('uploads the poster before the clip it belongs to', () async {
      // Arrange
      final (dir, clip) = tempClip();
      final poster = File('${dir.path}/poster.jpg')..writeAsStringSync('jpeg');
      final r2 = _FakeR2((_) => 'etag');
      final uploader = ApiEvidenceUploader(
        EcApi(posterApi()),
        put: r2.put,
        extractThumbnail: (_) async => poster.path,
      );

      // Act
      await uploader.upload(
        clip,
        tracking: 'SPX1',
        type: 'Đóng hàng',
        shopId: 'shop1',
      );

      // Assert — poster first, so the timeline fills in while the clip climbs.
      expect(r2.calls.map((c) => c.url).toList(), [
        'https://r2.example/thumb?sig=2',
        'https://r2.example/clip?sig=1',
      ]);
      expect(r2.calls.first.contentType, 'image/jpeg');
      expect(poster.existsSync(), isFalse, reason: 'temp poster is cleaned up');
    });

    test('still uploads the clip when frame extraction fails', () async {
      // Arrange — the branch that must never cost evidence.
      final (_, clip) = tempClip();
      final r2 = _FakeR2((_) => 'etag');
      final uploader = ApiEvidenceUploader(
        EcApi(posterApi()),
        put: r2.put,
        extractThumbnail: (_) async => throw StateError('no frame'),
      );

      // Act
      final evidenceId = await uploader.upload(
        clip,
        tracking: 'SPX1',
        type: 'Đóng hàng',
        shopId: 'shop1',
      );

      // Assert
      expect(evidenceId, 'ev1');
      expect(r2.calls.map((c) => c.url).toList(), [
        'https://r2.example/clip?sig=1',
      ]);
    });

    test('still uploads the clip when the poster PUT is rejected', () async {
      // Arrange
      final (dir, clip) = tempClip();
      final poster = File('${dir.path}/poster.jpg')..writeAsStringSync('jpeg');
      final r2 = _FakeR2((call) {
        if (call.url.contains('thumb')) {
          throw R2PutException('nope', statusCode: 403);
        }
        return 'etag';
      });
      final uploader = ApiEvidenceUploader(
        EcApi(posterApi()),
        put: r2.put,
        extractThumbnail: (_) async => poster.path,
      );

      // Act
      final evidenceId = await uploader.upload(
        clip,
        tracking: 'SPX1',
        type: 'Đóng hàng',
        shopId: 'shop1',
      );

      // Assert
      expect(evidenceId, 'ev1');
      expect(r2.calls.length, 2);
    });

    test(
      'sends the clip fingerprint on the single-PUT complete call',
      () async {
        // Arrange
        final (_, clip) = tempClip();
        final bodies = <String, Object?>{};
        final apiDio = Dio()
          ..httpClientAdapter = _StubAdapter((o) {
            bodies[o.path] = o.data;
            if (o.path.endsWith('/video-types')) return _json('[]');
            if (o.path.endsWith('/uploads/presign')) {
              return _json(
                '{"evidenceId":"ev1","key":"r2/ev1.mp4",'
                '"uploadUrl":"https://r2.example/clip?sig=1"}',
              );
            }
            if (o.path.endsWith('/complete')) {
              return _json('{"status":"stored"}');
            }
            return _json('{"id":"ord1","tracking_raw":"SPX1","created_at":0}');
          });
        final uploader = ApiEvidenceUploader(
          EcApi(apiDio),
          put: _FakeR2((_) => 'etag').put,
          extractThumbnail: (_) async => null,
        );

        // Act
        await uploader.upload(
          clip,
          tracking: 'SPX1',
          type: 'Đóng hàng',
          shopId: 'shop1',
        );

        // Assert — sha256 of the literal bytes written by tempClip().
        final body =
            bodies['/api/shops/shop1/orders/ord1/uploads/ev1/complete']!
                as Map<String, Object?>;
        expect(
          body['sha256'],
          sha256.convert(utf8.encode('video-bytes')).toString(),
        );
      },
    );

    test('skips the poster entirely for a photo', () async {
      // Arrange
      final dir = Directory.systemTemp.createTempSync('ec_uploader_photo');
      addTearDown(() => dir.deleteSync(recursive: true));
      final photo = File('${dir.path}/shot.jpg')..writeAsStringSync('jpeg');
      final r2 = _FakeR2((_) => 'etag');
      final uploader = ApiEvidenceUploader(
        EcApi(posterApi()),
        put: r2.put,
        extractThumbnail: (_) async => fail('a photo is its own preview'),
      );

      // Act
      await uploader.upload(
        photo,
        tracking: 'SPX1',
        type: 'Ảnh đính kèm',
        shopId: 'shop1',
      );

      // Assert
      expect(r2.calls.single.url, 'https://r2.example/clip?sig=1');
    });
  });
}
