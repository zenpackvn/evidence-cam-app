import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../locator.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home_body.dart';

/// The Home dashboard (SM-004, F01-S15/S16). Navigation targets are injected
/// by the host app's router.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    this.onCreateStamp,
    this.onOpenAlbum,
    this.onOpenInbox,
    super.key,
  });

  final VoidCallback? onCreateStamp;
  final VoidCallback? onOpenAlbum;
  final VoidCallback? onOpenInbox;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(const HomeLoadRequested()),
      child: HomeBody(
        onCreateStamp: onCreateStamp,
        onOpenAlbum: onOpenAlbum,
        onOpenInbox: onOpenInbox,
      ),
    );
  }
}
