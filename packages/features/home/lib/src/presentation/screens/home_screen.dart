import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_contracts/shared_contracts.dart';

import '../../domain/home_data.dart';
import '../../locator.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home_body.dart';

/// The Home dashboard (SM-004, F01-S15/S16). Navigation targets are injected
/// by the host app's router.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    this.onCreateStamp,
    this.onOpenAlbum,
    this.onOpenLetters,
    this.onOpenStamp,
    this.onOpenLetter,
    super.key,
  });

  final VoidCallback? onCreateStamp;
  final VoidCallback? onOpenAlbum;

  /// "Thư gần đây" see-all → the sent-letters tab (SM-021).
  final VoidCallback? onOpenLetters;

  /// Tapping a single recent stamp / letter card opens that item.
  final ValueChanged<StampRef>? onOpenStamp;
  final ValueChanged<HomeLetterItem>? onOpenLetter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(const HomeLoadRequested()),
      child: HomeBody(
        onCreateStamp: onCreateStamp,
        onOpenAlbum: onOpenAlbum,
        onOpenLetters: onOpenLetters,
        onOpenStamp: onOpenStamp,
        onOpenLetter: onOpenLetter,
      ),
    );
  }
}
