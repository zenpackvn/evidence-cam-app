/// Profile feature: the user's own account — the SM-024 profile and its edit
/// form, plus the settings surfaces.
///
/// The host app wires `FeatureProfilePackageModule` via
/// `externalPackageModulesBefore` and mounts the exported screens in its
/// router. Profile surfaces auth's delete-account flow as a single-consumer
/// capability and owns its own reaction to it (snackbars, session clearing).
library;

export 'src/di.module.dart' show FeatureProfilePackageModule;
export 'src/domain/entities/birth_date.dart';
export 'src/domain/entities/user_profile.dart';
export 'src/domain/repositories/profile_repository.dart';
export 'src/presentation/bloc/edit_profile_cubit.dart';
export 'src/presentation/bloc/edit_profile_state.dart';
export 'src/presentation/bloc/profile_bloc.dart';
export 'src/presentation/bloc/profile_state.dart';
export 'src/presentation/screens/crop_avatar_screen.dart';
export 'src/presentation/screens/delete_account_screen.dart';
export 'src/presentation/screens/edit_profile_screen.dart';
export 'src/presentation/screens/language_screen.dart';
export 'src/presentation/screens/notification_settings_screen.dart';
export 'src/presentation/screens/profile_screen.dart';
export 'src/presentation/screens/settings_screen.dart';
export 'src/presentation/screens/stampmail_profile_screen.dart';
