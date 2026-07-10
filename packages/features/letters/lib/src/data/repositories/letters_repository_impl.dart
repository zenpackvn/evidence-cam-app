import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/letter.dart';
import '../../domain/entities/letter_content.dart';
import '../../domain/entities/letter_link.dart';
import '../../domain/repositories/letters_repository.dart';
import '../datasources/letters_remote_data_source.dart';
import '../models/letter_requests.dart';
import '../models/link_dto.dart';

@LazySingleton(as: LettersRepository)
class LettersRepositoryImpl implements LettersRepository {
  LettersRepositoryImpl(this._remote, this._uuid);

  final LettersRemoteDataSource _remote;
  final Uuid _uuid;

  @override
  Future<Result<Letter>> create(LetterInput input) async {
    final stampIds = _dedupeCap(input.stampIds, LetterInput.maxStamps);
    try {
      final dto = await _remote.create(
        CreateLetterRequest(
          id: _uuid.v4(),
          contentJson: input.content.encode(),
          stampIds: stampIds,
        ),
      );
      return Ok(
        Letter(
          id: dto.id,
          content: LetterContent.decode(dto.contentJson),
          stampIds: List.of(dto.stampIds),
          createdAt: dto.createdAt,
        ),
      );
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    }
  }

  @override
  Future<Result<LetterLink>> createLink(
    String letterId, {
    String? platform,
  }) async {
    try {
      final dto = await _remote.createLink(
        letterId,
        CreateLinkRequest(platform: platform ?? ''),
      );
      return Ok(_linkFromDto(dto));
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    }
  }

  @override
  Future<Result<List<SentLetter>>> sent() async {
    try {
      final dtos = await _remote.sent();
      return Ok([
        for (final dto in dtos) SentLetter.fromLink(_linkFromDto(dto)),
      ]);
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    }
  }

  LetterLink _linkFromDto(LinkDto dto) => LetterLink(
    id: dto.id,
    letterId: dto.letterId,
    platform: dto.platform.isEmpty ? null : dto.platform,
    createdAt: dto.createdAt,
    expiresAt: dto.expiresAt,
    openedBy: dto.openedBy,
    openedAt: dto.openedAt,
  );

  List<String> _dedupeCap(List<String> ids, int cap) {
    final seen = <String>{};
    final out = <String>[];
    for (final raw in ids) {
      final id = raw.trim();
      if (id.isEmpty || !seen.add(id)) continue;
      out.add(id);
      if (out.length == cap) break;
    }
    return out;
  }

  Failure _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    final message = _extractMessage(e.response?.data);
    // The server returns 409 with code "quota_exceeded" when a Free user hits
    // the monthly send limit (SM-030); surface it as a validation failure so
    // the UI can show the quota nudge.
    if (status == 409) {
      return ValidationFailure(message ?? 'Đã đạt giới hạn thư tháng này.');
    }
    if (status == 404) {
      return NotFoundFailure(message ?? 'Không tìm thấy thư.');
    }
    return UnknownFailure(e.message ?? 'Network error');
  }

  String? _extractMessage(Object? body) {
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String) return message;
    }
    return null;
  }
}
