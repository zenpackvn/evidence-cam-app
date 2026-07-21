import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/creator_theme.dart';
import 'library_picker_screen.dart';

/// SM-005 — the in-app "Chọn từ thư viện" flow: requests photo-library access,
/// loads recent device images, and hands the selected photo's path to [onPicked]
/// (which advances to the "Xem trước ảnh" step). Renders loading / permission /
/// empty states around [LibraryPickerScreen].
class LibraryPickerFlow extends StatefulWidget {
  const LibraryPickerFlow({
    required this.gallery,
    required this.onPicked,
    this.onCamera,
    super.key,
  });

  final GalleryService gallery;

  /// Called with the picked photo's file path.
  final ValueChanged<String> onPicked;

  /// Optional "switch to camera" action for the segmented toggle.
  final VoidCallback? onCamera;

  @override
  State<LibraryPickerFlow> createState() => _LibraryPickerFlowState();
}

enum _Status { loading, denied, empty, ready }

class _LibraryPickerFlowState extends State<LibraryPickerFlow> {
  _Status _status = _Status.loading;
  List<GalleryImage> _images = const [];
  List<ImageProvider> _thumbs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final granted = await widget.gallery.ensurePermission();
    if (!mounted) return;
    if (!granted) {
      setState(() => _status = _Status.denied);
      return;
    }
    final images = await widget.gallery.recentImages();
    // Keep the two lists aligned: only surface images whose thumbnail decoded.
    final loaded = <GalleryImage>[];
    final thumbs = <ImageProvider>[];
    for (final image in images) {
      final bytes = await image.thumbnail();
      if (bytes != null) {
        loaded.add(image);
        thumbs.add(MemoryImage(bytes));
      }
    }
    if (!mounted) return;
    setState(() {
      _images = loaded;
      _thumbs = thumbs;
      _status = loaded.isEmpty ? _Status.empty : _Status.ready;
    });
  }

  Future<void> _pick(int index) async {
    final path = await _images[index].resolvePath();
    if (path != null) widget.onPicked(path);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_status) {
      _Status.loading => const _Message(child: CircularProgressIndicator()),
      _Status.denied => _Message(
        title: 'Chưa có quyền truy cập ảnh',
        message:
            'Cho phép StampMail truy cập thư viện ảnh để chọn ảnh tạo tem.',
        actionLabel: 'Mở cài đặt',
        onAction: widget.gallery.openSettings,
      ),
      _Status.empty => const _Message(
        title: 'Thư viện trống',
        message: 'Không tìm thấy ảnh nào trên thiết bị.',
      ),
      _Status.ready => LibraryPickerScreen(
        photos: _thumbs,
        onPick: _pick,
        title: 'Chọn từ thư viện',
        subtitle: 'Chạm để chọn ảnh bạn muốn tạo tem.',
        onCamera: widget.onCamera,
      ),
    };
  }
}

/// A centred status panel (loading / permission / empty) on the creator ground.
class _Message extends StatelessWidget {
  const _Message({
    this.child,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final Widget? child;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Scaffold(
      backgroundColor: CreatorColors.ground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ?child,
              if (title != null) ...[
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (message != null)
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
