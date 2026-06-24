import 'dart:math';

import 'package:dio/dio.dart';

/// Attaches a stable `Idempotency-Key` to mutating requests so the server can
/// safely dedupe retries.
///
/// The retry interceptor only auto-replays idempotent methods (GET/PUT/DELETE)
/// after an ambiguous failure; POST/PATCH are left to the caller. When a caller
/// *does* retry a POST — or a proxy silently re-sends one — a per-request key
/// lets the backend recognise the duplicate and return the original result
/// instead of creating a second resource. The key is generated once and stored
/// in [RequestOptions.extra], so a retry of the *same* request reuses it (a new
/// logical request gets a new key).
///
/// This is the client half of the contract; the server must honour the header
/// (look up the key, replay the stored response on a repeat). Header name and
/// method set match the common convention.
class IdempotencyInterceptor extends Interceptor {
  IdempotencyInterceptor({Random? random}) : _random = random ?? Random.secure();

  static const headerName = 'Idempotency-Key';
  static const _keyExtra = '__idempotency_key__';
  static const _methods = <String>{'POST', 'PATCH'};

  final Random _random;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_methods.contains(options.method.toUpperCase())) {
      // Reuse an existing key across retries; mint one on first sight.
      final key = (options.extra[_keyExtra] as String?) ?? _newKey();
      options.extra[_keyExtra] = key;
      options.headers[headerName] = key;
    }
    handler.next(options);
  }

  /// 128 bits of randomness as lowercase hex — unique enough to key a request
  /// without pulling in a UUID dependency.
  String _newKey() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
