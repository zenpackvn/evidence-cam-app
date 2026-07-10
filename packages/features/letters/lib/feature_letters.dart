/// StampMail Letters feature: compose a letter, attach stamps, mint a
/// one-time/7-day share link, and track sent status (SM-012..016, 021).
///
/// The host app wires `FeatureLettersPackageModule` via
/// `externalPackageModulesBefore`. Domain types and the repository are
/// exported; data internals stay private.
library;

export 'src/di.module.dart' show FeatureLettersPackageModule;
export 'src/domain/entities/letter.dart';
export 'src/domain/entities/letter_content.dart';
export 'src/domain/entities/letter_link.dart';
export 'src/domain/repositories/letters_repository.dart';
export 'src/domain/services/letter_share.dart';
