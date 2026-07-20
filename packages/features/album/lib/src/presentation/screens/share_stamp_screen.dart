import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// The three content levels of SM-025 BR-02.
enum ShareLevel {
  /// Mức 1 — stamp only, letter content stays private.
  stampOnly,

  /// Mức 2 — stamp + a one-line quote the user picks from the letter.
  quote,

  /// Mức 3 — stamp + the full letter content.
  full,
}

/// SM-025 — "Chia sẻ tem": lay a stamp out for a social post, pick the aspect
/// ratio (9:16 story / 1:1 feed, BR-04), and share via the native sheet (BR-07)
/// with a mandatory watermark composited into the image (BR-06).
///
/// When [letterText] is provided (sharing from an opened letter), the content
/// level selector is shown: Mức 1 (chỉ tem) / Mức 2 (trích dẫn) / Mức 3 (toàn
/// văn), with a public-content warning before revealing anything (BR-02/BR-03).
/// From the Album there is no letter, so only Mức 1 applies.
class ShareStampScreen extends StatefulWidget {
  const ShareStampScreen({
    required this.stampImageUrl,
    required this.onShareImage,
    this.onSaveToGallery,
    this.letterText,
    super.key,
  });

  /// The stamp image to lay out. A URL (not the album `Stamp` entity) so this
  /// screen serves both the Album (SM-025) and the letter reveal (Mức 2/3).
  final String stampImageUrl;

  /// The opened letter's text when sharing from a reveal — enables Mức 2/3
  /// (SM-025 BR-02). Null when sharing a bare stamp from the Album.
  final String? letterText;

  /// Called with the captured PNG bytes when the user shares (BR-07). The host
  /// writes a temp file and opens the native share sheet.
  final Future<void> Function(Uint8List png) onShareImage;

  /// Called with the captured PNG to save it to the device gallery (BR-05).
  /// Returns whether the save succeeded, so the screen can confirm or warn.
  final Future<bool> Function(Uint8List png)? onSaveToGallery;

  @override
  State<ShareStampScreen> createState() => _ShareStampScreenState();
}

enum ShareFormat { story, feed }

class _ShareStampScreenState extends State<ShareStampScreen> {
  final GlobalKey _boundaryKey = GlobalKey();
  ShareFormat _format = ShareFormat.story;
  ShareLevel _level = ShareLevel.stampOnly;
  bool _busy = false;

  double get _aspect => _format == ShareFormat.story ? 9 / 16 : 1;

  bool get _hasLetter =>
      widget.letterText != null && widget.letterText!.trim().isNotEmpty;

  /// The text shown on the post for the current level (empty for Mức 1). Mức 2
  /// is the first line of the letter as the quote (BR-02).
  String get _overlayText {
    final text = widget.letterText?.trim() ?? '';
    return switch (_level) {
      ShareLevel.stampOnly => '',
      ShareLevel.quote => text.split('\n').first,
      ShareLevel.full => text,
    };
  }

  /// SM-025 BR-03: switching to a content-revealing level asks to confirm first.
  Future<void> _selectLevel(ShareLevel level) async {
    if (level == _level) return;
    if (level != ShareLevel.stampOnly) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nội dung thư sẽ công khai'),
          content: Text(
            level == ShareLevel.quote
                ? 'Một dòng trích từ thư sẽ hiển thị công khai trên ảnh chia sẻ.'
                : 'Toàn bộ nội dung thư sẽ hiển thị công khai trên ảnh chia sẻ.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Huỷ'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Tiếp tục'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => _level = level);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF6EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Chia sẻ tem',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: _ShareCanvas(
                      stampImageUrl: widget.stampImageUrl,
                      aspect: _aspect,
                      overlayText: _overlayText,
                    ),
                  ),
                ),
              ),
            ),
            if (_hasLetter) ...[
              _LevelSelector(level: _level, onChanged: _selectLevel),
              const SizedBox(height: AppSpacing.sm),
            ],
            _FormatToggle(
              format: _format,
              onChanged: (f) => setState(() => _format = f),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                0,
                AppSpacing.xxl,
                AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _share,
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.ios_share),
                      label: const Text('Chia sẻ'),
                    ),
                  ),
                  if (widget.onSaveToGallery != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : _saveToGallery,
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Lưu về thư viện'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final png = await _capturePng();
      await widget.onShareImage(png);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveToGallery() async {
    final save = widget.onSaveToGallery;
    if (save == null) return;
    setState(() => _busy = true);
    var ok = false;
    try {
      ok = await save(await _capturePng());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Đã lưu ảnh về thư viện'
              : 'Không lưu được ảnh. Kiểm tra quyền truy cập ảnh.',
        ),
      ),
    );
  }

  Future<Uint8List> _capturePng() async {
    final boundary =
        _boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('share canvas not mounted');
    }
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('failed to encode PNG');
    return data.buffer.asUint8List();
  }
}

/// The composited post: the stamp centered on a warm card with the mandatory
/// StampMail watermark baked in (BR-06 — part of the captured pixels, not an
/// overlay that could be stripped).
class _ShareCanvas extends StatelessWidget {
  const _ShareCanvas({
    required this.stampImageUrl,
    required this.aspect,
    this.overlayText = '',
  });

  final String stampImageUrl;
  final double aspect;

  /// The letter quote / full text to overlay (Mức 2/3); empty for Mức 1.
  final String overlayText;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspect,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFAF1E6), Color(0xFFF2E4D2)],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: AppNetworkImage(imageUrl: stampImageUrl),
                      ),
                    ),
                  ),
                  if (overlayText.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Text(
                          overlayText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Color(0xFF3A322C),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: _Watermark(),
            ),
          ],
        ),
      ),
    );
  }
}

/// SM-025 BR-02: the three content-level chips (only shown when a letter is
/// available). Selecting Mức 2/3 goes through the public-content warning.
class _LevelSelector extends StatelessWidget {
  const _LevelSelector({required this.level, required this.onChanged});

  final ShareLevel level;
  final ValueChanged<ShareLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        for (final (value, label) in const [
          (ShareLevel.stampOnly, 'Chỉ tem'),
          (ShareLevel.quote, 'Kèm trích dẫn'),
          (ShareLevel.full, 'Toàn bộ thư'),
        ])
          ChoiceChip(
            label: Text(label),
            selected: value == level,
            onSelected: (_) => onChanged(value),
          ),
      ],
    );
  }
}

/// The forced brand watermark (BR-06). Small, corner-anchored, always drawn.
class _Watermark extends StatelessWidget {
  const _Watermark();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mail_outline, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'StampMail',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatToggle extends StatelessWidget {
  const _FormatToggle({required this.format, required this.onChanged});

  final ShareFormat format;
  final ValueChanged<ShareFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ShareFormat>(
      segments: const [
        ButtonSegment(
          value: ShareFormat.story,
          icon: Icon(Icons.crop_portrait),
          label: Text('Dọc 9:16'),
        ),
        ButtonSegment(
          value: ShareFormat.feed,
          icon: Icon(Icons.crop_square),
          label: Text('Vuông 1:1'),
        ),
      ],
      selected: {format},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
