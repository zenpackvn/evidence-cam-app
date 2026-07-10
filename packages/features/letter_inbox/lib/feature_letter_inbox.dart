/// StampMail Letter Inbox feature: open a received letter from its share link
/// and save its stamps to the album (SM-017, 019).
///
/// The host app wires `FeatureLetterInboxPackageModule` and routes incoming
/// `app_links` deep links to `InboxRepository.open`. Depends on `feature_album`
/// to save received stamps (single-consumer capability import).
library;

export 'src/di.module.dart' show FeatureLetterInboxPackageModule;
export 'src/domain/entities/received_letter.dart';
export 'src/domain/repositories/inbox_repository.dart';
