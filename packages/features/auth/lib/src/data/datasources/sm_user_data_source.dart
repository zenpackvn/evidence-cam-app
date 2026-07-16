import 'package:injectable/injectable.dart';
import 'package:network/network.dart';
import 'package:shared_contracts/shared_contracts.dart';

/// Reads the StampMail profile from the backend (`GET /api/sm/me`).
///
/// The backend provisions a Free profile lazily on first authenticated call
/// (auto-EnsureUser in the `smAuth` middleware), so calling this right after a
/// Firebase sign-in returns the user's profile — no separate register step.
@lazySingleton
class SmUserDataSource {
  SmUserDataSource(this._dio);

  final Dio _dio;

  /// Fetches the current user's profile. Requires a valid bearer token, which
  /// the auth interceptor attaches from Firebase.
  Future<AuthUser> me() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/sm/me');
    final body = res.data;
    if (body == null) {
      throw const FormatException('empty /api/sm/me body');
    }
    final id = body['id'];
    final username = body['username'];
    if (id is! String || username is! String) {
      throw const FormatException('missing id/username in /api/sm/me');
    }
    return AuthUser(
      id: id,
      username: username,
      stampsCreated: switch (body['stamps_created']) {
        final int n => n,
        _ => 0,
      },
      lettersSent: switch (body['letters_sent']) {
        final int n => n,
        _ => 0,
      },
    );
  }
}
