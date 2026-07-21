// The design-review gallery: one entry per frame in
// `specs/projects/stampmail/design-spec/pencil-new.pen` (57 screens), grouped
// by flow. Implemented screens open with fake data; missing ones are listed
// disabled with a note, so this doubles as the design-coverage checklist.
import 'dart:io';

import 'package:app_platform/app_platform.dart'
    show ImagePicker, ImagePickerService, ImageSource;
import 'package:app_ui/app_ui.dart';
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
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../app/widgets/app_shell.dart';
import 'preview_fakes.dart';

// ─────────────────────────────────────────────────────────────── catalog ──

enum EntryStatus { done, partial, missing }

class GalleryEntry {
  const GalleryEntry(
    this.code,
    this.title, {
    this.status = EntryStatus.done,
    this.note,
    this.build,
    this.prepare,
  });

  final String code;
  final String title;
  final EntryStatus status;

  /// Gap note shown under the title (what differs from the design).
  final String? note;

  final WidgetBuilder? build;

  /// Flips [previewSwitches] before the screen opens.
  final void Function(PreviewSwitches s)? prepare;
}

class GallerySection {
  const GallerySection(this.title, this.entries);
  final String title;
  final List<GalleryEntry> entries;
}

/// Wraps a tab-level screen in the real shell chrome (tab bar + create FAB).
Widget _shell(Widget child, {int tab = 0}) => Scaffold(
  body: child,
  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  floatingActionButton: StampMailCreateFab(onPressed: () {}),
  bottomNavigationBar: StampMailTabBar(currentIndex: tab, onSelect: (_) {}),
);

void _noop() {}
void _noopReply({required String senderName, required String senderUid}) {}

List<GallerySection> buildGallerySections() => [
  GallerySection('Flow 1 · Khởi đầu', [
    GalleryEntry(
      'F01-S01',
      'Splash',
      build: (_) => const Scaffold(body: SplashContent()),
    ),
    GalleryEntry(
      'F01-S02',
      'Onboarding — Slide 1/3',
      build: (_) => const OnboardingScreen(onDone: _noop),
    ),
    GalleryEntry(
      'F01-S03',
      'Login — Default',
      build: (_) => const LoginScreen(),
      prepare: (s) => s.loginFails = false,
    ),
    GalleryEntry(
      'F01-S04',
      'Login — Error (field + form)',
      note: 'Submit (điền bừa rồi bấm Đăng nhập) sẽ fail → banner lỗi form.',
      build: (_) => const LoginScreen(),
      prepare: (s) => s.loginFails = true,
    ),
    GalleryEntry(
      'F01-S05',
      'Login — Locked',
      note: 'Submit sẽ trả lỗi khoá → banner khoá + đếm ngược + CTA disable.',
      build: (_) => const LoginScreen(),
      prepare: (s) => s.loginLocked = true,
    ),
    GalleryEntry(
      'F01-S06',
      'Register — Default',
      build: (_) => const RegisterScreen(),
    ),
    GalleryEntry(
      'F01-S07',
      'Register — Social choice (sheet)',
      note: 'Bấm một nút MXH trong Register để mở sheet chọn cách đăng ký.',
      build: (_) => const RegisterScreen(),
    ),
    GalleryEntry(
      'F01-S08',
      'Verify email — Waiting (chờ bấm link)',
      build: (_) => const VerifyEmailScreen(email: 'sunny@stampmail.vn'),
    ),
    GalleryEntry(
      'F01-S09',
      'Choose username — Username-taken',
      note: 'Trạng thái taken + chips là demo state trong màn.',
      build: (_) => const ChooseUsernameScreen(),
    ),
    GalleryEntry(
      'F01-S10',
      'Avatar upload',
      build: (context) => AvatarUploadScreen(
        onDone: () => Navigator.of(context).maybePop(),
        onPickFromLibrary: () async {
          final f = await ImagePickerService(
            ImagePicker(),
          ).pickImage(source: ImageSource.gallery);
          return f?.path;
        },
      ),
    ),
    GalleryEntry(
      'F01-S11',
      'Forgot — Default',
      build: (_) => const ForgotPasswordScreen(),
    ),
    GalleryEntry(
      'F01-S12',
      'Forgot — Link sent (chờ bấm link)',
      note: 'Nhập email rồi gửi — sang màn "Kiểm tra email của bạn".',
      build: (_) => const ForgotPasswordScreen(),
    ),
    GalleryEntry(
      'F01-S13…S14',
      'Reset → Success (mở từ link đặt lại)',
      note:
          'Đường vào thật là universal link trong email; preview mở '
          'thẳng bước reset.',
      build: (_) => const ForgotPasswordScreen(initialStep: ForgotStep.reset),
    ),
    GalleryEntry(
      'F01-S15',
      'Home — Empty',
      build: (_) => _shell(
        const HomeScreen(
          onCreateStamp: _noop,
          onOpenAlbum: _noop,
          onOpenLetters: _noop,
        ),
      ),
      prepare: (s) => s
        ..emptyStamps = true
        ..emptyLetters = true,
    ),
    GalleryEntry(
      'F01-S16',
      'Home — Loaded',
      build: (_) => _shell(
        const HomeScreen(
          onCreateStamp: _noop,
          onOpenAlbum: _noop,
          onOpenLetters: _noop,
        ),
      ),
      prepare: (s) => s
        ..emptyStamps = false
        ..emptyLetters = false,
    ),
  ]),
  GallerySection('Flow 2 · Tạo tem', [
    GalleryEntry(
      'F02-S02',
      'Nguồn ảnh — Chọn cách lấy ảnh',
      build: (context) => StampSourceScreen(
        picker: ImagePickerService(ImagePicker()),
        onPicked: (path) => _pushWizard(context, path),
      ),
    ),
    GalleryEntry(
      'F02-S03…S08',
      'Wizard: xem trước → lọc màu → chỉnh tay → trang trí → hoàn thiện',
      note: 'Mở bằng ảnh mẫu đóng gói sẵn; đi từng bước trong wizard.',
      build: (context) => _SampleImageWizard(),
    ),
    GalleryEntry(
      'F02-S09',
      'Lưu tem — Success',
      build: (_) => const SaveSuccessScreen(
        onViewAlbum: _noop,
        onCreateAnother: _noop,
      ),
    ),
    GalleryEntry(
      'F02-S10',
      'Bộ sưu tập của bạn (Album)',
      build: (context) => _shell(
        const AlbumScreen(),
        tab: 2,
      ),
      prepare: (s) => s.emptyStamps = false,
    ),
    GalleryEntry(
      'F02-S11',
      'Nguồn ảnh — No-camera (thư viện in-app)',
      build: (context) => LibraryPickerScreen(
        photos: [
          for (var i = 1; i <= 9; i++)
            AssetImage('assets/design/f2-lib-$i.png'),
        ],
        onPick: (_) => Navigator.of(context).maybePop(),
      ),
    ),
    GalleryEntry(
      'F02-S12',
      'Trang trí — Locked sticker sheet',
      note: 'Trong wizard (isPremium=false), tab sticker khoá Premium.',
      build: (context) => _SampleImageWizard(),
    ),
    GalleryEntry(
      'F02-S13',
      'Lưu tem — Quota reached',
      note: 'Bấm lưu ở bước cuối wizard sẽ trả 403 quota (fake).',
      build: (context) => _SampleImageWizard(),
      prepare: (s) => s.quotaReached = true,
    ),
    GalleryEntry(
      'F02-S18',
      'Chi tiết tem — Tự tạo',
      build: (context) => StampDetailScreen(
        stamp: Stamp(
          id: 's1',
          imageUrl: 'asset:assets/design/hl-stamp-tulip.png',
          source: StampSource.created,
          createdAt: DateTime(2024, 5, 20),
        ),
        onBack: () => Navigator.of(context).maybePop(),
      ),
    ),
    GalleryEntry(
      'F02-S19',
      'Album — Empty (Sưu tầm)',
      build: (context) => _shell(
        const AlbumScreen(),
        tab: 2,
      ),
      prepare: (s) => s.emptyStamps = true,
    ),
  ]),
  GallerySection('Flow 3 · Soạn & Gửi thư', [
    GalleryEntry(
      'F03-S01',
      'Danh sách template — Default',
      build: (context) => TemplateListScreen(
        onPick: (t) => _pushComposer(context, t.id),
      ),
    ),
    GalleryEntry(
      'F03-S02',
      'Xem trước template — Free',
      build: (context) => TemplatePreviewScreen(
        templates: letterTemplates,
        initialIndex: 0,
        onUse: (t) => _pushComposer(context, t.id),
      ),
    ),
    GalleryEntry(
      'F03-S03',
      'Xem trước template — Premium-locked',
      build: (context) => TemplatePreviewScreen(
        templates: letterTemplates,
        initialIndex: 3,
        onUse: (t) => _pushComposer(context, t.id),
        onUpgrade: () {},
      ),
    ),
    GalleryEntry(
      'F03-S04…S07, S09…S11',
      'Composer flow: soạn → đính tem → xem trước → gửi',
      note: 'Toàn bộ flow chạy trên repo fake; link tạo ra là giả.',
      build: (context) => _buildComposerFlow(context, 'classic'),
    ),
    GalleryEntry(
      'F03-S05/S06',
      'Composer: panel Giấy nền · Căn lề · Màu nền · Sticker',
      status: EntryStatus.partial,
      note:
          'Panel 4 tab trong composer; căn lề + sticker mới là UI '
          '(chưa lưu vào thư — rich text SM-011).',
      build: (context) => _buildComposerFlow(context, 'classic'),
    ),
    GalleryEntry(
      'F03-S09',
      'Xem trước thư — Default',
      build: (context) => LetterPreviewScreen(
        content: const LetterContent(
          templateId: 'birthday',
          text:
              'Chúc mừng sinh nhật cậu!\nMong mọi điều tốt đẹp nhất '
              'sẽ đến với cậu trong tuổi mới. 🎂',
        ),
        stampName: 'Hoa mùa xuân',
        stampImageUrl: 'asset:assets/design/hl-stamp-tulip.png',
        onEdit: () => Navigator.of(context).maybePop(),
        onSend: () {},
        onChangeTemplate: () {},
        onChangeStamp: () {},
      ),
    ),
    GalleryEntry(
      'F03-S10',
      'Xem trước thư — Empty-warning',
      note: 'Bấm "Gửi thư" khi thư trống để mở modal cảnh báo.',
      build: (context) => LetterPreviewScreen(
        content: const LetterContent(templateId: 'classic', text: ''),
        onEdit: () => Navigator.of(context).maybePop(),
        onSend: () async {
          await showEmptyLetterWarning(context);
        },
      ),
    ),
    GalleryEntry(
      'F03-S11',
      'Platform picker — Gửi thư',
      build: (context) => BlocProvider(
        create: (_) => ComposerCubit(GetIt.instance<LettersRepository>()),
        child: SendScreen(
          onBack: () => Navigator.of(context).maybePop(),
          onSent: (_) {},
        ),
      ),
    ),
    GalleryEntry(
      'F03-S12',
      'Gửi thư — Success',
      build: (_) => const SendSuccessScreen(
        linkUrl: 'https://stampmail.app/letter/Ab3dE9',
        platforms: [SharePlatform.messenger],
        onDone: _noop,
      ),
    ),
  ]),
  GallerySection('Flow 4 · Nhận & Đọc thư', [
    const GalleryEntry(
      'F04-S01',
      'Web nhận thư — Guest',
      status: EntryStatus.missing,
      note: 'Web viewer (D1) nằm ngoài app; chưa có trong repo.',
    ),
    GalleryEntry(
      'F04-S02',
      'Đã mở / Hết hạn (in-app tương đương)',
      note: 'Mở link đã dùng → trạng thái already-opened (fake linkId).',
      build: (_) =>
          const LetterRevealScreen(linkId: 'already', onReply: _noopReply),
    ),
    GalleryEntry(
      'F04-S03/S04',
      'Animation mở phong bì (keyframes)',
      build: (_) =>
          const LetterRevealScreen(linkId: 'opened', onReply: _noopReply),
    ),
    GalleryEntry(
      'F04-S05/S06',
      'Thư đã mở — Completed',
      note: 'Đi tiếp từ animation; nút lưu tem dùng fake.',
      build: (_) =>
          const LetterRevealScreen(linkId: 'opened', onReply: _noopReply),
    ),
    GalleryEntry(
      'F04-S07d',
      'Thư đã gửi — Loaded',
      note: 'Tab "Thư" chỉ còn thư đã gửi (SM-021) — không có hộp thư đến.',
      build: (context) => _shell(
        SentLettersScreen(
          letters: [
            SentLetter.fromLink(
              LetterLink(
                id: 'lk1',
                letterId: 'l1',
                platform: 'messenger',
                createdAt: DateTime(2026, 7, 10, 20, 15),
                expiresAt: DateTime(2026, 7, 17, 20, 15),
                openedBy: 'u9',
                openedAt: DateTime(2026, 7, 11, 8),
              ),
            ),
            SentLetter.fromLink(
              LetterLink(
                id: 'lk2',
                letterId: 'l2',
                platform: 'zalo',
                createdAt: DateTime(2026, 7, 8, 9, 30),
                expiresAt: DateTime(2026, 7, 15, 9, 30),
              ),
            ),
            SentLetter.fromLink(
              LetterLink(
                id: 'lk3',
                letterId: 'l3',
                createdAt: DateTime(2026, 6, 20, 14, 2),
                expiresAt: DateTime(2026, 6, 27, 14, 2),
              ),
            ),
          ],
        ),
        tab: 1,
      ),
    ),
    GalleryEntry(
      'F04-S07d',
      'Thư đã gửi — Empty',
      build: (context) => _shell(
        SentLettersScreen(onCompose: () {}),
        tab: 1,
      ),
    ),
  ]),
  GallerySection('Flow 7 · Tài khoản', [
    GalleryEntry(
      'F07-S01',
      'Hồ sơ — Own Free',
      build: (_) => _shell(
        const StampMailProfileScreen(
          onEditProfile: _noop,
          onOpenSettings: _noop,
          onUpgrade: _noop,
        ),
        tab: 3,
      ),
    ),
    GalleryEntry(
      'F07-S02',
      'Hồ sơ — Own Premium',
      build: (_) => _shell(
        const StampMailProfileScreen(
          isPremium: true,
          onEditProfile: _noop,
          onOpenSettings: _noop,
          onUpgrade: _noop,
        ),
        tab: 3,
      ),
    ),
    GalleryEntry(
      'F07-S04',
      'Sửa hồ sơ — Crop avatar',
      build: (context) => _WithSampleImage(
        builder: (path) => CropAvatarScreen(
          imagePath: path,
          onSave: (_) => Navigator.of(context).maybePop(),
        ),
      ),
    ),
    GalleryEntry(
      'F07-S05',
      'Sửa hồ sơ — Thông tin',
      build: (_) => const ProfileScreen(),
    ),
    GalleryEntry(
      'F07-S06',
      'Cài đặt — Default',
      build: (_) => const SettingsScreen(
        onChangePassword: _noop,
        onSignOut: _noop,
        onSignOutAll: _noop,
        onLanguage: _noop,
        onNotifications: _noop,
        onDeleteAccount: _noop,
      ),
    ),
    GalleryEntry(
      'F07-S07',
      'Đổi mật khẩu — Default (+Error/Success)',
      note: 'Nhập mật khẩu hiện tại là "sai" để xem trạng thái lỗi.',
      build: (_) => const ChangePasswordScreen(),
    ),
    GalleryEntry(
      'F07-S08',
      'Ngôn ngữ — Picker',
      build: (_) => LanguageScreen(selected: 'vi', onSelect: (_) {}),
    ),
    GalleryEntry(
      'F07-S12',
      'Thông báo — Default',
      build: (_) => const NotificationSettingsScreen(),
    ),
    GalleryEntry(
      'F07-S13',
      'Xoá tài khoản — Confirm',
      build: (context) => DeleteAccountScreen(
        onConfirm: () => Navigator.of(context).maybePop(),
      ),
    ),
  ]),
];

// ───────────────────────────────────────────────────────────── helpers ──

void _pushWizard(BuildContext context, String imagePath) {
  Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => StampWizardScreen(
        imagePath: imagePath,
        onExit: () => Navigator.of(context).maybePop(),
        onViewAlbum: () => Navigator.of(context).maybePop(),
        onCreateAnother: () => Navigator.of(context).maybePop(),
      ),
    ),
  );
}

void _pushComposer(BuildContext context, String templateId) {
  Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => _buildComposerFlow(context, templateId)),
  );
}

Widget _buildComposerFlow(BuildContext context, String templateId) {
  return ComposerFlow(
    templateId: templateId,
    letters: GetIt.instance<LettersRepository>(),
    stamps: GetIt.instance<StampsRepository>(),
    linkBaseUrl: 'https://stampmail.app/letter',
    onClose: () => Navigator.of(context).maybePop(),
    onOpenShare: (_, _) {},
  );
}

/// Copies a bundled sample photo into a temp file, then builds with its
/// path — for screens that need a real file (wizard, crop).
class _WithSampleImage extends StatefulWidget {
  const _WithSampleImage({required this.builder});

  final Widget Function(String path) builder;

  @override
  State<_WithSampleImage> createState() => _WithSampleImageState();
}

class _WithSampleImageState extends State<_WithSampleImage> {
  String? _path;

  @override
  void initState() {
    super.initState();
    _materialize();
  }

  Future<void> _materialize() async {
    final bytes = await rootBundle.load('assets/design/f7-crop-photo.png');
    final file = File('${Directory.systemTemp.path}/preview-sample.png');
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    if (mounted) setState(() => _path = file.path);
  }

  @override
  Widget build(BuildContext context) {
    final path = _path;
    if (path == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return widget.builder(path);
  }
}

/// The stamp wizard over the bundled sample photo.
class _SampleImageWizard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _WithSampleImage(
      builder: (path) => StampWizardScreen(
        imagePath: path,
        onExit: () => Navigator.of(context).maybePop(),
        onViewAlbum: () => Navigator.of(context).maybePop(),
        onCreateAnother: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── gallery ──

class GalleryHome extends StatelessWidget {
  const GalleryHome({super.key, required this.themeMode});

  final ValueNotifier<ThemeMode> themeMode;

  @override
  Widget build(BuildContext context) {
    final sections = buildGallerySections();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design review — pencil-new.pen'),
        actions: [
          IconButton(
            tooltip: 'Đổi sáng/tối',
            icon: const Icon(Icons.brightness_6),
            onPressed: () => themeMode.value = themeMode.value == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark,
          ),
        ],
      ),
      body: ListView(
        children: [
          for (final section in sections) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                section.title,
                style: context.textTheme.titleLarge,
              ),
            ),
            for (final entry in section.entries) _EntryTile(entry),
          ],
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile(this.entry);

  final GalleryEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final (badge, color) = switch (entry.status) {
      EntryStatus.done => ('✓', context.semanticColors.success),
      EntryStatus.partial => ('◐', context.brand.gold),
      EntryStatus.missing => ('✗', scheme.error),
    };
    final enabled = entry.build != null;
    return ListTile(
      dense: true,
      enabled: enabled,
      leading: Text(
        badge,
        style: context.textTheme.titleMedium?.copyWith(color: color),
      ),
      title: Text('${entry.code} · ${entry.title}'),
      subtitle: entry.note == null ? null : Text(entry.note!),
      trailing: enabled ? const Icon(Icons.chevron_right, size: 18) : null,
      onTap: enabled
          ? () {
              // Reset switches, then apply this entry's overrides.
              previewSwitches
                ..emptyStamps = false
                ..emptyLetters = false
                ..quotaReached = false
                ..loginFails = false;
              entry.prepare?.call(previewSwitches);
              Navigator.of(context).push<void>(
                MaterialPageRoute(builder: entry.build!),
              );
            }
          : null,
    );
  }
}
