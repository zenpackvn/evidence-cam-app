import 'analytics_events.dart';
import 'analytics_service.dart';

export 'analytics_events.dart' show AnalyticsSources;

extension AuthAnalytics on AnalyticsService {
  /// `login` itself is a reserved Firebase event — log it with
  /// [AnalyticsService.logLogin]. This is only the failure branch, which
  /// Firebase has no name for.
  Future<void> trackLoginFailed({required String errorType}) {
    return logEvent(
      AnalyticsEvents.loginFailed,
      parameters: {AnalyticsParams.errorType: errorType},
    );
  }

  Future<void> trackSignOut() => logEvent(AnalyticsEvents.signOut);

  Future<void> trackEmailVerificationSent() =>
      logEvent(AnalyticsEvents.emailVerificationSent);

  Future<void> trackAccountDeleted() =>
      logEvent(AnalyticsEvents.accountDeleted);
}

extension ShopAnalytics on AnalyticsService {
  Future<void> trackShopCreated({required String platform}) {
    return logEvent(
      AnalyticsEvents.shopCreated,
      parameters: {AnalyticsParams.platform: platform},
    );
  }

  Future<void> trackShopSelected({required String platform}) {
    return logEvent(
      AnalyticsEvents.shopSelected,
      parameters: {AnalyticsParams.platform: platform},
    );
  }

  Future<void> trackMemberInvited() => logEvent(AnalyticsEvents.memberInvited);

  Future<void> trackMemberRemoved() => logEvent(AnalyticsEvents.memberRemoved);
}

extension RecordingAnalytics on AnalyticsService {
  Future<void> trackScanSucceeded() => logEvent(AnalyticsEvents.scanSucceeded);

  /// [errorType] separates "read nothing" from "read a code we rejected" —
  /// the two need different fixes on the packing table.
  Future<void> trackScanFailed({required String errorType}) {
    return logEvent(
      AnalyticsEvents.scanFailed,
      parameters: {AnalyticsParams.errorType: errorType},
    );
  }

  Future<void> trackCodeEnteredManually() =>
      logEvent(AnalyticsEvents.codeEnteredManually);

  Future<void> trackRecordingStarted({required String videoType}) {
    return logEvent(
      AnalyticsEvents.recordingStarted,
      parameters: {AnalyticsParams.videoType: videoType},
    );
  }

  Future<void> trackClipRecorded({
    required String videoType,
    int? durationSeconds,
  }) {
    return logEvent(
      AnalyticsEvents.clipRecorded,
      parameters: {
        AnalyticsParams.videoType: videoType,
        AnalyticsParams.durationSeconds: ?durationSeconds,
      },
    );
  }

  /// Closing one order straight into the next without leaving the viewfinder —
  /// the hands-free flow the whole product is sold on.
  Future<void> trackOrderCutover() => logEvent(AnalyticsEvents.orderCutover);

  Future<void> trackNearClipLimit() => logEvent(AnalyticsEvents.nearClipLimit);

  Future<void> trackVideoTypePicked({required String videoType}) {
    return logEvent(
      AnalyticsEvents.videoTypePicked,
      parameters: {AnalyticsParams.videoType: videoType},
    );
  }

  Future<void> trackVideoTypeCreated() =>
      logEvent(AnalyticsEvents.videoTypeCreated);
}

extension UploadAnalytics on AnalyticsService {
  Future<void> trackUploadCompleted() =>
      logEvent(AnalyticsEvents.uploadCompleted);

  Future<void> trackUploadFailed({String? errorType}) {
    return logEvent(
      AnalyticsEvents.uploadFailed,
      parameters: {
        AnalyticsParams.errorType: ?errorType,
      },
    );
  }

  Future<void> trackUploadRetried({required int attempt}) {
    return logEvent(
      AnalyticsEvents.uploadRetried,
      parameters: {AnalyticsParams.attempt: attempt},
    );
  }
}

extension EvidenceAnalytics on AnalyticsService {
  Future<void> trackOrderOpened({required String source}) {
    return logEvent(
      AnalyticsEvents.orderOpened,
      parameters: {AnalyticsParams.source: source},
    );
  }

  Future<void> trackVideoOpened({required String source}) {
    return logEvent(
      AnalyticsEvents.videoOpened,
      parameters: {AnalyticsParams.source: source},
    );
  }

  Future<void> trackVideoShared() => logEvent(AnalyticsEvents.videoShared);

  Future<void> trackVideoDeleted() => logEvent(AnalyticsEvents.videoDeleted);

  /// [filter] is which chip was used, not what the seller typed — an order
  /// code is customer data and has no business in an analytics payload.
  Future<void> trackOrdersFiltered({
    required String filter,
    required int resultCount,
  }) {
    return logEvent(
      AnalyticsEvents.ordersFiltered,
      parameters: {
        AnalyticsParams.filter: filter,
        AnalyticsParams.resultCount: resultCount,
      },
    );
  }
}

extension BillingAnalytics on AnalyticsService {
  Future<void> trackPaywallViewed() => logEvent(AnalyticsEvents.paywallViewed);

  Future<void> trackPurchaseStarted({required String planCode}) {
    return logEvent(
      AnalyticsEvents.purchaseStarted,
      parameters: {AnalyticsParams.planCode: planCode},
    );
  }
}

extension NotificationAnalytics on AnalyticsService {
  Future<void> trackNotificationOpened({required int payloadKeyCount}) {
    return logEvent(
      AnalyticsEvents.notificationOpened,
      parameters: {AnalyticsParams.payloadKeyCount: payloadKeyCount},
    );
  }
}
