/// Home feature: the StampMail dashboard (SM-004, F01-S15/S16).
///
/// The host app wires `FeatureHomePackageModule` via
/// `externalPackageModulesBefore`, registers a `HomeDataLoader` that reads the
/// album / letters / inbox features, and mounts the exported `HomeScreen` in
/// its router. The home package itself imports no other feature.
library;

export 'src/di.module.dart' show FeatureHomePackageModule;
export 'src/domain/home_data.dart';
export 'src/presentation/bloc/home_bloc.dart';
export 'src/presentation/bloc/home_state.dart';
export 'src/presentation/screens/home_screen.dart';
export 'src/presentation/widgets/home_body.dart';
