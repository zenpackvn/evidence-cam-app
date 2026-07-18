import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

/// Signs the user out on every device (SM-027).
///
/// Distinct from `SignOutUseCase`, which only ends the session on this device
/// and is best-effort. This one fails loudly, because a silent failure would
/// leave the user believing their other sessions are gone.
@injectable
class SignOutAllDevicesUseCase extends NoParamUseCase<void> {
  const SignOutAllDevicesUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call([NoParams param = noParams]) {
    return runResultGuarded(_repository.signOutAllDevices);
  }
}
