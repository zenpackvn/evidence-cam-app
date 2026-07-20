/// Supplies a fresh bearer token for outgoing authenticated requests.
///
/// The auth feature binds this to Firebase's `getIdToken()` (which caches the
/// ID token and only hits the network when it's near expiry), so the network
/// package attaches a valid token without importing `firebase_auth` — keeping
/// the layering `network → (callback) → auth` rather than the reverse.
///
/// Returns `null` when no user is signed in.
typedef TokenProvider = Future<String?> Function();

/// Network-owned holder the auth interceptor reads for a fresh bearer token.
///
/// Registered as a singleton by the network package (default: no provider →
/// falls back to the persisted token store). The auth feature, once Firebase is
/// available, calls [bind] to point it at `getIdToken()`. This one-way binding
/// avoids a circular DI dependency: the network `Dio` doesn't depend on the
/// auth package; auth mutates this holder after startup instead.
class AuthTokenProvider {
  AuthTokenProvider();

  TokenProvider? _provider;

  /// Points the holder at a token source (Firebase). Idempotent.
  // ignore: use_setters_to_change_properties
  void bind(TokenProvider provider) => _provider = provider;

  /// A fresh bearer token, or null when unbound / signed out.
  Future<String?> getToken() async => _provider == null ? null : _provider!();

  bool get isBound => _provider != null;
}
