import 'package:analytics/analytics.dart';
import 'package:architecture/architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/delete_account.dart';
import 'delete_account_state.dart';

@injectable
class DeleteAccountCubit extends Cubit<DeleteAccountState> with SafeEmitMixin {
  DeleteAccountCubit(this._deleteAccount, this._analytics)
    : super(const DeleteAccountState.initial());

  final DeleteAccountUseCase _deleteAccount;
  final AnalyticsService _analytics;

  Future<void> submit() async {
    if (state is DeleteAccountSubmitting) return;

    emit(const DeleteAccountState.submitting());

    final result = await _deleteAccount();

    // The delete can outlive this cubit (the user may navigate away mid-flight),
    // so guard the post-await emits against emit-after-close.
    switch (result) {
      case Ok():
        _analytics.trackAccountDeleted().fire();
        _analytics.setCurrentUser(null).fire();
        safeEmit(const DeleteAccountState.success());
      case Err(:final failure):
        safeEmit(DeleteAccountState.failure(failure));
    }
  }
}
