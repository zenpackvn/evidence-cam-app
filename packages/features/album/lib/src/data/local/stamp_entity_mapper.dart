import 'package:database/database.dart';

import '../../domain/entities/stamp.dart';

/// Maps the persistence [StampEntity] to/from the domain [Stamp]. Lives in the
/// feature data layer so the dependency direction stays `feature → database`.
extension StampEntityMapper on StampEntity {
  Stamp toDomain() => Stamp(
    id: uuid,
    imageUrl: imageUrl,
    thumbUrl: thumbUrl == null || thumbUrl!.isEmpty ? null : thumbUrl,
    name: name,
    source: StampSource.fromWire(source),
    senderName: senderName == null || senderName!.isEmpty ? null : senderName,
    senderUid: senderUid == null || senderUid!.isEmpty ? null : senderUid,
    createdAt: createdAt,
    isPendingSync: syncState.isPending,
  );
}
