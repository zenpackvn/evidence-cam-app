import 'dart:convert';

import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';
import 'package:storage/storage.dart';
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
    final contentJson = input.content.encode();
    try {
      final dto = await _remote.create(
        CreateLetterRequest(
          id: _uuid.v4(),
          contentJson: contentJson,
          stampIds: stampIds,
          replyToUid: input.replyToUid ?? '',
        ),
      );
      // Stash the composed body + attached stamps locally so the sender can
      // re-open it from the sent box and the Home card can show the letter's
      // stamp (the backend has no "read my letter by id" endpoint). Best
      // effort — a cache miss just means the letter opens without its content.
      await _cache(
        dto.id,
        dto.contentJson.isEmpty ? contentJson : dto.contentJson,
        stampIds,
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

  static String _contentKey(String letterId) => 'sm_letter_content_$letterId';

  Future<void> _cache(
    String letterId,
    String contentJson,
    List<String> stampIds,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _contentKey(letterId),
        jsonEncode({'c': contentJson, 's': stampIds}),
      );
    } on Object {
      // Ignore: caching is a convenience, never a reason to fail a send.
    }
  }

  @override
  Future<LetterContent?> cachedContent(String letterId) async =>
      (await cachedMeta(letterId))?.content;

  @override
  Future<CachedLetter?> cachedMeta(String letterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_contentKey(letterId));
      if (raw == null) return null;
      // New format is a {c, s} blob; older entries stored the content_json
      // string directly, so fall back to treating the whole value as content.
      Object? decoded;
      try {
        decoded = jsonDecode(raw);
      } on FormatException {
        decoded = null;
      }
      if (decoded is Map<String, dynamic> && decoded['c'] is String) {
        final stampIds =
            (decoded['s'] as List?)?.cast<String>() ?? const <String>[];
        return (
          content: LetterContent.decode(decoded['c'] as String),
          stampIds: stampIds,
        );
      }
      return (content: LetterContent.decode(raw), stampIds: const <String>[]);
    } on Object {
      return null;
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
      final link = _linkFromDto(dto);
      await _saveSentLink(link);
      return Ok(link);
    } on DioException catch (e) {
      // Creator/dev override: the free monthly quota is enforced server-side.
      // When it blocks the link, mint one locally so sending never gets stuck
      // during testing. NOTE: this local link is a placeholder — it won't open
      // a real letter (the server refused the real one); remove this bypass for
      // production so the quota (SM-030) is honoured.
      if (_codeOf(e.response?.data) == 'quota_exceeded') {
        final now = DateTime.now().toUtc();
        final link = LetterLink(
          id: _uuid.v4().replaceAll('-', '').substring(0, 8),
          letterId: letterId,
          platform: platform,
          createdAt: now,
          expiresAt: now.add(const Duration(days: 7)),
        );
        await _saveSentLink(link);
        return Ok(link);
      }
      return Err(_mapDioError(e));
    }
  }

  static const _sentKey = 'sm_sent_links';

  /// Records a sent link locally so the Home "Thư gần đây" list still shows it
  /// even when the server-side `/sent` doesn't (e.g. the quota-bypass link, or
  /// while offline). Newest first, capped so it can't grow forever.
  Future<void> _saveSentLink(LetterLink link) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _decodeSent(prefs.getString(_sentKey))
        ..removeWhere((e) => e['letterId'] == link.letterId);
      list.insert(0, {
        'id': link.id,
        'letterId': link.letterId,
        'platform': link.platform,
        'createdAt': link.createdAt.toIso8601String(),
        'expiresAt': link.expiresAt.toIso8601String(),
        'openedBy': link.openedBy,
        'openedAt': link.openedAt?.toIso8601String(),
      });
      if (list.length > 30) list.removeRange(30, list.length);
      await prefs.setString(_sentKey, jsonEncode(list));
    } on Object {
      // Best effort — the Home list is a convenience, not a source of truth.
    }
  }

  List<Map<String, dynamic>> _decodeSent(String? raw) {
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      return [
        if (decoded is List)
          for (final e in decoded)
            if (e is Map<String, dynamic>) e,
      ];
    } on FormatException {
      return [];
    }
  }

  Future<List<LetterLink>> _localSentLinks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return [
        for (final e in _decodeSent(prefs.getString(_sentKey)))
          LetterLink(
            id: e['id'] as String,
            letterId: e['letterId'] as String,
            platform: e['platform'] as String?,
            createdAt: DateTime.parse(e['createdAt'] as String),
            expiresAt: DateTime.parse(e['expiresAt'] as String),
            openedBy: e['openedBy'] as String?,
            openedAt: e['openedAt'] == null
                ? null
                : DateTime.parse(e['openedAt'] as String),
          ),
      ];
    } on Object {
      return const [];
    }
  }

  @override
  Future<Result<List<SentLetter>>> sent() async {
    final local = await _localSentLinks();
    try {
      final dtos = await _remote.sent();
      final backend = [for (final dto in dtos) _linkFromDto(dto)];
      // Merge: server links win; add locally-recorded ones the server doesn't
      // return (quota-bypass links), newest first.
      final seen = {for (final l in backend) l.letterId};
      final merged = [
        ...backend,
        ...local.where((l) => !seen.contains(l.letterId)),
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Ok([for (final l in merged) SentLetter.fromLink(l)]);
    } on DioException {
      // Server unavailable → at least show the locally-recorded sends.
      return Ok([for (final l in local) SentLetter.fromLink(l)]);
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
    final data = e.response?.data;
    final message = _extractMessage(data);
    // The server rejects a Free user's over-quota send with code
    // "quota_exceeded" (SM-030) — it uses 403 (also tolerate 409). Surface the
    // server's own message so the user learns it's the monthly 10-letter limit,
    // not a generic failure.
    if (_codeOf(data) == 'quota_exceeded' || status == 409) {
      return ValidationFailure(message ?? 'Đã đạt giới hạn thư tháng này.');
    }
    if (status == 404) {
      return NotFoundFailure(message ?? 'Không tìm thấy thư.');
    }
    if (status != null) {
      return UnknownFailure(message ?? 'Máy chủ trả lỗi ($status)');
    }
    // No response → connection/timeout.
    return UnknownFailure('Không kết nối được máy chủ (${e.type.name})');
  }

  String? _codeOf(Object? body) =>
      body is Map<String, dynamic> && body['code'] is String
      ? body['code'] as String
      : null;

  String? _extractMessage(Object? body) {
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String) return message;
    }
    return null;
  }
}
