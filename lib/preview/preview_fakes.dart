// Fakes for the design-review preview harness (`lib/preview_all.dart`).
//
// Everything here exists so every screen can be opened with believable data
// and every design state (empty / loaded / error / quota / locked …) can be
// forced without a backend. Not shipped: only `preview_all.dart` imports it.
//
// ignore_for_file: implementation_imports
import 'package:analytics/analytics.dart';
import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_auth/src/domain/repositories/auth_repository.dart';
import 'package:feature_auth/src/domain/usecases/change_password.dart';
import 'package:feature_auth/src/domain/usecases/delete_account.dart';
import 'package:feature_auth/src/domain/usecases/register.dart';
import 'package:feature_auth/src/domain/usecases/restore_session.dart';
import 'package:feature_auth/src/domain/usecases/sign_in.dart';
import 'package:feature_auth/src/domain/usecases/sign_in_with_google.dart';
import 'package:feature_auth/src/domain/usecases/sign_out.dart';
import 'package:feature_auth/src/presentation/bloc/change_password_cubit.dart';
import 'package:feature_home/feature_home.dart';
import 'package:feature_letter_inbox/feature_letter_inbox.dart';
import 'package:feature_letters/feature_letters.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:feature_stamp_creator/src/data/stamp_uploader.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:network/network.dart';
import 'package:rev_sync/rev_sync.dart';
import 'package:shared_contracts/shared_contracts.dart';

/// Latency added to fake calls so loading states are visible during review.
const _lag = Duration(milliseconds: 350);

String _img(String seed, {int w = 300, int h = 380}) =>
    'https://picsum.photos/seed/$seed/$w/$h';

// ─────────────────────────────────────────────────────────────── switches ──

/// Mutable switches the gallery flips before pushing a screen, so one fake
/// serves every design state (empty album, quota reached, home empty …).
class PreviewSwitches {
  /// Album/Home return no stamps (F01-S15, F02-S19).
  bool emptyStamps = false;

  /// Home returns no letters either (F01-S15).
  bool emptyLetters = false;

  /// Stamp save fails with the quota message (F02-S13).
  bool quotaReached = false;

  /// Sign-in always fails with invalid credentials (F01-S04).
  bool loginFails = false;

  /// Sign-in fails with the temporary-lock failure (F01-S05).
  bool loginLocked = false;
}

final previewSwitches = PreviewSwitches();

// ──────────────────────────────────────────────────────────────── session ──

class FakeSession extends ChangeNotifier implements Session {
  @override
  AuthUser? currentUser = const AuthUser(id: 'u1', username: 'sunny.daily');

  @override
  bool get isSigningOut => false;

  @override
  Future<void> restore() async {}

  @override
  void signOut() {}

  @override
  void clearSession() {}
}

// ─────────────────────────────────────────────────────────────────── auth ──

class FakeAuthRepository implements AuthRepository {
  static const _user = AuthUser(id: 'u1', username: 'sunny.daily');

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<Result<void>> sendEmailVerification() async => const Ok(null);

  @override
  Future<Result<bool>> checkEmailVerified() async => const Ok(true);

  @override
  Future<Result<void>> sendPasswordReset(String email) async => const Ok(null);

  @override
  Future<Result<AuthUser>> signIn({
    required String username,
    required String password,
  }) async {
    await Future<void>.delayed(_lag * 3);
    if (previewSwitches.loginLocked) {
      return const Err(PermissionFailure('Tài khoản bị khoá tạm thời.'));
    }
    if (previewSwitches.loginFails) {
      return const Err(
        InvalidCredentialsFailure('Email hoặc mật khẩu không đúng.'),
      );
    }
    return const Ok(_user);
  }

  @override
  Future<Result<AuthUser>> register({
    required String username,
    required String password,
  }) async {
    await Future<void>.delayed(_lag * 3);
    return const Ok(_user);
  }

  @override
  Future<Result<AuthUser>> signInWithGoogle() async => const Ok(_user);

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(_lag * 2);
    if (currentPassword == 'sai') {
      return const Err(InvalidCredentialsFailure('Mật khẩu hiện tại sai.'));
    }
    return const Ok(null);
  }

  @override
  Future<Result<void>> signOut() async => const Ok(null);

  @override
  Future<Result<void>> signOutAllDevices() async {
    await Future<void>.delayed(_lag * 2);
    return const Ok(null);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    await Future<void>.delayed(_lag * 2);
    return const Ok(null);
  }

  @override
  Future<Result<AuthUser>> restoreSession() async =>
      const Err(NoSessionFailure());
}

// ─────────────────────────────────────────────────────────────── stamps ──

/// Design content images bundled at the app root (assets/design/), served
/// through the `asset:` scheme AppNetworkImage understands.
String _design(String file) => 'asset:assets/design/$file';

final _fakeStamps = <Stamp>[
  Stamp(
    id: 's1',
    imageUrl: _design('hl-stamp-tulip.png'),
    source: StampSource.created,
    createdAt: DateTime(2024, 5, 20),
  ),
  Stamp(
    id: 's2',
    imageUrl: _design('hl-stamp-daisy.png'),
    source: StampSource.created,
    createdAt: DateTime(2024, 5, 19),
  ),
  Stamp(
    id: 's3',
    imageUrl: _design('hl-stamp-dog.png'),
    source: StampSource.received,
    senderName: 'Mai Anh',
    senderUid: 'u9',
    createdAt: DateTime(2024, 5, 18),
  ),
  Stamp(
    id: 's4',
    imageUrl: _design('hl-stampmini-mom.png'),
    source: StampSource.created,
    createdAt: DateTime(2024, 4, 3),
  ),
];

const _stampNames = [
  'Tulip nở hồng',
  'Ngày nắng đẹp',
  'Cún đáng yêu',
  'Tem của mẹ',
];

class FakeStampsRepository implements StampsRepository {
  @override
  Future<Result<List<Stamp>>> list() async {
    await Future<void>.delayed(_lag);
    return Ok(previewSwitches.emptyStamps ? const [] : _fakeStamps);
  }

  @override
  Future<Result<List<Stamp>>> listLocal() => list();

  @override
  Future<Result<Stamp>> get(String id) async => Ok(
    _fakeStamps.firstWhere((s) => s.id == id, orElse: () => _fakeStamps.first),
  );

  @override
  Future<Result<Stamp>> save(StampInput input) async {
    await Future<void>.delayed(_lag * 2);
    if (previewSwitches.quotaReached) {
      return const Err(
        ValidationFailure('Bạn đã dùng hết 30 lượt tạo tem tháng này.'),
      );
    }
    return Ok(
      Stamp(
        id: 'new',
        imageUrl: input.imageUrl,
        source: input.source,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Result<Stamp>> rename(String id, String name) async =>
      const Err(UnknownFailure());

  @override
  Future<Result<void>> delete(String id) async => const Ok(null);
}

/// Skips the real 3-hop presign→R2→create upload; the wizard's save path
/// exercises quota/failure via [FakeStampsRepository.save] instead.
class FakeStampUploader extends StampUploader {
  FakeStampUploader() : super(Dio());

  @override
  Future<String> upload(Uint8List pngBytes) async {
    await Future<void>.delayed(_lag * 2);
    if (previewSwitches.quotaReached) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/sm/uploads/presign'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/sm/uploads/presign'),
          statusCode: 403,
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return _img('created-stamp');
  }
}

// ─────────────────────────────────────────────────────────────── letters ──

class FakeLettersRepository implements LettersRepository {

  @override
  Future<Result<List<Letter>>> letters() async => const Ok([]);
  @override
  Future<Result<Letter>> create(LetterInput input) async {
    await Future<void>.delayed(_lag * 2);
    return Ok(
      Letter(
        id: 'ltr-1',
        content: input.content,
        stampIds: input.stampIds,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Result<LetterLink>> createLink(
    String letterId, {
    String? platform,
  }) async {
    await Future<void>.delayed(_lag * 2);
    return Ok(
      LetterLink(
        id: 'Ab3dE9',
        letterId: letterId,
        platform: platform,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      ),
    );
  }

  @override
  Future<Result<List<SentLetter>>> sent() async => const Ok([]);

  @override
  Future<LetterContent?> cachedContent(String letterId) async => null;

  @override
  Future<CachedLetter?> cachedMeta(String letterId) async => null;
}

// ─────────────────────────────────────────────────────── letter reveal ──

class FakeInboxRepository implements InboxRepository {
  /// The preview picks the outcome by linkId, so the gallery can show every
  /// terminal state of F04: `already` / `expired` / `invalid` / anything else
  /// opens normally.
  @override
  Future<OpenLetterOutcome> open(String linkId, {String? viewerUid}) async {
    await Future<void>.delayed(_lag * 2);
    return switch (linkId) {
      'already' => const LetterAlreadyOpened(),
      'expired' => const LetterExpired(),
      'invalid' => const LetterInvalid(),
      _ => LetterOpened(
        ReceivedLetter(
          id: 'rl1',
          text:
              'Chào cậu,\n\nCảm ơn cậu vì đã luôn ở bên tớ suốt thời gian '
              'qua. Mong rằng con tem nhỏ này sẽ khiến cậu mỉm cười.\n\n'
              'Thương nhiều 💌',
          stamps: [
            StampRef(
              id: 's1',
              imageUrl: _img('rstamp1'),
              createdAt: DateTime(2026, 7, 1),
            ),
            StampRef(
              id: 's2',
              imageUrl: _img('rstamp2'),
              createdAt: DateTime(2026, 7, 1),
            ),
          ],
          createdAt: DateTime(2026, 7, 9),
        ),
      ),
    };
  }
}

// ────────────────────────────────────────────────────────────────── home ──

class FakeHomeDataLoader implements HomeDataLoader {
  @override
  Future<HomeData> load() async {
    await Future<void>.delayed(_lag);
    if (previewSwitches.emptyStamps && previewSwitches.emptyLetters) {
      return HomeData.empty;
    }
    return HomeData(
      recentStamps: previewSwitches.emptyStamps
          ? const []
          : [
              for (final (i, s) in _fakeStamps.take(3).indexed)
                StampRef(
                  id: s.id,
                  imageUrl: s.imageUrl,
                  createdAt: s.createdAt,
                  name: _stampNames[i],
                ),
            ],
      recentLetters: previewSwitches.emptyLetters
          ? const []
          : [
              HomeLetterItem(
                id: 'l1',
                letterId: 'l1',
                title: 'Cảm ơn mẹ yêu ❤️',
                meta: 'Gửi đến Mẹ  ·  20/05/2024',
                opened: true,
                envelopeImageUrl: _design('hl-letter-mom.png'),
                stampImageUrl: _design('hl-stampmini-mom.png'),
              ),
              HomeLetterItem(
                id: 'l2',
                letterId: 'l2',
                title: 'Happy Birthday Linh! 🎂',
                meta: 'Gửi đến Linh  ·  19/05/2024',
                opened: false,
                envelopeImageUrl: _design('hl-letter-bday.png'),
                stampImageUrl: _design('hl-stampmini-mom.png'),
              ),
              HomeLetterItem(
                id: 'l3',
                letterId: 'l3',
                title: 'Nhớ chuyến đi Đà Lạt 🌿',
                meta: 'Gửi đến Hội bạn thân  ·  18/05/2024',
                opened: true,
                envelopeImageUrl: _design('hl-letter-trip.png'),
                stampImageUrl: _design('hl-stampmini-mom.png'),
              ),
            ],
    );
  }
}

/// The preview harness renders the online design states, so connectivity is
/// pinned online — the offline notice (SM-004 BR-07 / SM-022 BR-10) stays out
/// of the frames unless a preview deliberately asks for it.
class FakeOnlineConnectivity implements ConnectivitySource {
  const FakeOnlineConnectivity();

  @override
  Future<bool> isOnline() async => true;

  @override
  Stream<bool> get onOnlineChanged => const Stream<bool>.empty();
}

// ──────────────────────────────────────────────────────── registration ──

/// Registers every dependency the screens resolve via `GetIt`, backed by the
/// fakes above. Call once from `preview_all.dart` before `runApp`.
void registerPreviewFakes() {
  final getIt = GetIt.instance;
  const analytics = NoOpAnalyticsService();
  const connectivity = FakeOnlineConnectivity();
  final authRepo = FakeAuthRepository();

  getIt
    ..registerLazySingleton<StampsRepository>(FakeStampsRepository.new)
    ..registerLazySingleton<LettersRepository>(FakeLettersRepository.new)
    ..registerLazySingleton<InboxRepository>(FakeInboxRepository.new)
    ..registerLazySingleton<StampUploader>(FakeStampUploader.new)
    ..registerFactory<HomeBloc>(
      () => HomeBloc(FakeHomeDataLoader(), connectivity),
    )
    ..registerFactory<AlbumCubit>(
      () => AlbumCubit(getIt<StampsRepository>(), connectivity),
    )
    ..registerFactory<SentLettersCubit>(
      () => SentLettersCubit(
        getIt<LettersRepository>(),
        getIt<StampsRepository>(),
      ),
    )
    ..registerFactory<ProfileBloc>(() => ProfileBloc(analytics))
    ..registerFactory<DeleteAccountCubit>(
      () => DeleteAccountCubit(DeleteAccountUseCase(authRepo), analytics),
    )
    ..registerFactory<ChangePasswordCubit>(
      () => ChangePasswordCubit(ChangePasswordUseCase(authRepo)),
    );
}

/// A real [AuthBloc] over [FakeAuthRepository] — sign-in/register run their
/// genuine reducer logic against fake outcomes.
AuthBloc buildPreviewAuthBloc() {
  final repo = FakeAuthRepository();
  return AuthBloc(
    signIn: SignInUseCase(repo),
    register: RegisterUseCase(repo),
    signOut: SignOutUseCase(repo),
    restoreSession: RestoreSessionUseCase(repo),
    analytics: const NoOpAnalyticsService(),
    signInWithGoogle: SignInWithGoogleUseCase(repo),
  );
}
