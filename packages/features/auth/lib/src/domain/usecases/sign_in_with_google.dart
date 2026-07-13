import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_contracts/shared_contracts.dart';

import '../repositories/auth_repository.dart';

/// Interactive Google sign-in (SM-001 BR-24): Firebase's Google provider,
/// then the StampMail profile load — all inside the repository.
@injectable
class SignInWithGoogleUseCase extends UseCase<void, AuthUser> {
  const SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthUser>> call([void param]) {
    return runResultGuarded(_repository.signInWithGoogle);
  }
}
