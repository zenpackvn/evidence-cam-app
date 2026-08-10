import 'package:injectable/injectable.dart';

@singleton
class EnvConfig {
  const EnvConfig();

  String get flavor =>
      const String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// Production API origin is the default so a bare `flutter build` (no
  /// `--dart-define-from-file`) ships a working app rather than one pointing at
  /// a localhost that only exists on a developer's machine. Point it elsewhere
  /// with `env/dev.json` when running against a local Worker.
  String get apiBaseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.zenpack.vn',
  );

  /// HTTP connect/receive timeout, configurable per flavor via the
  /// `API_TIMEOUT_SECONDS` dart-define. Defaults to 10 seconds.
  Duration get apiTimeout => const Duration(
    seconds: int.fromEnvironment('API_TIMEOUT_SECONDS', defaultValue: 10),
  );

  /// Comma-separated SHA-256 fingerprints (lowercase hex, no colons) of the
  /// server certificates to pin, supplied via the `CERT_SHA256_PINS`
  /// dart-define. Empty (the default) disables pinning — convenient for dev
  /// against a local/tunnel server with a rotating cert. Set it for prod.
  ///
  /// Compute a pin for a host with:
  /// `openssl s_client -connect host:443 </dev/null 2>/dev/null \`
  /// `  | openssl x509 -outform der | openssl dgst -sha256`.
  List<String> get certSha256Pins {
    const raw = String.fromEnvironment('CERT_SHA256_PINS');
    if (raw.isEmpty) return const [];
    return raw
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }

  /// Khoá SDK CÔNG KHAI của RevenueCat, một khoá mỗi nền tảng
  /// (Project Settings → API keys → App-specific, tiền tố `appl_` / `goog_`).
  ///
  /// Đây KHÔNG phải `RC_V2_KEY` mà `tool/rc_products.mjs` dùng — cái đó là khoá
  /// quản trị và không bao giờ được nhúng vào app. Khoá công khai vốn để lộ ra
  /// trong binary, nên nó nằm ở dart-define chứ không phải secret store.
  ///
  /// Vắng = KHÔNG khởi tạo RevenueCat và màn Quota không hiện nút mua. Đó là
  /// mặc định an toàn: một nút mua bấm vào không làm gì tệ hơn nhiều so với
  /// không có nút, và bản build nội bộ/offline không cần cửa hàng.
  String get revenueCatIosKey =>
      const String.fromEnvironment('REVENUECAT_IOS_KEY');

  String get revenueCatAndroidKey =>
      const String.fromEnvironment('REVENUECAT_ANDROID_KEY');

  bool get isDev => flavor == 'dev';
  bool get isStaging => flavor == 'staging';
  bool get isProd => flavor == 'prod';
}
