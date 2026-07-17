import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../domain/entities/stamp.dart';

/// SM-025 — "Chia sẻ tem": lay a stamp out for a social post, pick the aspect
/// ratio (9:16 story / 1:1 feed, BR-04), and share via the native sheet (BR-07)
/// with a mandatory watermark composited into the image (BR-06).
///
/// Sharing from the Album only has the stamp (no letter context), so this is
/// the Mức-1 "chỉ tem" flow (BR-02); Mức 2/3 need a letter and belong to the
/// letter-reveal share path.
class ShareStampScreen extends StatefulWidget {
  const ShareStampScreen({
    required this.stamp,
    required this.onShareImage,
    super.key,
  });

  final Stamp stamp;

  /// Called with the captured PNG bytes when the user shares (BR-07). The host
  /// writes a temp file and opens the native share sheet.
  final Future<void> Function(Uint8List png) onShareImage;

  @override
  State<ShareStampScreen> createState() => _ShareStampScreenState();
}

enum ShareFormat { story, feed }

class _ShareStampScreenState extends State<ShareStampScreen> {
  final GlobalKey _boundaryKey = GlobalKey();
  ShareFormat _format = ShareFormat.story;
  bool _sharing = false;

  double get _aspect => _format == ShareFormat.story ? 9 / 16 : 1;

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
                      stamp: widget.stamp,
                      aspect: _aspect,
                    ),
                  ),
                ),
              ),
            ),
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
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _sharing ? null : _share,
                  icon: _sharing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.ios_share),
                  label: const Text('Chia sẻ'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final png = await _capturePng();
      await widget.onShareImage(png);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
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
  const _ShareCanvas({required this.stamp, required this.aspect});

  final Stamp stamp;
  final double aspect;

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
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: AppNetworkImage(imageUrl: stamp.imageUrl),
                  ),
                ),
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

/// The forced brand watermark (BR-06). Small, corner-anchored, always drawn.
class _Watermark extends StatelessWidget {
  const _Watermark();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
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
