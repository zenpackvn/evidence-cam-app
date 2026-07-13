import 'package:architecture/architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/inbox_entry.dart';
import '../../domain/repositories/inbox_repository.dart';

/// Loads the received-letters list for the inbox tab (SM-018, F04-S07).
@injectable
class InboxListCubit extends Cubit<InboxListState> {
  InboxListCubit(this._inbox) : super(const InboxListState(isLoading: true));

  final InboxRepository _inbox;

  Future<void> load() async {
    emit(const InboxListState(isLoading: true));
    final result = await _inbox.list();
    switch (result) {
      case Ok(value: final entries):
        emit(InboxListState(entries: entries));
      case Err(:final failure):
        emit(InboxListState(error: failure.message));
    }
  }
}

class InboxListState {
  const InboxListState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
  });

  final List<InboxEntry> entries;
  final bool isLoading;
  final String? error;

  int get unread => entries.where((e) => !e.read).length;
}
