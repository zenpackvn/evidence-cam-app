/// StampMail Letter Reveal feature: open a received letter from its share link
/// and save its stamps to the album (SM-017, 019). Received letters are never
/// stored for the recipient (SM-017 BR-10) — there is no inbox.
///
/// The host app wires `FeatureLetterInboxPackageModule` and routes incoming
/// `app_links` deep links to `InboxRepository.open`. Received stamps are never
/// saved to the recipient's album (SM-017 BR-05), so this feature has no
/// dependency on `feature_album`.
library;

export 'src/di.module.dart' show FeatureLetterInboxPackageModule;
export 'src/domain/entities/received_letter.dart';
export 'src/domain/repositories/inbox_repository.dart';
export 'src/presentation/bloc/reveal_cubit.dart';
export 'src/presentation/bloc/reveal_state.dart';
export 'src/presentation/screens/letter_reveal_screen.dart';
export 'src/presentation/widgets/envelope_reveal.dart';
export 'src/presentation/widgets/opened_letter_view.dart';
