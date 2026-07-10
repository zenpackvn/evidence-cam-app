import 'package:database/database.dart';
import 'package:rev_sync/rev_sync.dart';

import '../../domain/entities/album.dart';

/// Maps the persistence [AlbumEntity] to/from the domain [Album].
extension AlbumEntityMapper on AlbumEntity {
  Album toDomain() => Album(
    id: uuid,
    name: name,
    stampIds: List.unmodifiable(stampIds),
    createdAt: createdAt,
    updatedAt: updatedAt,
    isPendingSync: syncState.isPending,
    isConflicted: syncState == SyncState.conflicted,
    isFailed: syncState == SyncState.failed,
  );

  /// Mutates this entity from an [AlbumInput]. Bumps `updatedAt`; leaves
  /// `createdAt` alone so updates preserve it.
  void applyInput(AlbumInput input, {required DateTime now}) {
    name = input.name;
    stampIds = List.of(input.stampIds);
    updatedAt = now;
  }
}
