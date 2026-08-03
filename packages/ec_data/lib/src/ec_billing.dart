import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Kết quả một lượt mở paywall, quy về ba trạng thái app cần phân biệt.
enum EcPurchaseOutcome {
  /// Đã thanh toán xong ở phía cửa hàng. KHÔNG có nghĩa là backend đã cộng ngày
  /// — RevenueCat gọi webhook bất đồng bộ, xem [EcBilling.waitForPlanChange].
  purchased,

  /// Người dùng đóng paywall, không mua. Không phải lỗi, đừng báo lỗi.
  cancelled,

  /// Cửa hàng hoặc mạng lỗi. Đáng hiện thông báo.
  failed,
}

/// Cổng thanh toán trong ứng dụng: RevenueCat + paywall của họ.
///
/// Nguồn sự thật về quyền dùng KHÔNG nằm ở đây mà ở backend — lớp này chỉ lo
/// việc thu tiền. Sản phẩm là loại tiêu hao (mua đứt, cộng ngày), nên
/// `customerInfo.entitlements` của RevenueCat luôn rỗng và không được dùng để
/// quyết định người dùng có quyền gì.
class EcBilling {
  EcBilling({required this.apiKey});

  /// SDK key công khai của nền tảng (iOS: `appl_…`, Android: `goog_…`).
  final String apiKey;

  bool _configured = false;

  /// Gắn phiên mua với tài khoản. `uid` phải là **Firebase uid** — backend đọc
  /// `app_user_id` của webhook đúng bằng giá trị này để biết cộng ngày cho ai.
  /// Sai chỗ này thì tiền vào mà không ai được kích hoạt.
  Future<void> start(String uid) async {
    if (!_configured) {
      await Purchases.configure(PurchasesConfiguration(apiKey)..appUserID = uid);
      _configured = true;
      return;
    }
    await Purchases.logIn(uid);
  }

  /// Tách phiên mua khỏi tài khoản khi đăng xuất, để lần đăng nhập sau trên
  /// cùng thiết bị không kế thừa giao dịch của người trước.
  Future<void> signOut() async {
    if (!_configured) return;
    await Purchases.logOut();
  }

  /// Mở paywall dựng trong dashboard RevenueCat.
  Future<EcPurchaseOutcome> presentPaywall() async {
    if (!_configured) return EcPurchaseOutcome.failed;
    try {
      final result = await RevenueCatUI.presentPaywall(displayCloseButton: true);
      return switch (result) {
        PaywallResult.purchased || PaywallResult.restored =>
          EcPurchaseOutcome.purchased,
        PaywallResult.cancelled => EcPurchaseOutcome.cancelled,
        PaywallResult.error || PaywallResult.notPresented =>
          EcPurchaseOutcome.failed,
      };
    } on PlatformException {
      return EcPurchaseOutcome.failed;
    }
  }

  /// Chờ backend áp xong giao dịch, bằng cách hỏi lại cho tới khi gói đổi.
  ///
  /// Cần thiết vì cửa hàng báo "đã mua" trước khi RevenueCat kịp gọi webhook về
  /// backend. Không chờ thì màn hình vẫn hiện gói cũ ngay sau khi trả tiền —
  /// người dùng tưởng mất tiền.
  ///
  /// Trả về `true` nếu thấy gói đổi, `false` nếu hết thời gian chờ. Hết thời
  /// gian **không** có nghĩa là mua hỏng: webhook có thể về muộn hơn, nên phía
  /// gọi hãy báo "đang xử lý" chứ đừng báo thất bại.
  static Future<bool> waitForPlanChange({
    required Future<String> Function() fetchPlanCode,
    required String previousPlanCode,
    Duration timeout = const Duration(seconds: 20),
    Duration interval = const Duration(seconds: 2),
    Future<void> Function(Duration)? sleep,
  }) async {
    final delay = sleep ?? Future<void>.delayed;
    var waited = Duration.zero;
    while (waited < timeout) {
      await delay(interval);
      waited += interval;
      try {
        if (await fetchPlanCode() != previousPlanCode) return true;
      } on Object {
        // Mạng chập chờn giữa chừng không được làm hỏng cả vòng chờ; lần sau
        // hỏi lại. Chỉ hết thời gian mới bỏ cuộc.
        continue;
      }
    }
    return false;
  }
}
