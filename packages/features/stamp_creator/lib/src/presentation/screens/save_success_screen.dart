import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/filters.dart';
import '../../domain/stamp_draft.dart';
import '../widgets/creator_theme.dart';

/// SM-011 success — "Đã lưu vào Album!" (F02-S09): a celebratory confirmation
/// with a rainbow save glyph, a result card showing the saved stamp's thumbnail
/// and name, and two actions (view album / create another).
class SaveSuccessScreen extends StatelessWidget {
  const SaveSuccessScreen({
    required this.onViewAlbum,
    required this.onCreateAnother,
    this.draft,
    this.stampName = 'Con tem mới',
    super.key,
  });

  final VoidCallback onViewAlbum;
  final VoidCallback onCreateAnother;

  /// The saved stamp, used to render the result-card thumbnail. Null renders a
  /// neutral placeholder (e.g. in isolation / tests).
  final StampDraft? draft;

  /// The name the user gave the stamp on the finish step; shown on the card.
  final String stampName;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Scaffold(
      backgroundColor: CreatorColors.ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Text(
                'Đã lưu vào Album!',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Con tem của bạn đã được lưu thành công\nvào bộ sưu tập.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.47,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SaveGlyph(),
              const SizedBox(height: AppSpacing.lg),
              _ResultCard(draft: draft, stampName: stampName),
              const Spacer(flex: 3),
              _PrimaryButton(label: 'Xem Album', onTap: onViewAlbum),
              const SizedBox(height: AppSpacing.md),
              _SecondaryButton(label: 'Tạo tem mới', onTap: onCreateAnother),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

/// The rainbow "saved" glyph: a pastel-gradient stamp holding a heart, ringed by
/// sparkles (F02-S09 glyphWrap).
class _SaveGlyph extends StatelessWidget {
  const _SaveGlyph();

  static const _gold = Color(0xFFF5BC58);
  static const _coral = Color(0xFFF26B4E);
  static const _purple = Color(0xFFB48CE0);
  static const _sky = Color(0xFFA9D4EB);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 232,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rainbow glow.
          Container(
            width: 196,
            height: 208,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFAD0E0),
                  Color(0xFFFDE7C7),
                  Color(0xFFFFF3C4),
                  Color(0xFFCDEBCB),
                  Color(0xFFC7E4F5),
                  Color(0xFFDCCBF0),
                ],
              ),
            ),
          ),
          // White stamp card with a heart.
          Container(
            width: 128,
            height: 148,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.favorite, size: 52, color: _coral),
            ),
          ),
          // Sparkles.
          const Positioned(
            top: 30,
            left: 18,
            child: Icon(Icons.auto_awesome, size: 18, color: _gold),
          ),
          Positioned(
            top: 22,
            right: 16,
            child: Icon(
              Icons.auto_awesome,
              size: 20,
              color: _coral.withValues(alpha: 0.8),
            ),
          ),
          const Positioned(
            bottom: 24,
            right: 30,
            child: Icon(Icons.auto_awesome, size: 15, color: _purple),
          ),
          const Positioned(
            bottom: 34,
            left: 22,
            child: Icon(Icons.auto_awesome, size: 13, color: _sky),
          ),
        ],
      ),
    );
  }
}

/// The elevated card summarising the save: the stamp thumbnail, its name, and an
/// "Đã thêm vào Album" note (F02-S09 resultCard).
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.draft, required this.stampName});

  final StampDraft? draft;
  final String stampName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F24211F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _ResultThumb(draft: draft),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stampName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Đã thêm vào Album',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultThumb extends StatelessWidget {
  const _ResultThumb({required this.draft});

  final StampDraft? draft;

  @override
  Widget build(BuildContext context) {
    final draft = this.draft;
    final file = draft == null ? null : File(draft.imagePath);
    final Widget image;
    if (file != null && file.existsSync()) {
      final photo = Image.file(file, fit: BoxFit.cover);
      final filter = effectiveColorFilter(draft!);
      image = filter == null
          ? photo
          : ColorFiltered(colorFilter: filter, child: photo);
    } else {
      image = ColoredBox(
        color: context.colorScheme.secondaryContainer,
        child: const Center(child: Icon(Icons.image_outlined, size: 20)),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(width: 54, height: 62, child: image),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Text(
              label,
              style: context.textTheme.titleMedium?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Text(
              label,
              style: context.textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
