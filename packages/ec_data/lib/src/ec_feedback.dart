/// Gửi góp ý người dùng lên CMS dùng chung của công ty.
///
/// Đây là hệ thống **riêng**, không phải backend EvidenceCam: host khác, không
/// dùng Firebase token, và người đọc góp ý ngồi ở admin panel của CMS. Vì vậy
/// nó có client riêng thay vì thêm một hàm vào `EcApi` — nhét chung một Dio đã
/// gắn `Authorization: Bearer <firebase-id-token>` là gửi token của người dùng
/// sang một bên thứ ba không cần tới nó.
library;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:network/network.dart'
    show BaseOptions, Dio, DioException, Options;

/// Origin của CMS. Ghi đè bằng `--dart-define=EC_FEEDBACK_URL=…`.
const kDefaultFeedbackBaseUrl = 'https://content-manager.zentam.vn';

/// Đường ghi góp ý của tenant **zenpack** — app này là ZenPack
/// (`com.aktechvn.zenpack`), không phải Zentam.
///
/// Mỗi tenant có collection riêng và **body khác nhau**: collection
/// `zenpack-feedback` chỉ nhận `message` + `source`, còn `feedback` của Zentam
/// mới có thêm `type`/`name`/`email`. Gửi nhầm sang đường của Zentam là góp ý
/// rơi vào hộp của sản phẩm khác.
///
/// **Bắt buộc có tiền tố tenant** — gọi thẳng `/api/zenpack-feedback` bị 403.
const kFeedbackPath = '/api/zenpack/zenpack-feedback';

/// CMS từ chối nội dung gửi lên (thiếu `message`, sai `type`/`email`).
///
/// Tách riêng khỏi lỗi mạng vì cách xử lý ngược nhau: cái này **không được
/// gửi lại** — gửi lại y nguyên thì lại hỏng y như vậy.
class EcFeedbackRejected implements Exception {
  const EcFeedbackRejected(this.message);

  final String message;

  @override
  String toString() => 'EcFeedbackRejected: $message';
}

/// Client gửi góp ý. Không có đường đọc: CMS chỉ cho admin đã đăng nhập `read`,
/// nên app không bao giờ lấy được danh sách góp ý về.
class EcFeedback {
  EcFeedback({Dio? dio, String baseUrl = kDefaultFeedbackBaseUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              // Tự nhận mọi mã trạng thái rồi phân loại bên dưới. Để Dio ném
              // thì 400 và 503 về cùng một chỗ, trong khi một cái phải bỏ hẳn
              // còn một cái đáng gửi lại.
              validateStatus: (_) => true,
            ),
          );

  final Dio _dio;

  /// Gửi một góp ý. Ném [EcFeedbackRejected] khi CMS bảo nội dung sai, ném
  /// [DioException] khi mạng hỏng.
  ///
  /// Chỉ có `message` và `source` — đúng bộ field collection `zenpack-feedback`
  /// khai. `type`/`name`/`email` là của collection bên Zentam; gửi kèm ở đây là
  /// gửi thứ đầu nhận không có chỗ chứa.
  ///
  /// KHÔNG gửi `tenant` và `status`: hai trường đó do CMS tự quyết. Client gửi
  /// lên là ghi xuyên sang tenant khác hoặc nhảy cóc hàng đợi xử lý — đúng lỗ
  /// hổng #2 trong tài liệu tích hợp, và bên gửi thì không có lý do gì chạm vào.
  ///
  /// Cũng KHÔNG gửi header `X-App-Version` — xem [_headers].
  Future<void> send({required String message, required String source}) async {
    final response = await _dio.post<dynamic>(
      kFeedbackPath,
      options: _headers,
      data: {'message': message, 'source': source},
    );

    final status = response.statusCode ?? 0;
    if (status == 201 || status == 200) return;
    // 400 sai nội dung, 403 sai URL (thiếu tiền tố tenant) — cả hai đều là lỗi
    // của phía gửi, gửi lại không đổi được gì.
    if (status == 400 || status == 403) {
      throw EcFeedbackRejected(_errorText(response.data) ?? 'HTTP $status');
    }
    // Còn lại (5xx, 426, mã lạ) coi là hỏng tạm thời để bên gọi tự quyết có
    // thử lại không.
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'feedback_failed_$status',
    );
  }

  /// Cố ý KHÔNG gắn `X-App-Version`.
  ///
  /// Header đó bật cơ chế **force-update** của CMS: middleware so phiên bản với
  /// một global `min supported version` rồi trả 426 kèm `storeUrl`, và nó áp
  /// cho **mọi** endpoint `/api/*` chứ không riêng góp ý. Global đó là của CMS
  /// dùng chung, đánh số phiên bản theo app khác, trỏ về store listing khác —
  /// để nó phán quyết bản ZenPack nào còn được dùng là giao vòng đời app của
  /// mình cho một hệ thống không biết gì về mình. App đã có cổng cập nhật riêng
  /// (`lib/app/update_gate.dart`).
  ///
  /// Bối cảnh phiên bản vẫn tới tay người đọc góp ý — nó nằm trong `source`.
  static Options get _headers => Options(headers: {'X-Platform': platformCode});

  /// `android` / `ios`, khớp giá trị tài liệu tích hợp dùng.
  static String get platformCode => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    final other => other.name.toLowerCase(),
  };

  /// Chuỗi `source` gửi kèm góp ý, ví dụ `zenpack-ios@1.4.2`.
  ///
  /// Phiên bản đi trong đây thay vì header `X-App-Version` — xem [_headers].
  /// Trường này là chuỗi tự do nên nhét được, và người đọc góp ý vẫn thấy ngay
  /// bối cảnh mà không phải hỏi lại: phần lớn góp ý là về một hành vi cụ thể
  /// trên một phiên bản cụ thể.
  static String sourceFor(String appVersion) {
    final base = 'zenpack-$platformCode';
    return appVersion.isEmpty ? base : '$base@$appVersion';
  }

  /// Lỗi của Payload luôn có dạng `{ "errors": [{ "message": "…" }] }`.
  static String? _errorText(dynamic body) {
    if (body is! Map) return null;
    final errors = body['errors'];
    if (errors is! List || errors.isEmpty) return null;
    final first = errors.first;
    return first is Map && first['message'] is String
        ? first['message'] as String
        : null;
  }
}
