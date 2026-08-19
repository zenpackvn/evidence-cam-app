/// Sự kiện gửi về Meta (Facebook Ads) để chiến dịch tối ưu theo hành vi thật,
/// không chỉ theo lượt cài.
///
/// Ranh giới hẹp có chủ đích — chỉ ba thứ đi qua đây:
///
///   * **Cài đặt / mở app**: auto-log của SDK, nhưng bị TẮT trong `Info.plist`
///     và chỉ bật lại sau khi người dùng trả lời hộp thoại ATT — Apple bắt buộc
///     vậy. Lượt mở app bị bỏ lỡ trong khoảng đó được bù bằng đúng một
///     `activateApp()` trong `EcMetaEvents.start`; đừng thêm lượt log tay nào.
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

import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_platform/app_platform.dart'
    show Permission, PermissionActions, PermissionStatus;
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/widgets.dart'
    show AppLifecycleListener, AppLifecycleState, WidgetsBinding;

import 'ec_purchases.dart';

/// Cầu nối sang Meta App Events.
class EcMetaEvents {
  EcMetaEvents._();

  static final _events = FacebookAppEvents();

  /// Xin quyền theo dõi (iOS), bật thu thập của Meta, rồi nối danh tính Meta ↔
  /// RevenueCat.
  ///
  /// Thứ tự ở đây là thứ Apple soi, và app đã bị từ chối vì nó (Guideline 2.1,
  /// bản 2.0.2 build 700): hộp thoại phải hiện RA TRƯỚC mọi dữ liệu có thể dùng
  /// để theo dõi. Nên Meta SDK bị tắt thu thập trong `Info.plist`
  /// (`FacebookAutoLogAppEventsEnabled`, `FacebookAdvertiserIDCollectionEnabled`
  /// đều `false`) và chỉ được bật lại ở đây, sau khi người dùng đã trả lời.
  ///
  /// Không ném: quảng cáo hỏng thì app vẫn phải quay được video.
  static Future<void> start() async {
    try {
      if (Platform.isIOS) await _requestTracking();

      // Bật lại thu thập SAU câu trả lời. `activateApp` bù đúng một lượt mở app
      // — lượt mà auto-log đã bỏ lỡ vì bị tắt lúc khởi động. Gọi một lần mỗi
      // lượt chạy nên Meta không đếm hai lần.
      await _events.setAutoLogAppEventsEnabled(true);
      await _events.activateApp();

      final anonId = await _events.getAnonymousId();
      if (anonId != null) await EcPurchases.setFacebookAnonymousId(anonId);
      debugPrint('zenpack.meta: sẵn sàng (anon id ${anonId ?? "—"})');
    } on Object catch (error) {
      debugPrint('zenpack.meta: không khởi tạo được ($error) — bỏ qua');
    }
  }

  /// Hiện hộp thoại ATT, rồi mở thu thập ID quảng cáo đúng theo câu trả lời.
  ///
  /// Chờ app thật sự `resumed` mới hỏi. Đây là lỗi làm Apple từ chối bản trước:
  /// `addPostFrameCallback` chạy sau khung hình ĐẦU TIÊN, mà lúc đó iOS còn coi
  /// app là `inactive` — và `requestTrackingAuthorization` gọi lúc inactive thì
  /// trả `denied` NGAY, không hiện gì, không hỏi lại lần nào nữa. Người soi xét
  /// không bao giờ thấy hộp thoại.
  static Future<void> _requestTracking() async {
    await _whenResumed();
    // Nghỉ một nhịp sau `resumed`: iOS chuyển sang active xong vẫn còn dựng nốt
    // cảnh, và hộp thoại xin quyền bật lên giữa lúc đó có thể bị nuốt.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final status = await Permission.appTrackingTransparency.request();
    // Từ chối KHÔNG phải lỗi — attribution rơi về SKAdNetwork, thưa hơn nhưng
    // vẫn chạy. Chỉ khác ở chỗ không được đụng vào ID quảng cáo.
    await _events.setAdvertiserIdCollectionEnabled(
      status == PermissionStatus.granted,
    );
    debugPrint('zenpack.meta: ATT trả lời $status');
  }

  /// Hoàn tất khi app ở trạng thái `resumed`, hoặc sau 10 giây thì thôi chờ.
  ///
  /// Có mốc bỏ cuộc vì app có thể khởi động ở nền (thông báo đẩy, tải nền) và
  /// không bao giờ `resumed`. Treo vĩnh viễn ở đó thì cả phần nối danh tính
  /// Meta ↔ RevenueCat bên dưới cũng không bao giờ chạy.
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
        onTimeout: () => debugPrint('zenpack.meta: chờ app active quá lâu'),
      );
    } finally {
      listener.dispose();
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
