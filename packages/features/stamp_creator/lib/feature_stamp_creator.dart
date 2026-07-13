/// Stamp creator feature (SM-005..SM-011): the wizard that turns a photo into a
/// stamp. The host app mounts the wizard at `StampCreatorRoutes.create`; the
/// source picker (SM-005) constructs the wizard with the chosen photo.
///
/// Flow: source pick → filter (SM-006) → decorate (SM-008/009) → preview
/// (SM-010) → save (SM-011). Color filters use `ColorFilter.matrix`; the save
/// upload to R2 is stubbed until credentials land.
library;

export 'src/di.dart';
export 'src/di.module.dart';
export 'src/domain/borders.dart';
export 'src/domain/filters.dart';
export 'src/domain/stamp_draft.dart';
export 'src/presentation/bloc/creator_cubit.dart';
export 'src/presentation/bloc/creator_state.dart';
export 'src/presentation/screens/library_picker_screen.dart';
export 'src/presentation/screens/save_success_screen.dart';
export 'src/presentation/screens/stamp_source_screen.dart';
export 'src/presentation/screens/stamp_wizard_screen.dart';
export 'src/presentation/stamp_creator_routes.dart';
export 'src/presentation/widgets/creator_theme.dart';
export 'src/presentation/widgets/source_card.dart';
export 'src/presentation/widgets/stamp_frame.dart';
