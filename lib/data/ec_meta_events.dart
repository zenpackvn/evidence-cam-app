/// Sự kiện gửi về Meta (Facebook Ads) để chiến dịch tối ưu theo hành vi thật,
/// không chỉ theo lượt cài.
///
/// Ranh giới hẹp có chủ đích — chỉ ba thứ đi qua đây:
///
///   * **Cài đặt / mở app**: SDK tự log (`AutoLogAppEvents` mặc định bật). Không
///     có dòng code nào ở file này, và đừng thêm — log tay thì Meta đếm hai lần.
///   * **`CompleteRegistration`**: chủ shop tạo shop đầu tiên. Đây là phễu để
///     chạy quảng cáo lúc ngân sách còn nhỏ: Meta cần ~50 conversion/tuần/ad set
///     mới thoát learning, mà `Purchase` thì quá thưa để đạt ngưỡng đó.
///   * **Mua gói**: KHÔNG log ở đây, dù SDK có sẵn `logPurchase`. RevenueCat bắn
///     event server-side qua tích hợp Facebook Ads của nó, và nó thấy cả **gia
///     hạn** — thứ client SDK không bao giờ thấy vì app không chạy lúc Apple/
///     Google trừ tiền. Cầu nối là `getAnonymousId()` của Meta SDK, được nối
///     sang RevenueCat trong `EcMetaEvents.start`; thiếu nó thì event về tới Meta
///     mà không khớp được với ai đã bấm quảng cáo.
library;

import 'dart:io' show Platform;

import 'package:app_platform/app_platform.dart'
    show Permission, PermissionActions;
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'ec_purchases.dart';

/// Cầu nối sang Meta App Events.
class EcMetaEvents {
  EcMetaEvents._();

  static final _events = FacebookAppEvents();

  /// Xin quyền theo dõi (iOS) và nối danh tính Meta ↔ RevenueCat.
  ///
  /// Gọi SAU `runApp`, không phải trong bootstrap: hộp thoại ATT của iOS chỉ
  /// hiện khi app đã ở trạng thái `active`. Gọi sớm hơn thì hệ điều hành trả
  /// `denied` ngay lập tức mà không hỏi gì — và không hỏi lại lần nào nữa.
  ///
  /// Không ném: quảng cáo hỏng thì app vẫn phải quay được video.
  static Future<void> start() async {
    try {
      // Từ chối ATT không phải lỗi — attribution chỉ rơi về SKAdNetwork, thưa
      // hơn nhưng vẫn chạy. Không cần báo kết quả cho Meta SDK: từ FBSDK 18 nó
      // tự đọc trạng thái ATT của hệ điều hành (`setAdvertiserTracking` đã bị
      // đánh dấu deprecated đúng vì lý do đó).
      if (Platform.isIOS) await Permission.appTrackingTransparency.request();

      final anonId = await _events.getAnonymousId();
      if (anonId != null) await EcPurchases.setFacebookAnonymousId(anonId);
      debugPrint('zenpack.meta: sẵn sàng (anon id ${anonId ?? "—"})');
    } on Object catch (error) {
      debugPrint('zenpack.meta: không khởi tạo được ($error) — bỏ qua');
    }
  }

  /// Chủ shop tạo shop → `CompleteRegistration`.
  ///
  /// Đây là mốc "đã thành người dùng thật" của EvidenceCam: đăng nhập xong mà
  /// chưa có shop thì chưa quay được đơn nào.
  static Future<void> logShopCreated() async {
    try {
      await _events.logCompletedRegistration(registrationMethod: 'shop');
    } on Object catch (error) {
      debugPrint('zenpack.meta: log CompleteRegistration hỏng ($error)');
    }
  }
}
