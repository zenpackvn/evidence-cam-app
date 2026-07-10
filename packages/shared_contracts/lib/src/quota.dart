import 'package:architecture/architecture.dart';

/// How many stamps and letters a Free user has left this month, for the
/// low-quota nudge (SM-030). Mirrors the server's `QuotaService.Remaining`,
/// which returns `-1` for Premium (unlimited).
class QuotaRemaining {
  const QuotaRemaining({required this.stamps, required this.letters});

  /// Unlimited quota, used for Premium users.
  static const unlimited = QuotaRemaining(stamps: -1, letters: -1);

  /// Stamps left to save this month, or `-1` when unlimited.
  final int stamps;

  /// Letters left to send this month, or `-1` when unlimited.
  final int letters;

  bool get isUnlimited => stamps < 0 || letters < 0;
}

/// Reads the current user's remaining monthly quota. Implemented by the premium
/// feature (or an app-level reader over `GET /api/sm/me`) and consumed through
/// `shared` by the stamp creator and letters features to show the low-quota
/// nudge and block over-limit actions before hitting the server.
abstract class QuotaReader extends NoParamUseCase<QuotaRemaining> {
  const QuotaReader();
}
