import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../permissions/permission_service.dart';

/// Thin wrapper around [FlutterLocalNotificationsPlugin].
///
/// Call [init] once during app bootstrap (from `main`). Permission prompts
/// are issued on demand via [requestPermissions]; on Android 13+ this is
/// required before any notification will surface.
@lazySingleton
class NotificationsService {
  NotificationsService(this._plugin, this._permissions);

  final FlutterLocalNotificationsPlugin _plugin;
  final PermissionService _permissions;

  /// Android notification channel used for general app notifications.
  /// Must match what's registered in [init] before posting.
  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
        'default_channel',
        'General',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
      );

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: initSettings);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_defaultChannel);
    _initialized = true;
  }

  /// Asks the user for permission to show notifications.
  Future<bool> requestPermissions() =>
      _permissions.requestNotificationPermission();

  /// Người dùng đã cho phép chưa — ĐỌC thôi, không bật hộp thoại nào.
  ///
  /// Cần tách khỏi [requestPermissions] vì trên iOS hỏi là hỏi một lần: gọi
  /// nhầm hàm hỏi ở chỗ chỉ định kiểm tra là đốt mất lượt hỏi duy nhất.
  Future<bool> daChoPhep() => _permissions.hasNotificationPermission();

  /// Shows a one-off notification on the default channel.
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) {
    return _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannel.id,
          _defaultChannel.name,
          channelDescription: _defaultChannel.description,
          importance: _defaultChannel.importance,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);

  Future<void> cancelAll() => _plugin.cancelAll();
}
