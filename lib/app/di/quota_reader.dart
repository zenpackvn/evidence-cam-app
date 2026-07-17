import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';
import 'package:shared_contracts/shared_contracts.dart';

/// Reads the current user's remaining monthly quota from `GET /api/sm/quota`
/// (SM-030). Lives in the app shell so `shared_contracts` stays transport-free
/// and features depend only on the [QuotaReader] contract. Premium returns
/// [QuotaRemaining.unlimited] (the server sends -1/-1).
@LazySingleton(as: QuotaReader)
class ApiQuotaReader extends QuotaReader {
  ApiQuotaReader(this._dio);

  final Dio _dio;

  @override
  Future<Result<QuotaRemaining>> call([NoParams param = noParams]) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/sm/quota');
      final data = res.data ?? const {};
      return Ok(
        QuotaRemaining(
          stamps: (data['stamps_remaining'] as num?)?.toInt() ?? -1,
          letters: (data['letters_remaining'] as num?)?.toInt() ?? -1,
        ),
      );
    } on DioException catch (e) {
      return Err(UnknownFailure(e.message ?? 'Không tải được hạn mức.'));
    }
  }
}
