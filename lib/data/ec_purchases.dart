/// Mua gói TRONG APP qua IAP, môi giới bởi RevenueCat.
///
/// Ranh giới trách nhiệm rất hẹp có chủ đích: file này chỉ biết mở cửa hàng và
/// biết người đang đăng nhập là ai. Nó **không** cấp ngày, không đọc hạn dùng,
/// không quyết định ai được dùng gì — tất cả những thứ đó do backend chốt khi
/// webhook của RevenueCat tới (`/webhooks/revenuecat` → `applyRevenueCatEvent`).
///
/// Vì sao chia như vậy: biên nhận trên máy có thể bị giả, bị phát lại, hoặc đến
/// từ một thiết bị vừa đổi tài khoản. Tin nó là mở cửa cho việc tự cấp gói.
/// App mua xong chỉ làm đúng một việc — hỏi lại backend.
library;

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Cửa hàng trong app. `null` ở mọi chỗ gọi nghĩa là build này không có khoá
/// RevenueCat — xem [EcPurchases.configure].
class EcPurchases {
  EcPurchases._();

  static EcPurchases? _instance;

  /// Đã cấu hình chưa. Màn Quota hỏi cờ này để quyết định có hiện nút mua —
  /// nút mua bấm vào không mở được gì còn tệ hơn là không có nút.
  static bool get isAvailable => _instance != null;

  /// Khởi tạo SDK. Gọi MỘT LẦN lúc bootstrap, TRƯỚC `runApp`.
  ///
  /// Khoá rỗng → thoát êm, không ném: bản build offline/nội bộ cố ý không có
  /// cửa hàng, và làm sập app lúc khởi động vì thiếu một khoá tuỳ chọn là đổi
  /// một tính năng vắng mặt lấy một app không mở được.
  static Future<void> configure(String apiKey) async {
    // Một dòng ở logcat/Console, kể cả bản release. Khi cửa hàng vắng mặt thì
    // hậu quả duy nhất nhìn thấy được là NÚT BIẾN MẤT — không lỗi, không dấu
    // vết, và không cách nào phân biệt "build quên khoá" với "SDK từ chối
    // khoá" nếu đứng ngoài nhìn vào. Đây chính là chỗ đã ngốn hai giờ dò lỗi.
    if (apiKey.isEmpty) {
      // `debugPrint` chứ KHÔNG phải `developer.log`: cái sau đi qua VM service,
      // thứ bản release không có — nên ở đúng bản cần dò lỗi thì nó câm.
      debugPrint(
        'zenpack.purchases: KHÔNG có khoá cửa hàng cho nền tảng này — mọi nút '
        'mua sẽ ẩn (build thiếu --dart-define-from-file env/<flavor>.json?)',
      );
      return;
    }
    // Log rác của SDK chỉ có ích khi đang dò lỗi tích hợp.
    await Purchases.setLogLevel(LogLevel.warn);
    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
    } on Object catch (error) {
      // KHÔNG để ném tiếp: chỗ gọi nằm trong bootstrap, nên một lỗi cửa hàng
      // sẽ biến thành màn "app không mở được". Không có cửa hàng thì app vẫn
      // quay video được — đó là việc chính của nó.
      debugPrint(
        'zenpack.purchases: SDK từ chối khoá (${error.runtimeType}: $error) — '
        'mọi nút mua sẽ ẩn',
      );
      return;
    }
    _instance = EcPurchases._();
    debugPrint('zenpack.purchases: sẵn sàng (khoá ${apiKey.substring(0, 8)}…)');
  }

  /// Gắn phiên mua hàng vào ĐÚNG tài khoản đang đăng nhập.
  ///
  /// `app_user_id` phải là Firebase uid: backend tra tài khoản bằng chính giá
  /// trị đó (`applyRevenueCatEvent`), và uid lạ thì nó bỏ qua event — người
  /// dùng trả tiền mà không ai được cộng ngày.
  static Future<void> logIn(String uid) async {
    if (_instance == null || uid.isEmpty) return;
    await Purchases.logIn(uid);
  }

  /// Gỡ phiên mua hàng khỏi máy khi đăng xuất.
  ///
  /// KHÔNG phải dọn dẹp cho gọn: thiếu bước này thì người đăng nhập SAU mua gói
  /// sẽ được cộng ngày cho tài khoản TRƯỚC, vì RevenueCat vẫn giữ app_user_id
  /// cũ. Lỗi này đã từng có trong app hồi còn cửa hàng.
  static Future<void> logOut() async {
    if (_instance == null) return;
    // Đã ở trạng thái ẩn danh thì `logOut` ném — không phải lỗi cần ai biết.
    try {
      await Purchases.logOut();
    } on PlatformException catch (_) {
      // bỏ qua
    }
  }

  /// Nối phiên mua hàng với AppsFlyer UID của máy.
  ///
  /// Không phải trang trí: tích hợp AppsFlyer của RevenueCat bắn event mua gói
  /// (kể cả **gia hạn**) thẳng từ máy chủ họ sang AppsFlyer, và AppsFlyer chỉ
  /// quy được event đó về đúng lượt bấm quảng cáo nếu có UID này. Thiếu nó thì
  /// chiến dịch tối ưu theo doanh thu mù hoàn toàn.
  ///
  /// Xem `EcAppsflyer.start` — chỗ gọi duy nhất.
  static Future<void> setAppsflyerId(String id) async {
    if (_instance == null || id.isEmpty) return;
    await Purchases.setAppsflyerID(id);
  }

  /// Ép ngôn ngữ hiển thị của paywall dựng sẵn.
  ///
  /// Phải gọi, không phải tuỳ chọn: paywall của RevenueCat đọc ngôn ngữ **của
  /// máy**, không đọc ngôn ngữ app. Người dùng đổi app sang Tiếng Việt mà iOS
  /// đang để English thì bấm mua vẫn ra paywall tiếng Anh — và không có nút nào
  /// trong app giải thích được chuyện đó.
  ///
  /// Không sửa được từ dashboard: localization bên đó chỉ quyết định *có* bản
  /// dịch nào, còn *chọn* bản nào là việc của SDK.
  ///
  /// [code] là mã ngôn ngữ (`vi`, `en`, hoặc dạng `es-ES` / `es_ES`).
  static Future<void> setUiLocale(String code) async {
    if (_instance == null) return;
    await Purchases.overridePreferredUILocale(code);
  }

  /// Mở paywall dựng sẵn của RevenueCat cho offering `default`.
  ///
  /// Dùng `presentPaywall()` chứ KHÔNG dùng `presentPaywallIfNeeded()`: biến
  /// thể kia chỉ mở khi người dùng CHƯA có entitlement, mà ở đây người đang
  /// dùng gói Cơ bản vẫn phải mở được paywall để lên gói cao hơn. Với
  /// `presentPaywallIfNeeded()` thì đúng nhóm khách sẵn sàng trả thêm tiền lại
  /// là nhóm không bấm được nút.
  ///
  /// Điều kiện để nó mở ra được, cả ba đều phải đúng bên RevenueCat: offering
  /// `default` là **current**, có **paywall đã publish** gắn vào nó, và
  /// package trong đó gắn product của **đúng cửa hàng đang chạy**. Thiếu một
  /// cái là SDK trả `PaywallResult.error` và người dùng thấy một cú bấm không
  /// làm gì.
  ///
  /// Trả về `true` khi người dùng mua xong. Chỗ gọi dùng nó để hỏi lại backend,
  /// KHÔNG phải để tự bật gói.
  static Future<bool> presentPaywall() async {
    if (_instance == null) return false;
    final result = await RevenueCatUI.presentPaywall();
    return result == PaywallResult.purchased ||
        result == PaywallResult.restored;
  }
}
