import 'package:ec_data/ec_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:test_utils/test_utils.dart';

class _MockDio extends Mock implements Dio {}

class _FakeOptions extends Fake implements Options {}

Response<dynamic> _res(int status, [dynamic body]) => Response<dynamic>(
  statusCode: status,
  data: body,
  requestOptions: RequestOptions(path: kFeedbackPath),
);

void main() {
  late _MockDio dio;
  late EcFeedback feedback;

  setUpAll(() => registerFallbackValue(_FakeOptions()));

  setUp(() {
    dio = _MockDio();
    feedback = EcFeedback(dio: dio);
  });

  void stub(Response<dynamic> response) {
    when(
      () => dio.post<dynamic>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => response);
  }

  Map<String, dynamic> sentBody() {
    final call = verify(
      () => dio.post<dynamic>(
        captureAny(),
        data: captureAny(named: 'data'),
        options: any(named: 'options'),
      ),
    );
    return call.captured[1] as Map<String, dynamic>;
  }

  test(
    'gửi vào collection của tenant zenpack, không phải của zentam',
    () async {
      stub(_res(201));

      await feedback.send(message: 'App treo', source: 'zenpack-ios@1.0.0');

      final call = verify(
        () => dio.post<dynamic>(
          captureAny(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      );
      // Tiền tố tenant là bắt buộc (thiếu → 403), và phải là `zenpack`: đường
      // của zentam đổ góp ý vào hộp của sản phẩm khác.
      expect(call.captured.single, '/api/zenpack/zenpack-feedback');
    },
  );

  // Collection `zenpack-feedback` chỉ khai 2 field. Gửi thừa `type`/`name`/
  // `email` (của collection bên Zentam) là gửi thứ đầu nhận không có chỗ chứa.
  test('gửi đúng hai field zenpack-feedback nhận, không thừa', () async {
    stub(_res(201));

    await feedback.send(message: 'Góp ý', source: 'zenpack-android@2.0.0');

    final body = sentBody();
    expect(body['message'], 'Góp ý');
    expect(body['source'], 'zenpack-android@2.0.0');
    expect(body.keys, unorderedEquals(<String>['message', 'source']));
  });

  // Lỗ hổng #2 của CMS: client gửi được thì ghi xuyên tenant / nhảy cóc hàng
  // đợi xử lý. Bên gửi không có lý do gì chạm vào hai trường đó.
  test('không bao giờ gửi tenant hay status', () async {
    stub(_res(201));

    await feedback.send(message: 'x', source: 's');

    final body = sentBody();
    expect(body.containsKey('tenant'), isFalse);
    expect(body.containsKey('status'), isFalse);
  });

  test('400 nêu đúng lý do CMS trả về, và không phải lỗi mạng', () async {
    stub(
      _res(400, {
        'errors': [
          {'message': 'message is required'},
        ],
      }),
    );

    await expectLater(
      feedback.send(message: '', source: 's'),
      throwsA(
        isA<EcFeedbackRejected>().having(
          (e) => e.message,
          'message',
          'message is required',
        ),
      ),
    );
  });

  test('403 (sai URL) cũng là lỗi bên gửi, không đáng thử lại', () async {
    stub(_res(403));

    await expectLater(
      feedback.send(message: 'x', source: 's'),
      throwsA(isA<EcFeedbackRejected>()),
    );
  });

  // 5xx và 426 đều KHÔNG phải EcFeedbackRejected: bên gọi được phép thử lại.
  test('5xx ném lỗi mạng để bên gọi thử lại', () async {
    stub(_res(503));

    await expectLater(
      feedback.send(message: 'x', source: 's'),
      throwsA(isA<DioException>()),
    );
  });

  test('426 force-update không bị nhầm thành nội dung sai', () async {
    stub(_res(426, {'storeUrl': 'https://store', 'title': 'Cập nhật'}));

    await expectLater(
      feedback.send(message: 'x', source: 's'),
      throwsA(isA<DioException>()),
    );
  });

  test('source mang phiên bản để người đọc biết bối cảnh', () {
    expect(EcFeedback.sourceFor('1.4.2'), contains('@1.4.2'));
    expect(EcFeedback.sourceFor('1.4.2'), startsWith('zenpack-'));
    // Đọc không ra phiên bản thì vẫn phải gửi được góp ý.
    expect(EcFeedback.sourceFor(''), isNot(contains('@')));
  });
}
