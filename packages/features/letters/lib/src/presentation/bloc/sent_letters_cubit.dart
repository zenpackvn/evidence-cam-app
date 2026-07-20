import 'package:architecture/architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/letter_link.dart';
import '../../domain/repositories/letters_repository.dart';

/// Loads the sent-letters list for the "Thư" tab (SM-021, F04-S07d). The tab
/// is sent-only: received letters are never stored (SM-017 BR-10), so there is
/// no inbox to show.
@injectable
class SentLettersCubit extends Cubit<SentLettersState> {
  SentLettersCubit(this._letters)
    : super(const SentLettersState(isLoading: true));

  final LettersRepository _letters;

  Future<void> load() async {
    emit(const SentLettersState(isLoading: true));
    final result = await _letters.sent();
    switch (result) {
      case Ok(value: final letters):
        emit(SentLettersState(letters: letters));
      case Err(:final failure):
        emit(SentLettersState(error: failure.message));
    }
  }

  /// Recreates a share link for an expired letter (SM-021 BR-04) and reloads.
  /// Blocked for an already-opened letter (BR-05) — it has already reached its
  /// recipient. Returns whether a new link was minted.
  Future<bool> recreateLink(SentLetter sent) async {
    if (sent.status == SentStatus.opened) return false; // BR-05
    emit(state.copyWith(recreatingLetterId: sent.link.letterId));
    final result = await _letters.createLink(
      sent.link.letterId,
      platform: sent.link.platform,
    );
    emit(state.copyWith(clearRecreating: true));
    if (result is Ok) {
      await load();
      return true;
    }
    return false;
  }
}

class SentLettersState {
  const SentLettersState({
    this.letters = const [],
    this.isLoading = false,
    this.error,
    this.recreatingLetterId,
  });

  final List<SentLetter> letters;
  final bool isLoading;
  final String? error;

  /// The letterId whose link is currently being recreated (BR-04), or null.
  final String? recreatingLetterId;

  SentLettersState copyWith({
    String? recreatingLetterId,
    bool clearRecreating = false,
  }) => SentLettersState(
    letters: letters,
    isLoading: isLoading,
    error: error,
    recreatingLetterId: clearRecreating
        ? null
        : (recreatingLetterId ?? this.recreatingLetterId),
  );
}
