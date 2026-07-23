import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/sent_letters_cubit.dart';
import 'sent_letter_detail_screen.dart';
import 'sent_letters_screen.dart';

/// Hosts [SentLettersScreen] behind [SentLettersCubit] (SM-021 — the whole
/// "Thư" tab). A row tap opens the "xem thư đã gửi" detail, which reads from
/// this page's cubit so a link renewal there refreshes the list behind it.
class SentLettersPage extends StatelessWidget {
  const SentLettersPage({required this.createCubit, this.onCompose, super.key});

  /// Builds the cubit (from the host's DI); the page owns and disposes it.
  final SentLettersCubit Function() createCubit;

  /// Forwarded to the empty state's "Tạo thư đầu tiên" CTA (F04-S07d).
  final VoidCallback? onCompose;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit()..load(),
      child: BlocBuilder<SentLettersCubit, SentLettersState>(
        builder: (context, state) => SentLettersScreen(
          letters: state.letters,
          onCompose: onCompose,
          onRefresh: context.read<SentLettersCubit>().load,
          onView: (sent) {
            final cubit = context.read<SentLettersCubit>();
            Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: SentLetterDetailScreen(
                    letterId: sent.link.letterId,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
