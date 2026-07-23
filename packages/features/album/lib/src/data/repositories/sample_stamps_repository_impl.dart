import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import '../../domain/entities/sample_stamp.dart';
import '../../domain/repositories/sample_stamps_repository.dart';
import '../datasources/sample_stamps_remote_data_source.dart';

/// Fetches the sample-stamp catalog from the backend (SM-035). Online-only: the
/// catalog is browse-content, cached by the HTTP layer; a network error surfaces
/// so the UI can show the offline banner (BR-08).
@LazySingleton(as: SampleStampsRepository)
class SampleStampsRepositoryImpl implements SampleStampsRepository {
  SampleStampsRepositoryImpl(this._remote);

  final SampleStampsRemoteDataSource _remote;

  @override
  Future<Result<List<SampleStamp>>> list({String? theme}) async {
    try {
      final dtos = await _remote.list(theme: theme);
      return Ok([
        for (final d in dtos)
          SampleStamp(
            id: d.id,
            name: d.name,
            imageUrl: d.imageUrl,
            thumbUrl: d.thumbUrl.isEmpty ? d.imageUrl : d.thumbUrl,
            theme: d.theme,
            isNew: d.isNew,
          ),
      ]);
    } on DioException catch (e) {
      return Err(UnknownFailure(e.message ?? 'Không tải được tem mẫu.'));
    }
  }
}
