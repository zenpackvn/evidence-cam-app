import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:network/network.dart';
import 'package:shared_contracts/shared_contracts.dart';

import '../../domain/entities/received_letter.dart';
import '../../domain/repositories/inbox_repository.dart';
import '../datasources/inbox_remote_data_source.dart';
import '../models/public_letter_dto.dart';

@LazySingleton(as: InboxRepository)
class InboxRepositoryImpl implements InboxRepository {
  InboxRepositoryImpl(this._remote);

  final InboxRemoteDataSource _remote;

  @override
  Future<OpenLetterOutcome> open(String linkId, {String? viewerUid}) async {
    try {
      final dto = await _remote.open(linkId, viewerUid);
      return LetterOpened(_toReceived(dto));
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final serverCode = _codeOf(e.response?.data);
      // 410 covers both already-opened and expired; the body's code
      // distinguishes them (SM-017 AC-03/AC-05).
      if (code == 410) {
        return serverCode == 'expired'
            ? const LetterExpired()
            : const LetterAlreadyOpened();
      }
      if (code == 404) return const LetterInvalid();
      rethrow;
    }
  }

  ReceivedLetter _toReceived(PublicLetterDto dto) {
    final decoded = _decodeContent(dto.contentJson);
    return ReceivedLetter(
      id: dto.id,
      templateId: decoded.templateId,
      text: decoded.text,
      stamps: [
        for (final s in dto.stamps)
          StampRef(
            id: s.id,
            imageUrl: s.imageUrl,
            thumbUrl: s.thumbUrl.isEmpty ? null : s.thumbUrl,
            createdAt: dto.createdAt,
          ),
      ],
      createdAt: dto.createdAt,
    );
  }

  ({String templateId, String text}) _decodeContent(String contentJson) {
    if (contentJson.isEmpty) return (templateId: 'classic', text: '');
    try {
      final decoded = jsonDecode(contentJson);
      if (decoded is Map<String, dynamic>) {
        return (
          templateId: (decoded['template_id'] as String?) ?? 'classic',
          text: (decoded['text'] as String?) ?? '',
        );
      }
    } on FormatException {
      // fall through
    }
    return (templateId: 'classic', text: '');
  }

  String? _codeOf(Object? body) {
    if (body is Map<String, dynamic> && body['code'] is String) {
      return body['code'] as String;
    }
    return null;
  }
}
