# Certificate Pinning

Pin the server's certificate to prevent MITM attacks. Pins are configured per flavor in `EnvConfig` — not hardcoded in the interceptor.

## `SecurityInterceptor`

```dart
// lib/src/core/network/interceptors/security_interceptor.dart
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../../config/app_config.dart';

/// Applies SHA-256 certificate pinning to [Dio] based on flavor config.
/// Registered in DI and injected into buildDio like other interceptors.
final class SecurityInterceptor {
  SecurityInterceptor({required AppConfig config})
      : _enablePinning = config.enableSslPinning,
        _pins = config.sslPins;

  final bool _enablePinning;
  final Set<String> _pins;

  /// Applies certificate pinning to the given [Dio] instance.
  void apply(Dio dio) {
    if (!_enablePinning || _pins.isEmpty) return;

    final adapter = dio.httpClientAdapter;
    if (adapter is! IOHttpClientAdapter) return;

    adapter.createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = _validateCertificate;
      return client;
    };
  }

  bool _validateCertificate(X509Certificate cert, String host, int port) {
    final digest = sha256.convert(cert.der).bytes;
    final pin = base64Encode(digest);
    return _pins.contains(pin);
  }
}
```

## Flavor config for pins

Pins live in `EnvConfig` — each flavor controls whether pinning is enabled and which SHA-256 hashes to trust.

```dart
// In EnvConfig
const EnvConfig({
  // ...existing fields...
  this.enableSslPinning = false,
  this.sslPins = const <String>{},
});

final bool enableSslPinning;
final Set<String> sslPins;

static const dev = EnvConfig(
  env: Env.dev,
  // No pinning — dev may use self-signed certs
);

static const uat = EnvConfig(
  env: Env.uat,
  enableSslPinning: true,
  sslPins: <String>{'AAAA...='},
);

static const prod = EnvConfig(
  env: Env.prod,
  enableSslPinning: true,
  sslPins: <String>{
    'AAAA...=', // primary
    'BBBB...=', // backup
  },
);
```

## Wire in DI + `DioClient`

```dart
// service_locator.dart
getIt.registerLazySingleton<SecurityInterceptor>(
  () => SecurityInterceptor(config: getIt<AppConfig>()),
);

// dio_client.dart
Dio buildDio({
  required AppConfig config,
  required SecurityInterceptor security,
  required RetryInterceptorFactory retryFactory,
  required LoggingInterceptor logging,
  required ErrorInterceptor error,
}) {
  final dio = Dio(BaseOptions(baseUrl: config.apiBaseUrl));
  security.apply(dio);
  dio.interceptors.addAll([retryFactory.create(dio), logging, error]);
  return dio;
}
```

## Network Security Config (Android)

`android/app/src/main/res/xml/network_security_config.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- No cleartext traffic in production -->
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>

    <!-- Pin certificate for the API domain -->
    <domain-config>
        <domain includeSubdomains="true">api.example.com</domain>
        <pin-set expiration="2026-01-01">
            <pin digest="SHA-256">AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=</pin>
            <!-- Backup pin (rotate before expiration) -->
            <pin digest="SHA-256">BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=</pin>
        </pin-set>
    </domain-config>
</network-security-config>
```

`AndroidManifest.xml`:

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

## App Transport Security (iOS)

`ios/Runner/Info.plist` — disable ATS exceptions in production:

```xml
<!-- Remove or don't add NSAppTransportSecurity exceptions in prod -->
<!-- If needed only for dev: -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```
