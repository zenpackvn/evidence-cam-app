/// Đọc pin + loại mạng thật từ nền tảng, cho [DeviceConditionSource] của
/// feature_capture.
///
/// Nằm ở composition root chứ không nằm trong feature package: `battery_plus`
/// là plugin bên thứ ba, và feature package chỉ được chạm plugin qua một infra
/// wrapper (`test/architecture/wrapper_rule_test.dart` canh điều đó). Loại mạng
/// thì đã có wrapper sẵn — `sync_connectivity_plus`.
library;

import 'package:battery_plus/battery_plus.dart';
import 'package:feature_capture/feature_capture.dart'
    show DeviceConditionSource, NetKind;
import 'package:sync_connectivity_plus/sync_connectivity_plus.dart';

class PlatformDeviceConditions implements DeviceConditionSource {
  const PlatformDeviceConditions();

  @override
  Future<({int? battery, bool charging, NetKind net})> read() async {
    final battery = Battery();
    // Đọc song song: mỗi lời gọi là một lượt qua platform channel, và hàm này
    // chạy 2 giây một lần trong lúc camera đang ghi.
    final results = await Future.wait([
      _level(battery),
      _charging(battery),
      _net(),
    ]);
    return (
      battery: results[0] as int?,
      charging: results[1]! as bool,
      net: results[2]! as NetKind,
    );
  }

  /// Null khi nền tảng không trả lời — "không đọc được" là dữ kiện thật, khác
  /// hẳn với việc bịa một con số vào bằng chứng.
  static Future<int?> _level(Battery battery) async {
    try {
      return await battery.batteryLevel;
    } on Object {
      return null;
    }
  }

  static Future<bool> _charging(Battery battery) async {
    try {
      final state = await battery.batteryState;
      return state == BatteryState.charging || state == BatteryState.full;
    } on Object {
      return false;
    }
  }

  static Future<NetKind> _net() async {
    try {
      return _kindOf(await Connectivity().checkConnectivity());
    } on Object {
      return NetKind.other;
    }
  }

  /// Nền tảng trả về **danh sách** liên kết (máy có thể vừa WiFi vừa di động).
  /// Chọn liên kết "tốn tiền nhất" — nếu đang có di động thì đó là thứ mô tả
  /// đúng điều kiện quay, kể cả khi WiFi cũng đang bật nhưng không ra được
  /// internet.
  static NetKind _kindOf(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.mobile)) return NetKind.mobile;
    if (results.contains(ConnectivityResult.wifi)) return NetKind.wifi;
    if (results.contains(ConnectivityResult.ethernet)) return NetKind.ethernet;
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      return NetKind.none;
    }
    return NetKind.other;
  }
}
