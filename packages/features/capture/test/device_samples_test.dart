import 'package:feature_capture/feature_capture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeviceSample wire format', () {
    test('round-trips through the encoding the upload queue persists', () {
      const samples = [
        DeviceSample(tMs: 0, battery: 87, charging: false, net: NetKind.mobile),
        DeviceSample(
          tMs: 2000,
          battery: null,
          charging: true,
          net: NetKind.wifi,
        ),
      ];

      final decoded = DeviceSample.decode(DeviceSample.encode(samples));

      expect(decoded, hasLength(2));
      expect(decoded[0].tMs, 0);
      expect(decoded[0].battery, 87);
      expect(decoded[0].charging, isFalse);
      expect(decoded[0].net, NetKind.mobile);
      // Pin null phải sống sót nguyên vẹn: "không đọc được" là dữ kiện thật,
      // hoá thành 0 là bịa một con số vào bằng chứng.
      expect(decoded[1].battery, isNull);
      expect(decoded[1].charging, isTrue);
      expect(decoded[1].net, NetKind.wifi);
    });

    test('uses exactly the keys and net values the backend validates', () {
      const sample = DeviceSample(
        tMs: 4000,
        battery: 50,
        charging: false,
        net: NetKind.ethernet,
      );
      // Lệch một tên khoá là backend trả 400 và cả bộ mẫu của clip đó mất
      // vĩnh viễn — không quay lại lấy được.
      expect(sample.toJson(), {
        't_ms': 4000,
        'battery': 50,
        'charging': false,
        'net': 'ethernet',
      });
      expect(NetKind.values.map((k) => k.wire), [
        'wifi',
        'mobile',
        'ethernet',
        'other',
        'none',
      ]);
    });

    test('an unknown net kind from a newer writer degrades to other', () {
      final decoded = DeviceSample.decode(
        '[{"t_ms":0,"battery":10,"charging":false,"net":"satellite"}]',
      );
      expect(decoded.single.net, NetKind.other);
    });

    test('sampling interval matches the backend contract', () {
      // PHẢI khớp SAMPLE_INTERVAL_MS trong services/device_samples.ts — máy chủ
      // đối chiếu số mẫu với thời lượng clip để phát hiện bộ mẫu dựng tay.
      expect(kSampleInterval, const Duration(seconds: 2));
    });
  });
}
