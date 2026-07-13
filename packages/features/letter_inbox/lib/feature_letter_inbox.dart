/// StampMail Letter Inbox feature: open a received letter from its share link
/// and save its stamps to the album (SM-017, 019).
///
/// The host app wires `FeatureLetterInboxPackageModule` and routes incoming
/// `app_links` deep links to `InboxRepository.open`. Depends on `feature_album`
/// to save received stamps (single-consumer capability import).
library;

export 'src/di.module.dart' show FeatureLetterInboxPackageModule;
export 'src/domain/entities/inbox_entry.dart';
export 'src/domain/entities/received_letter.dart';
export 'src/domain/repositories/inbox_repository.dart';
export 'src/presentation/bloc/inbox_list_cubit.dart';
export 'src/presentation/bloc/reveal_cubit.dart';
export 'src/presentation/bloc/reveal_state.dart';
export 'src/presentation/screens/inbox_list_page.dart';
export 'src/presentation/screens/inbox_list_screen.dart';
export 'src/presentation/screens/letter_reveal_screen.dart';
export 'src/presentation/widgets/envelope_reveal.dart';
export 'src/presentation/widgets/opened_letter_view.dart';
