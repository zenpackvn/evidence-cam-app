/// Sự kiện gửi về AppsFlyer để đo attribution (quảng cáo nào đưa người dùng tới
/// app) và để chiến dịch tối ưu theo hành vi thật, không chỉ theo lượt cài.
///
/// Ranh giới hẹp có chủ đích — chỉ ba thứ đi qua đây:
///
///   * **Cài đặt / mở app**: SDK tự log sau `startSDK()`. Không có dòng code nào
///     ở file này, và đừng thêm — log tay thì AppsFlyer đếm hai lần.
///   * **`af_complete_registration`**: chủ shop tạo shop đầu tiên. Đây là phễu
///     để chạy quảng cáo lúc ngân sách còn nhỏ: mạng quảng cáo cần nhiều
///     conversion/tuần mới thoát learning, mà mua gói thì quá thưa để đạt ngưỡng.
///   * **`af_login`**: đăng nhập thành công. Đầu phễu — dày nhất trong các mốc
///     log tay, đủ số để ad set thoát learning khi ngân sách còn nhỏ.
///   * **`af_content_view`**: mở bảng giá. Tín hiệu ý định trả tiền, đứng ngay
///     trước `af_purchase` trong bậc thang AEM của Meta.
///   * **Mua gói**: KHÔNG log ở đây, dù SDK có sẵn `af_purchase`. RevenueCat bắn
///     event server-side qua tích hợp AppsFlyer của nó, và nó thấy cả **gia
///     hạn** — thứ client SDK không bao giờ thấy vì app không chạy lúc Apple/
///     Google trừ tiền. Cầu nối là AppsFlyer UID, được nối sang RevenueCat trong
///     `EcAppsflyer.start`; thiếu nó thì event về tới AppsFlyer mà không khớp
///     được với ai đã bấm quảng cáo.
library;

import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_platform/app_platform.dart'
    show Permission, PermissionActions, PermissionStatus;
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:config/config.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/widgets.dart'
    show AppLifecycleListener, AppLifecycleState, WidgetsBinding;

import 'ec_purchases.dart';

/// Cầu nối sang AppsFlyer.
class EcAppsflyer {
  EcAppsflyer._();

  static AppsflyerSdk? _sdk;

  /// Xin quyền theo dõi (iOS), khởi động SDK và nối danh tính AppsFlyer ↔
  /// RevenueCat.
  ///
  /// Thứ tự ở đây là thứ Apple soi, và app đã bị từ chối vì nó (Guideline 2.1,
  /// bản 2.0.2 build 700): hộp thoại phải hiện RA TRƯỚC mọi dữ liệu có thể dùng
  /// để theo dõi. Với AppsFlyer điều đó có nghĩa là **không dựng SDK** cho tới
  /// khi người dùng đã trả lời — `manualStart` một mình không đủ, chính lúc
  /// `AppsflyerSdk(...)` được tạo là lúc nó bắt đầu đọc máy.
  ///
  /// Không ném: quảng cáo hỏng thì app vẫn phải quay được video.
  static Future<void> start() async {
    const env = EnvConfig();
    final devKey = env.appsflyerDevKey;
    // Vắng khoá = không đo attribution. Mặc định an toàn cho bản build nội bộ,
    // giống cách RevenueCat vắng khoá thì không hiện nút mua.
    if (devKey.isEmpty) {
      debugPrint('zenpack.appsflyer: thiếu APPSFLYER_DEV_KEY — bỏ qua');
      return;
    }
    // iOS thiếu App Store ID thì SDK vẫn khởi động nhưng attribution hỏng âm
    // thầm — thà không chạy còn hơn báo cáo số liệu sai.
    if (Platform.isIOS && env.appsflyerIosAppId.isEmpty) {
      debugPrint('zenpack.appsflyer: thiếu APPSFLYER_IOS_APP_ID — bỏ qua');
      return;
    }

    try {
      // Xin TRƯỚC khi dựng SDK để IDFA (nếu được cho phép) có mặt ngay trong sự
      // kiện cài đặt; xin sau thì lượt cài đầu tiên mất IDFA vĩnh viễn.
      final allowed = !Platform.isIOS || await _requestTracking();

      final sdk = AppsflyerSdk(
        AppsFlyerOptions(
          afDevKey: devKey,
          appId: env.appsflyerIosAppId, // chỉ iOS đọc; Android bỏ qua
          showDebug: kDebugMode,
          manualStart: true,
          // Từ chối ATT KHÔNG phải lỗi — attribution rơi về SKAdNetwork, thưa
          // hơn nhưng vẫn chạy. Chỉ khác ở chỗ không được đụng vào IDFA.
          disableAdvertisingIdentifier: !allowed,
        ),
      );
      await sdk.initSdk();
      sdk.startSDK();
      _sdk = sdk;

      final uid = await sdk.getAppsFlyerUID();
      if (uid != null) await EcPurchases.setAppsflyerId(uid);
      debugPrint('zenpack.appsflyer: sẵn sàng (uid ${uid ?? "—"})');
    } on Object catch (error) {
      debugPrint('zenpack.appsflyer: không khởi tạo được ($error) — bỏ qua');
    }
  }

  /// Hiện hộp thoại ATT; trả về `true` khi người dùng đồng ý.
  ///
  /// Chờ app thật sự `resumed` mới hỏi. Đây là lỗi làm Apple từ chối bản trước:
  /// `addPostFrameCallback` chạy sau khung hình ĐẦU TIÊN, mà lúc đó iOS còn coi
  /// app là `inactive` — và `requestTrackingAuthorization` gọi lúc inactive thì
  /// trả `denied` NGAY, không hiện gì, không hỏi lại lần nào nữa. Người soi xét
  /// không bao giờ thấy hộp thoại.
  static Future<bool> _requestTracking() async {
    await _whenResumed();
    // Nghỉ một nhịp sau `resumed`: iOS chuyển sang active xong vẫn còn dựng nốt
    // cảnh, và hộp thoại xin quyền bật lên giữa lúc đó có thể bị nuốt.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final status = await Permission.appTrackingTransparency.request();
    debugPrint('zenpack.appsflyer: ATT trả lời $status');
    return status == PermissionStatus.granted;
  }

  /// Hoàn tất khi app ở trạng thái `resumed`, hoặc sau 10 giây thì thôi chờ.
  ///
  /// Có mốc bỏ cuộc vì app có thể khởi động ở nền (thông báo đẩy, tải nền) và
  /// không bao giờ `resumed`. Treo vĩnh viễn ở đó thì cả phần nối danh tính
  /// AppsFlyer ↔ RevenueCat bên dưới cũng không bao giờ chạy.
  static Future<void> _whenResumed() async {
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      return;
    }
    final resumed = Completer<void>();
    final listener = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.resumed && !resumed.isCompleted) {
          resumed.complete();
        }
      },
    );
    try {
      await resumed.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () =>
            debugPrint('zenpack.appsflyer: chờ app active quá lâu'),
      );
    } finally {
      listener.dispose();
    }
  }

  /// Đăng nhập thành công → `af_login`.
  ///
  /// Bắn mỗi lần đăng nhập, không chỉ lần đầu — đó là hành vi chuẩn của
  /// `af_login` và là lý do nó dày hơn `af_complete_registration`.
  static Future<void> logLogin(String method) =>
      _log('af_login', {'af_method': method});

  /// Mở bảng giá → `af_content_view`.
  ///
  /// KHÔNG có mốc "bấm nút mua": paywall dựng sẵn của RevenueCat chỉ trả về
  /// kết quả cuối, SDK không lộ ra lúc người dùng chạm nút. Bậc thang dừng ở
  /// đây rồi nhảy thẳng sang `af_purchase` do RevenueCat bắn server-side.
  static Future<void> logPaywallViewed() =>
      _log('af_content_view', {'af_content_type': 'paywall'});

  /// Chủ shop tạo shop → `af_complete_registration`.
  ///
  /// Đây là mốc "đã thành người dùng thật" của EvidenceCam: đăng nhập xong mà
  /// chưa có shop thì chưa quay được đơn nào.
  static Future<void> logShopCreated() =>
      _log('af_complete_registration', {'af_registration_method': 'shop'});

  /// Gửi một event, nuốt mọi lỗi.
  ///
  /// `_sdk` null nghĩa là `start` chưa chạy xong hoặc đã bỏ qua vì thiếu khoá —
  /// event không có chỗ để tới, bỏ im lặng chứ không xếp hàng chờ.
  static Future<void> _log(String name, Map<String, Object?> values) async {
    final sdk = _sdk;
    if (sdk == null) return;
    try {
      await sdk.logEvent(name, values);
    } on Object catch (error) {
      debugPrint('zenpack.appsflyer: log $name hỏng ($error)');
    }
  }
}
