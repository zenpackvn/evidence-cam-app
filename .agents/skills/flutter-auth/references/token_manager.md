# Auth — TokenManager

Stores tokens in `SecureStorage` (from [template-storage.md](template-storage.md)). Decodes JWT `exp` claim via simple base64 — no third-party JWT package needed.

## `lib/src/core/auth/token_manager.dart`

```dart
import 'dart:convert';

import '../storage/secure_storage.dart';

class TokenManager {
  TokenManager(this._storage);
  final SecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  // ── Read ──

  Future<String?> getAccessToken() => _storage.read(_accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(_refreshTokenKey);

  // ── Write ──

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(_accessTokenKey, accessToken);
    await _storage.write(_refreshTokenKey, refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(_accessTokenKey);
    await _storage.delete(_refreshTokenKey);
  }

  // ── Expiry ──

  /// Returns `true` if a non-expired access token exists.
  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return false;
    final expiry = _decodeExpiry(token);
    if (expiry == null) return false;
    // Consider expired 30 s early to account for clock skew / latency.
    return expiry.isAfter(DateTime.now().add(const Duration(seconds: 30)));
  }

  /// Decode the `exp` claim from a JWT without a third-party package.
  /// Returns `null` if the token is malformed.
  DateTime? _decodeExpiry(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;

      // JWT base64url → standard base64
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      final exp = json['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
```

> **Note:** `SecureStorage` uses the generic key-value interface with `read(key)`, `write(key, value)`, `delete(key)`, `deleteAll()` — see [template-storage.md](template-storage.md).
