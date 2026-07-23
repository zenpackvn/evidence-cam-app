import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_platform/app_platform.dart';
import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_home/feature_home.dart';
import 'package:feature_letter_inbox/feature_letter_inbox.dart';
import 'package:feature_letters/feature_letters.dart';
import 'package:feature_onboarding/feature_onboarding.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:feature_splash/feature_splash.dart';
import 'package:feature_stamp_creator/feature_stamp_creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rev_sync/rev_sync.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:storage/storage.dart';

import '../core/locale/locale_bloc.dart';
import 'widgets/app_shell.dart';

part 'router.g.dart';

@TypedStatefulShellRoute<AppShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<HomeBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<HomeRoute>(path: '/', name: 'home'),
      ],
    ),
    TypedStatefulShellBranch<LettersBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<SentLettersRoute>(path: '/letters', name: 'letters'),
      ],
    ),
    TypedStatefulShellBranch<AlbumBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<AlbumRoute>(path: '/album', name: 'album'),
      ],
    ),
    TypedStatefulShellBranch<ProfileBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<StampMailProfileRoute>(
          path: '/me',
          name: 'me',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<ProfileRoute>(path: 'edit', name: 'profile'),
            TypedGoRoute<ChangePasswordRoute>(
              path: 'change-password',
              name: 'change-password',
            ),
          ],
        ),
      ],
    ),
  ],
)
class AppShellRouteData extends StatefulShellRouteData {
  const AppShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => AppShell(navigationShell: navigationShell);
}

class HomeBranchData extends StatefulShellBranchData {
  const HomeBranchData();
}

class LettersBranchData extends StatefulShellBranchData {
  const LettersBranchData();
}

class AlbumBranchData extends StatefulShellBranchData {
  const AlbumBranchData();
}

class ProfileBranchData extends StatefulShellBranchData {
  const ProfileBranchData();
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding', name: 'onboarding')
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final store = GetIt.instance<OnboardingStore>();
    return OnboardingScreen(
      // SM-003 §5: resume where the user left off, persisting each step.
      initialStep: store.lastStep,
      onStepChanged: store.saveStep,
      onDone: () {
        // Onboarding is the first-run intro shown before auth: finishing (or
        // skipping) it leads to sign-in, not into the app.
        store.markSeen().then((_) {
          if (context.mounted) context.go(AuthRoutes.login);
        });
      },
    );
  }
}

@TypedGoRoute<CreateStampRoute>(path: '/create', name: 'create')
class CreateStampRoute extends GoRouteData with $CreateStampRoute {
  const CreateStampRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => StampSourceScreen(
    picker: GetIt.instance<ImagePickerService>(),
    // On pick, show the "Xem trước ảnh" zoom/confirm step (SM-005, F02-S03)
    // before entering the filter wizard.
    onPicked: (path) => _openPhotoPreview(context, path),
    // "Chọn từ thư viện" opens the in-app library grid (SM-005 F02-S11).
    onBrowseLibrary: () => _openLibrary(context),
    // "Chụp ảnh mới" opens the in-app camera with the square stamp viewfinder.
    onCapture: () => _openCamera(context),
  );
}

// SM-005 F02-S02: the in-app full-screen camera with the square stamp
// viewfinder. On capture it flows into the same "Xem trước ảnh" → wizard path.
void _openCamera(BuildContext context) {
  Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => CameraCaptureScreen(
        camera: GetIt.instance<CameraService>(),
        onCaptured: (path, frame) {
          Navigator.of(context).pop();
          _openPhotoPreview(context, path, frame);
        },
        onClose: () => Navigator.of(context).maybePop(),
      ),
    ),
  );
}

// SM-005 F02-S11: the in-app "Chọn từ thư viện" grid backed by the device
// photo library. On pick it flows into the same "Xem trước ảnh" → wizard path.
void _openLibrary(BuildContext context) {
  Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => LibraryPickerFlow(
        gallery: GetIt.instance<GalleryService>(),
        onPicked: (path) => _openPhotoPreview(context, path),
        onCamera: () => Navigator.of(context).maybePop(),
      ),
    ),
  );
}

// SM-005 (F02-S03): confirm/zoom the picked photo before the wizard. "Xác nhận"
// advances to the filter step; "Hủy" returns to the source picker.
void _openPhotoPreview(
  BuildContext context,
  String imagePath, [
  StampFrameStyle? frame,
]) {
  Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => PhotoPreviewScreen(
        imagePath: imagePath,
        frameStyle: frame,
        // The user may have re-picked the tem edge and zoomed/positioned the
        // photo — carry the chosen edge and the cropped image into the wizard.
        onConfirm: (chosenFrame, croppedPath) =>
            _openWizard(context, croppedPath, chosenFrame),
        onCancel: () => Navigator.of(context).maybePop(),
      ),
    ),
  );
}

void _openWizard(
  BuildContext context,
  String imagePath, [
  StampFrameStyle? frame,
]) {
  Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => StampWizardScreen(
        imagePath: imagePath,
        frameStyle: frame ?? StampFrameStyle.perforated,
        // Creator/dev build: everything unlocked — no locked filters/borders/
        // stickers in the wizard.
        isPremium: true,
        onExit: () => Navigator.of(context).maybePop(),
        onViewAlbum: () => const HomeRoute().go(context),
        onCreateAnother: () => const CreateStampRoute().go(context),
      ),
    ),
  );
}

class AlbumRoute extends GoRouteData with $AlbumRoute {
  const AlbumRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => AlbumScreen(
    onCreate: () => const CreateStampRoute().push<void>(context),
    // SM-022 BR-07: attach a stamp to a new letter → composer. Placeholder
    // navigation to the template list; passing the preselected stamp through
    // the composer is wired when the composer accepts an initial stamp.
    onAttachStamp: (_) => const LetterComposeRoute().push<void>(context),
    // SM-035: the sample-stamp catalog is a separate browse area reached from
    // the Album.
    onBrowseSamples: () => const SampleStampsRoute().push<void>(context),
    // SM-025 BR-07: write the captured post to a temp file and open the native
    // share sheet. The watermark is already baked into the PNG (BR-06).
    onShareImage: _shareStampImage,
    // SM-025 BR-05: save the post to the device gallery.
    onSaveImageToGallery: _saveStampToGallery,
  );
}

/// Saves [png] to the device gallery (SM-025 BR-05); returns whether it worked.
Future<bool> _saveStampToGallery(Uint8List png) async {
  if (!GetIt.instance.isRegistered<GallerySaveService>()) return false;
  try {
    await GetIt.instance<GallerySaveService>().savePng(png);
    return true;
  } on Object {
    return false;
  }
}

/// Writes [png] to a temp file and opens the native share sheet (SM-025 BR-07).
Future<void> _shareStampImage(Uint8List png) async {
  final path =
      '${Directory.systemTemp.path}/stampmail-share-${DateTime.now().millisecondsSinceEpoch}.png';
  final file = File(path);
  await file.writeAsBytes(png, flush: true);
  await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
}

// SM-026 BR-02: map a settings toggle id to its backend notification kind.
const _notificationKinds = <String, String>{
  'new-letter': 'letter_received',
  'letter-read': 'letter_opened',
  'quota': 'quota_low',
};

/// The prefs key for a notification kind's on/off state. Keyed by kind (not the
/// UI toggle id) so the settings screen and the sign-in subscription sync read
/// the same value (SM-026 BR-02).
String _notifPrefKey(String kind) => 'notif_enabled_kind_$kind';

/// Reads persisted notification toggle state (defaults on) for the settings
/// screen (SM-026 BR-02).
Map<String, bool> _notificationPrefs() {
  if (!GetIt.instance.isRegistered<SharedPreferences>()) return const {};
  final prefs = GetIt.instance<SharedPreferences>();
  return {
    for (final entry in _notificationKinds.entries)
      entry.key: prefs.getBool(_notifPrefKey(entry.value)) ?? true,
  };
}

/// Persists a toggle and (un)subscribes its FCM topic (SM-026 BR-02).
void _setNotificationKind(String uid, String id, {required bool value}) {
  final kind = _notificationKinds[id];
  if (kind == null) return;
  if (GetIt.instance.isRegistered<SharedPreferences>()) {
    unawaited(
      GetIt.instance<SharedPreferences>().setBool(_notifPrefKey(kind), value),
    );
  }
  if (GetIt.instance.isRegistered<FirebaseMessagingService>()) {
    unawaited(
      GetIt.instance<FirebaseMessagingService>().setKindEnabled(
        uid: uid,
        kind: kind,
        enabled: value,
      ),
    );
  }
}

/// SM-035 — the curated sample-stamp catalog (a separate browse area, BR-01).
@TypedGoRoute<SampleStampsRoute>(path: '/samples', name: 'samples')
class SampleStampsRoute extends GoRouteData with $SampleStampsRoute {
  const SampleStampsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SampleStampsScreen();
}

@TypedGoRoute<LetterComposeRoute>(path: '/compose', name: 'compose')
class LetterComposeRoute extends GoRouteData with $LetterComposeRoute {
  const LetterComposeRoute({this.replyTo, this.replyToUid});

  /// The original sender's name when this is a reply (SM-020 BR-01); a query
  /// param so a deep link / reply can carry it.
  final String? replyTo;

  /// The original sender's uid when replying (SM-026 D12), threaded to the
  /// created letter so the server pushes "letter received".
  final String? replyToUid;

  @override
  Widget build(BuildContext context, GoRouterState state) => TemplateListScreen(
    // SM-020 BR-01: when replying, the template picker shows the original
    // sender as recipient.
    replyToName: replyTo,
    onPick: (template) =>
        _openComposer(context, template.id, replyToUid: replyToUid),
  );
}

void _openComposer(
  BuildContext context,
  String templateId, {
  String? replyToUid,
}) {
  final rootContext = context;
  Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => ComposerFlow(
        templateId: templateId,
        replyToUid: replyToUid,
        letters: GetIt.instance<LettersRepository>(),
        stamps: GetIt.instance<StampsRepository>(),
        // ponytail: link base is a placeholder until the web viewer is deployed
        // (D3) and its base lands in config; the URL shape is already correct.
        linkBaseUrl: 'https://stampmail.app/letter',
        onClose: () => const AlbumRoute().go(rootContext),
        // SM-016 BR-05 / section 5: hand the link to the native share sheet so
        // the user picks the target messenger and pastes it in. (Per-platform
        // DM-prefill schemes exist for only 3 of the 8 platforms and change
        // often — the share sheet covers all eight uniformly. ponytail: share
        // sheet only; wire LetterShare.dmUri via url_launcher if deep-linking
        // straight into a DM composer becomes a requirement.)
        onOpenShare: (platform, letterUrl) =>
            SharePlus.instance.share(ShareParams(text: letterUrl)),
      ),
    ),
  );
}

/// SM-021 — the whole "Thư" tab: sent letters + link status. There is no
/// received-letters list (SM-017 BR-10).
class SentLettersRoute extends GoRouteData with $SentLettersRoute {
  const SentLettersRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => SentLettersPage(
    createCubit: () => GetIt.instance<SentLettersCubit>(),
    onCompose: () => const LetterComposeRoute().push<void>(context),
  );
}

/// SM-017: opening a received letter link. Guest-allowed (B3.3) — a signed-out
/// web reader can open it; reply then prompts auth.
@TypedGoRoute<LetterRevealRoute>(path: '/letter/:linkId', name: 'letter')
class LetterRevealRoute extends GoRouteData with $LetterRevealRoute {
  const LetterRevealRoute(this.linkId);

  final String linkId;

  @override
  Widget build(BuildContext context, GoRouterState state) => LetterRevealScreen(
    linkId: linkId,
    // Người nhận đã đăng nhập mở link dưới uid của mình để server cho phép
    // chính chủ mở lại (link 1 lần với người khác — SM-017 BR-03/BR-10).
    viewerUid: SessionScope.of(context).currentUser?.id,
    // SM-020 BR-01: reply opens the composer prefilled with the original
    // sender as recipient; SM-026 D12: carry their uid so the sent reply pushes
    // "letter received" to them. (The send still goes out as a fresh link —
    // BR-03/BR-04.)
    onReply: ({required senderName, required senderUid}) => LetterComposeRoute(
      replyTo: senderName.isEmpty ? null : senderName,
      replyToUid: senderUid.isEmpty ? null : senderUid,
    ).push<void>(context),
    // SM-025: share the opened letter to social (Mức 1/2/3) with its stamp and
    // text; the same capture → share sheet / gallery plumbing as the Album.
    onShare: ({required stampImageUrl, required letterText}) =>
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => ShareStampScreen(
              stampImageUrl: stampImageUrl,
              letterText: letterText,
              onShareImage: _shareStampImage,
              onSaveToGallery: _saveStampToGallery,
            ),
          ),
        ),
  );
}

class StampMailProfileRoute extends GoRouteData with $StampMailProfileRoute {
  const StampMailProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const _StampMailProfilePage();
}

/// Resolves the user's Premium entitlement, then shows the profile in either its
/// Free (F07-S01) or Premium (F07-S02) state. Reads once and caches the future
/// so a rebuild doesn't re-hit the network.
class _StampMailProfilePage extends StatefulWidget {
  const _StampMailProfilePage();

  @override
  State<_StampMailProfilePage> createState() => _StampMailProfilePageState();
}

class _StampMailProfilePageState extends State<_StampMailProfilePage> {
  // Creator/dev build: unlock everything — treat the user as Premium so no
  // filter / border / sticker / screen is gated across any flow.
  late final Future<Result<Entitlement>> _entitlement = Future.value(
    const Ok(Entitlement(isPremium: true)),
  );

  // The single profile cubit shared with the "Sửa hồ sơ" screen, so an edit
  // (name / username / avatar) reflects on this screen the moment it is saved.
  late final EditProfileCubit _editCubit = GetIt.instance<EditProfileCubit>()
    ..load();

  @override
  void dispose() {
    _editCubit.close();
    super.dispose();
  }

  /// F07-S04: pick a photo, crop it 1:1 like the demo, then upload + save it as
  /// the avatar. The cubit shows the cropped picture immediately (optimistic).
  Future<void> _editAvatar(BuildContext context) async {
    final navigator = Navigator.of(context);
    final file = await GetIt.instance<ImagePickerService>().pickImage(
      source: ImageSource.gallery,
    );
    if (file == null) return;
    await navigator.push<void>(
      MaterialPageRoute(
        builder: (_) => CropAvatarScreen(
          imagePath: file.path,
          onSave: (bytes) {
            navigator.pop();
            _editCubit.changeAvatar(bytes);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<Entitlement>>(
      future: _entitlement,
      builder: (context, snapshot) {
        final entitlement = switch (snapshot.data) {
          Ok(:final value) => value,
          _ => Entitlement.free,
        };
        return BlocConsumer<EditProfileCubit, EditProfileState>(
          bloc: _editCubit,
          listenWhen: (prev, next) =>
              prev.saveError != next.saveError && next.saveError != null,
          listener: (context, editState) => ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(editState.saveError!))),
          builder: (context, editState) => StampMailProfileScreen(
            isPremium: entitlement.isPremium,
            premiumExpiry: entitlement.expiresAt,
            name: editState.profile?.effectiveName,
            username: editState.profile?.username,
            avatarUrl: editState.profile?.avatarUrl,
            avatarBytes: editState.pendingAvatarBytes,
            isSavingAvatar: editState.isSavingAvatar,
            onEditAvatar: () => _editAvatar(context),
            // The edit screen shares _editCubit, so saved name/handle/avatar
            // land here live — no reload needed.
            onEditProfile: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(
                  cubit: _editCubit,
                  picker: GetIt.instance<ImagePickerService>(),
                ),
              ),
            ),
            onOpenSettings: () => const SettingsRoute().push<void>(context),
            // ponytail: the paywall / manage-subscription flow (RevenueCat)
            // lands separately; both actions open Settings for now.
            onUpgrade: () => const SettingsRoute().push<void>(context),
            onManagePlan: () => const SettingsRoute().push<void>(context),
          ),
        );
      },
    );
  }
}

@TypedGoRoute<SettingsRoute>(path: '/settings', name: 'settings')
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BlocProvider<SignOutAllDevicesCubit>(
        create: (_) => GetIt.instance<SignOutAllDevicesCubit>(),
        child: Builder(
          builder: (context) =>
              BlocListener<SignOutAllDevicesCubit, SignOutAllDevicesState>(
                listener: _onSignOutAllState,
                child: _buildSettings(context),
              ),
        ),
      );

  /// Reacts to the revoke result. On success the repository has already ended
  /// the session server-side and locally, so the session is only cleared here to
  /// send the router back to login — mirroring the delete-account flow.
  void _onSignOutAllState(BuildContext context, SignOutAllDevicesState state) {
    switch (state) {
      case SignOutAllDevicesSuccess():
        SessionScope.of(context).clearSession();
      case SignOutAllDevicesFailure(:final failure):
        // The user is still signed in everywhere. Say so rather than let the
        // screen sit there looking like it worked.
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      case SignOutAllDevicesInitial() || SignOutAllDevicesSubmitting():
        break;
    }
  }

  /// Confirms before ending every session.
  ///
  /// The dialog is where the one-hour caveat belongs: the row promises "tất cả
  /// thiết bị", and revoking refresh tokens does not drop other devices until
  /// their current ID token expires. Better the user reads that here than
  /// discovers it on a device that is still logged in.
  Future<void> _confirmSignOutAll(BuildContext context) async {
    final cubit = context.read<SignOutAllDevicesCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất tất cả thiết bị?'),
        content: const Text(
          'Bạn sẽ đăng xuất khỏi thiết bị này và tất cả thiết bị khác.\n\n'
          'Các thiết bị khác có thể mất tới 1 giờ để đăng xuất hoàn toàn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.submit();
  }

  /// Confirms before signing out of this device (SM-027) — a stray tap should
  /// not end the session.
  Future<void> _confirmSignOut(BuildContext context) async {
    final session = SessionScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi thiết bị này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) session.signOut();
  }

  Widget _buildSettings(BuildContext context) {
    // Read (not watch): switching the locale rebuilds MaterialApp, which
    // rebuilds this route, so a fresh read here always reflects the current
    // language.
    final localeBloc = context.read<LocaleBloc>();
    final code = localeBloc.state.locale.languageCode;
    return _SettingsConnectivity(
      builder: (isOffline) => SettingsScreen(
        isOffline: isOffline,
        languageLabel: _languageLabel(code),
        onChangePassword: () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
        ),
        onSignOut: () => _confirmSignOut(context),
        onSignOutAll: () => _confirmSignOutAll(context),
        onLanguage: () => Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => LanguageScreen(
              selected: code,
              onSelect: (picked) => localeBloc.add(LocaleChanged(picked)),
            ),
          ),
        ),
        onNotifications: () {
          final uid = SessionScope.of(context).currentUser?.id;
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => NotificationSettingsScreen(
                initialValues: _notificationPrefs(),
                onKindChanged: uid == null
                    ? null
                    : (id, {required value}) =>
                          _setNotificationKind(uid, id, value: value),
              ),
            ),
          );
        },
        onDeleteAccount: () => Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => BlocProvider<DeleteAccountCubit>(
              create: (_) => GetIt.instance<DeleteAccountCubit>(),
              child: BlocListener<DeleteAccountCubit, DeleteAccountState>(
                listener: (_, state) => _onDeleteAccountState(context, state),
                child: Builder(
                  builder: (buttonContext) => DeleteAccountScreen(
                    onConfirm: () =>
                        buttonContext.read<DeleteAccountCubit>().submit(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Reacts to the delete-account result. On success the account is already
  /// gone server-side (Firebase `user.delete()`), so the session is cleared to
  /// send the router to login; on failure the user stays put with a message.
  void _onDeleteAccountState(BuildContext context, DeleteAccountState state) {
    switch (state) {
      case DeleteAccountSuccess():
        SessionScope.of(context).clearSession();
      case DeleteAccountFailure():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không xoá được tài khoản. Vui lòng thử lại.'),
          ),
        );
      case DeleteAccountInitial() || DeleteAccountSubmitting():
        break;
    }
  }

  /// Display name for a language code. Only the two codes with a bundled
  /// translation appear here; the picker offers more, but LocaleBloc ignores
  /// any it cannot render, so the label can only ever be one of these.
  static String _languageLabel(String code) => switch (code) {
    'en' => 'English',
    _ => 'Tiếng Việt',
  };
}

/// Watches connectivity and rebuilds its [builder] with the current offline
/// flag, so the Settings screen can show the "Đang xem ngoại tuyến" notice
/// (SM-004 BR-07) and hide it again the moment the connection returns.
class _SettingsConnectivity extends StatefulWidget {
  const _SettingsConnectivity({required this.builder});

  // A single-bool builder reads clearly here (isOffline → widget).
  // ignore: avoid_positional_boolean_parameters
  final Widget Function(bool isOffline) builder;

  @override
  State<_SettingsConnectivity> createState() => _SettingsConnectivityState();
}

class _SettingsConnectivityState extends State<_SettingsConnectivity> {
  final ConnectivitySource _connectivity = GetIt.instance<ConnectivitySource>();
  bool _offline = false;
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    // Seed the current state (onOnlineChanged only fires on transitions), then
    // track changes.
    unawaited(
      _connectivity.isOnline().then((online) {
        if (mounted) setState(() => _offline = !online);
      }),
    );
    _sub = _connectivity.onOnlineChanged.listen((online) {
      if (mounted) setState(() => _offline = !online);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_offline);
}

@TypedGoRoute<SplashRoute>(path: '/splash', name: 'splash')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => SplashScreen(
    onRestored: (context) {
      DeepLinkScope.of(context).splashCompleted = true;
      final store = GetIt.instance<OnboardingStore>();
      if (!store.hasSeenOnboarding) {
        const OnboardingRoute().go(context);
      } else {
        const HomeRoute().go(context);
      }
    },
  );
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => HomeScreen(
    onCreateStamp: () => const CreateStampRoute().push<void>(context),
    onOpenAlbum: () => const AlbumRoute().go(context),
    onOpenLetters: () => const SentLettersRoute().go(context),
    // Tapping a recent stamp opens the Album (where it can be viewed/edited);
    // tapping a recent letter opens that letter's composed content.
    onOpenStamp: (_) => const AlbumRoute().go(context),
    onOpenLetter: (letter) => _openLetterContent(context, letter.letterId),
  );
}

/// Opens a read-only view of a letter the user composed, loading its body from
/// the local cache the letters repo stashed at create time (the backend has no
/// "read my letter by id" endpoint, so this only covers on-device letters).
void _openLetterContent(BuildContext context, String letterId) {
  Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => SentLetterViewScreen(
        loadContent: () =>
            GetIt.instance<LettersRepository>().cachedContent(letterId),
      ),
    ),
  );
}

/// SM-024 "Sửa hồ sơ" (`/me/edit`): the profile edit form — display name
/// (BR-02), the once-only username change (BR-03) and the optional birthday
/// (BR-06).
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      EditProfileScreen(picker: GetIt.instance<ImagePickerService>());
}

class ChangePasswordRoute extends GoRouteData with $ChangePasswordRoute {
  const ChangePasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ChangePasswordScreen();
}

/// Tracks deep-link targets and splash-screen completion so the redirect can
/// capture cold-start URIs and replay them after auth resolves.
class DeepLinkState {
  String? pendingRedirect;
  bool splashCompleted = false;
}

class DeepLinkScope extends InheritedWidget {
  const DeepLinkScope({
    super.key,
    required this.deepLink,
    required super.child,
  });

  final DeepLinkState deepLink;

  static DeepLinkState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DeepLinkScope>();
    assert(scope != null, 'No DeepLinkScope found in context.');
    return scope!.deepLink;
  }

  @override
  bool updateShouldNotify(DeepLinkScope oldWidget) =>
      deepLink != oldWidget.deepLink;
}

/// Builds the app router and wires auth redirects to [bloc] state changes.
///
/// [featureRoutes] are the non-shell routes contributed by the feature
/// packages (and auth's login/register). They are mounted alongside the
/// generated shell routes ([$appRoutes]) so adding a feature's screens never
/// edits this file — the feature ships its own route table.
({GoRouter router, DeepLinkState deepLink}) buildRouterWithDeepLink(
  AuthBloc bloc, {
  required List<RouteBase> featureRoutes,
  List<NavigatorObserver>? observers,
}) {
  final deepLink = DeepLinkState();
  final homeLocation = const HomeRoute().location;
  final splashLocation = const SplashRoute().location;
  final onboardingLocation = const OnboardingRoute().location;
  const loginLocation = AuthRoutes.login;
  const registerLocation = AuthRoutes.register;
  const forgotPasswordLocation = AuthRoutes.forgotPassword;

  final router = GoRouter(
    // No initialLocation — GoRouter resolves the platform deep-link URI on
    // cold start and the redirect below captures it before sending the user
    // through splash / auth.
    routes: [...$appRoutes, ...featureRoutes],
    observers: observers,
    refreshListenable: _BlocListenable(bloc.stream),
    redirect: (context, state) => resolveSplashRedirect(
      auth: bloc.state,
      location: state.matchedLocation,
      requestedUri: state.uri.toString(),
      deepLink: deepLink,
      splashLocation: splashLocation,
      loginLocation: loginLocation,
      registerLocation: registerLocation,
      onboardingLocation: onboardingLocation,
      forgotPasswordLocation: forgotPasswordLocation,
      homeLocation: homeLocation,
    ),
  );

  return (router: router, deepLink: deepLink);
}

/// Resolves the auth/splash redirect for a single navigation.
///
/// Pure decision function behind [buildRouterWithDeepLink]'s `redirect`: given
/// the current [auth] state, the [location] GoRouter matched, the
/// [requestedUri] the user is trying to reach, and the mutable [deepLink] gate,
/// it returns the location to redirect to, or `null` to allow the navigation.
/// Extracted so the three-phase state machine can be unit-tested without
/// assembling a full [GoRouter] and widget tree.
///
/// Mutates [DeepLinkState.pendingRedirect] to capture a cold-start/deep-link
/// target before splash/auth, then replays it once the user is authenticated.
@visibleForTesting
String? resolveSplashRedirect({
  required AuthState auth,
  required String location,
  required String requestedUri,
  required DeepLinkState deepLink,
  required String splashLocation,
  required String loginLocation,
  required String registerLocation,
  required String onboardingLocation,
  required String forgotPasswordLocation,
  required String homeLocation,
}) {
  // ── Phase 1: Before splash completes ──
  // Intercept every navigation until restoreSession and the splash minimum
  // display time complete. The splash screen flips splashCompleted after both
  // gates finish.
  if (!deepLink.splashCompleted) {
    // Already on splash — let it run.
    if (location == splashLocation) return null;
    // Any other location (deep link or default '/') — capture and send
    // through splash first.
    deepLink.pendingRedirect ??= requestedUri;
    return splashLocation;
  }

  // ── Phase 2: Unauthenticated ──
  // Splash completed with no session, or user signed out.
  if (auth is AuthInitial || auth is AuthFailure) {
    // The pre-auth routes reachable without a session: onboarding (first-run
    // intro, splash → onboarding → login) and forgot-password (reached from the
    // login screen's "Quên mật khẩu?" link). Without whitelisting them here the
    // redirect would bounce the user straight back to login.
    if (location == loginLocation ||
        location == registerLocation ||
        location == onboardingLocation ||
        location == forgotPasswordLocation) {
      return null;
    }
    deepLink.pendingRedirect ??= requestedUri;
    return loginLocation;
  }

  // ── Phase 3: Authenticated (incl. mid-sign-out) ──
  // AuthSigningOut still holds a user; let the screen stay put until the op
  // completes and AuthBloc emits AuthInitial.
  if (auth is AuthAuthenticated || auth is AuthSigningOut) {
    final target = deepLink.pendingRedirect;
    if (target != null) {
      deepLink.pendingRedirect = null;
      if (target != requestedUri) return target;
    }
    // No pending deep link; bounce off splash/login/register to home.
    if (location == splashLocation ||
        location == loginLocation ||
        location == registerLocation) {
      return homeLocation;
    }
    // Already on a valid, protected route — allow it.
    return null;
  }

  // AuthSubmitting / AuthRestoring — don't interfere.
  return null;
}

/// Adapts a [Stream] to the [Listenable] contract GoRouter needs for
/// `refreshListenable`.
class _BlocListenable extends ChangeNotifier {
  _BlocListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
