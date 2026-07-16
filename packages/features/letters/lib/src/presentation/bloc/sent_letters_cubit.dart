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
}

class SentLettersState {
  const SentLettersState({
    this.letters = const [],
    this.isLoading = false,
    this.error,
  });

  final List<SentLetter> letters;
  final bool isLoading;
  final String? error;
}
