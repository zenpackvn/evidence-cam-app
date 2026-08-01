/// Điều kiện thiết bị lấy mẫu trong lúc quay — nguồn cho bản render nung chữ
/// lên khung hình.
///
/// Dữ liệu này **không hồi tố được**: nó chỉ tồn tại trong lúc quay. Clip nào
/// quay mà không lấy mẫu thì vĩnh viễn không có pin/mạng, không dựng lại được
/// từ bất cứ đâu.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Nhịp lấy mẫu. PHẢI khớp `SAMPLE_INTERVAL_MS` của backend
/// (`services/device_samples.ts`) — máy chủ đối chiếu số mẫu với thời lượng
/// clip, lệch nhịp là mọi bộ mẫu bị đánh là dựng.
const kSampleInterval = Duration(seconds: 2);

/// Loại kết nối, đúng bộ giá trị backend nhận. Cố ý **không** có cường độ sóng:
/// iOS không có API public cho RSSI, và một trường có thật trên Android còn
/// trống trên iOS thì chính nó là thứ không thật.
enum NetKind {
  wifi,
  mobile,
  ethernet,
  other,
  none;

  String get wire => name;
}

/// Một lần đọc điều kiện thiết bị.
///
/// [tMs] là offset từ `Stopwatch` (đồng hồ đơn điệu), **không** phải giờ tường:
/// giờ tuyệt đối do máy chủ cộng vào lúc render, client không được quyền quyết
/// định giờ hiển thị trên bằng chứng.
@immutable
class DeviceSample {
  const DeviceSample({
    required this.tMs,
    required this.battery,
    required this.charging,
    required this.net,
  });

  final int tMs;

  /// 0–100, hoặc null khi nền tảng không đọc được. Null vẫn hợp lệ và vẫn gửi —
  /// "không đọc được" là dữ kiện thật, khác với bịa một con số.
  final int? battery;
  final bool charging;
  final NetKind net;

  Map<String, Object?> toJson() => {
    't_ms': tMs,
    'battery': battery,
    'charging': charging,
    'net': net.wire,
  };

  static String encode(List<DeviceSample> samples) =>
      jsonEncode(samples.map((s) => s.toJson()).toList());

  static List<DeviceSample> decode(String raw) => (jsonDecode(raw) as List)
      .cast<Map<String, dynamic>>()
      .map(
        (j) => DeviceSample(
          tMs: j['t_ms'] as int,
          battery: j['battery'] as int?,
          charging: j['charging'] as bool,
          net: NetKind.values.firstWhere(
            (k) => k.wire == j['net'],
            orElse: () => NetKind.other,
          ),
        ),
      )
      .toList();
}

/// Đọc pin + loại mạng. Cài đặt thật nằm ở composition root (`lib/`) — feature
/// package không import plugin trực tiếp (wrapper rule, có
/// `test/architecture/wrapper_rule_test.dart` canh).
abstract class DeviceConditionSource {
  Future<({int? battery, bool charging, NetKind net})> read();
}
