import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

/// Kết quả một lượt mua, quy về ba trạng thái app cần phân biệt.
enum EcPurchaseOutcome {
  /// Đã thanh toán xong ở phía cửa hàng. KHÔNG có nghĩa là backend đã cộng ngày
  /// — RevenueCat gọi webhook bất đồng bộ, xem [EcBilling.waitForPlanChange].
  purchased,

  /// Người dùng bấm huỷ ở hộp thoại của cửa hàng. Không phải lỗi, đừng báo lỗi.
  cancelled,

  /// Cửa hàng hoặc mạng lỗi. Đáng hiện thông báo.
  failed,
}

/// Một gói bán được, đã ghép mã sản phẩm với giá đã định dạng theo tiền tệ của
/// cửa hàng. Màn hình paywall chỉ đọc kiểu này, không chạm tới SDK.
class EcPlanOffer {
  const EcPlanOffer({
    required this.planCode,
    required this.termKey,
    required this.priceLabel,
    required this.priceAmount,
    required this.package,
  });

  /// `basic` · `saver` · `premium`.
  final String planCode;

  /// `1m` · `6m` · `12m`.
  final String termKey;

  /// Giá đã định dạng sẵn bởi cửa hàng (vd `169.000 ₫`). **Luôn hiển thị chuỗi
  /// này**, đừng tự dựng lại từ số — cửa hàng mới biết đúng ký hiệu và cách
  /// nhóm chữ số của từng nước.
  final String priceLabel;

  /// Giá dạng số, chỉ dùng để tính giá quy đổi mỗi tháng.
  final double priceAmount;

  final Package package;
}

/// Cổng thanh toán trong ứng dụng.
///
/// Nguồn sự thật về quyền dùng KHÔNG nằm ở đây mà ở backend — lớp này chỉ lo
/// việc thu tiền. Sản phẩm là loại tiêu hao (mua đứt, cộng ngày), nên
/// `customerInfo.entitlements` của RevenueCat luôn rỗng và **không được dùng**
/// để quyết định người dùng có quyền gì. Cũng vì thế project không có
/// entitlement nào: gắn consumable vào entitlement thì RevenueCat báo mở khoá
/// vĩnh viễn, dựng lại đúng lỗi gói-vĩnh-viễn đã sửa ở backend.
class EcBilling {
  EcBilling({required this.apiKey});

  /// SDK key công khai của nền tảng (iOS: `appl_…`, Android: `goog_…`).
  final String apiKey;

  bool _configured = false;

  /// Gắn phiên mua với tài khoản. `uid` phải là **Firebase uid** — backend đọc
  /// `app_user_id` của webhook đúng bằng giá trị này để biết cộng ngày cho ai.
  /// Sai chỗ này thì tiền vào mà không ai được kích hoạt.
  /// Trả `false` khi không gắn được (cửa hàng lỗi, thiếu mạng, khoá sai). Phía
  /// gọi vẫn mở được paywall để người dùng thấy bảng giá — nuốt lỗi ở đây chứ
  /// KHÔNG ném ra, vì một ngoại lệ không ai bắt sẽ biến nút thành nút chết.
  Future<bool> start(String uid) async {
    try {
      if (!_configured) {
        await Purchases.configure(
          PurchasesConfiguration(apiKey)..appUserID = uid,
        );
        _configured = true;
        return true;
      }
      await Purchases.logIn(uid);
      return true;
    } on Object {
      return false;
    }
  }

  /// Tách phiên mua khỏi tài khoản khi đăng xuất, để lần đăng nhập sau trên
  /// cùng thiết bị không kế thừa giao dịch của người trước.
  Future<void> signOut() async {
    if (!_configured) return;
    try {
      await Purchases.logOut();
    } on Object {
      // Đăng xuất khỏi app không được phụ thuộc vào việc cửa hàng có trả lời.
    }
  }

  /// Các gói đang bán, đọc từ offering hiện hành của RevenueCat.
  ///
  /// Trả rỗng khi chưa cấu hình hoặc offering trống — màn hình gọi phải chịu
  /// được danh sách rỗng thay vì hiện paywall trắng trơn.
  Future<List<EcPlanOffer>> offers() async {
    if (!_configured) return const [];
    try {
      final current = (await Purchases.getOfferings()).current;
      if (current == null) return const [];
      return current.availablePackages
          .map(parseOffer)
          .whereType<EcPlanOffer>()
          .toList();
    } on Object {
      // Cửa hàng im lặng (simulator không có StoreKit, sản phẩm chưa duyệt,
      // mất mạng) là chuyện bình thường — trả rỗng để paywall hiện trạng thái
      // "chưa tải được bảng giá" thay vì ném lỗi lên tận nút bấm.
      return const [];
    }
  }

  /// Tách `basic_6m` thành gói + thời hạn.
  ///
  /// Khoá package do ta tự đặt khi tạo bên RevenueCat (tool/rc_products.mjs),
  /// nên hình dạng này là hợp đồng giữa hai bên. Package lạ bị bỏ qua chứ không
  /// làm hỏng cả danh sách — dashboard thêm nhầm một dòng không được làm sập
  /// màn hình mua gói.
  static EcPlanOffer? parseOffer(Package package) {
    final parts = package.identifier.split('_');
    if (parts.length != 2) return null;
    const plans = {'basic', 'saver', 'premium'};
    const terms = {'1m', '6m', '12m'};
    if (!plans.contains(parts[0]) || !terms.contains(parts[1])) return null;
    return EcPlanOffer(
      planCode: parts[0],
      termKey: parts[1],
      priceLabel: package.storeProduct.priceString,
      priceAmount: package.storeProduct.price,
      package: package,
    );
  }

  /// Mở hộp thoại thanh toán của cửa hàng cho một gói.
  Future<EcPurchaseOutcome> buy(EcPlanOffer offer) async {
    if (!_configured) return EcPurchaseOutcome.failed;
    try {
      await Purchases.purchasePackage(offer.package);
      return EcPurchaseOutcome.purchased;
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      return code == PurchasesErrorCode.purchaseCancelledError
          ? EcPurchaseOutcome.cancelled
          : EcPurchaseOutcome.failed;
    }
  }

  /// Nạp lại biên nhận của thiết bị lên RevenueCat.
  ///
  /// Dùng cho đúng một tình huống: cửa hàng đã trừ tiền nhưng backend chưa cộng
  /// ngày (webhook rớt, máy mất mạng ngay sau khi mua). RevenueCat bắn lại
  /// webhook cho những giao dịch nó thấy, và backend chống trùng theo
  /// `transaction_id` nên gọi bao nhiêu lần cũng không cộng dư.
  ///
  /// Đây KHÔNG phải "khôi phục mua hàng": gói tiêu hao đã tiêu là hết, không
  /// lấy lại được trên máy khác.
  Future<bool> syncPurchases() async {
    if (!_configured) return false;
    try {
      await Purchases.restorePurchases();
      return true;
    } on Object {
      return false;
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
