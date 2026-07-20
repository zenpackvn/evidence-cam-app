import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localization/localization.dart';

import '../widgets/widgets.dart';

/// F01-S10 — avatar upload after choosing a username: a 150px placeholder
/// circle with the heart badge, "library / camera" option rows, the coral
/// continue CTA, and a skip link.
///
/// UI-only: [onPickFromLibrary] / [onTakePhoto] resolve to a local file path
/// (the host wires the image picker); upload comes with the profile API.
class AvatarUploadScreen extends StatefulWidget {
  const AvatarUploadScreen({
    required this.onDone,
    this.onPickFromLibrary,
    this.onTakePhoto,
    super.key,
  });

  /// Called when the user continues (with or without a chosen photo) or skips.
  final VoidCallback onDone;

  final Future<String?> Function()? onPickFromLibrary;
  final Future<String?> Function()? onTakePhoto;

  @override
  State<AvatarUploadScreen> createState() => _AvatarUploadScreenState();
}

class _AvatarUploadScreenState extends State<AvatarUploadScreen> {
  String? _imagePath;

  Future<void> _pick(Future<String?> Function()? source) async {
    if (source == null) return;
    final path = await source();
    if (path != null && mounted) setState(() => _imagePath = path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthBrandHeader().animateSlideDown(),
          const SizedBox(height: 14),
          AuthHeading(
            title: '${l10n.smAvatarTitle} ✨',
            subtitle: l10n.smAvatarSubtitle,
          ).animateSlideDown(delay: 50.ms),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: _AvatarPreview(imagePath: _imagePath),
          ).animateFadeIn(delay: 100.ms),
          const SizedBox(height: AppSpacing.xxl),
          _OptionRow(
            icon: FontAwesomeIcons.image,
            label: l10n.smAvatarFromLibrary,
            onTap: () => _pick(widget.onPickFromLibrary),
          ).animateSlideLeft(delay: 150.ms),
          const SizedBox(height: AppSpacing.md),
          _OptionRow(
            icon: FontAwesomeIcons.camera,
            label: l10n.smAvatarTakePhoto,
            onTap: () => _pick(widget.onTakePhoto),
          ).animateSlideLeft(delay: 200.ms),
          const SizedBox(height: AppSpacing.xl),
          AuthPrimaryButton(
            label: l10n.smAvatarContinue,
            onPressed: widget.onDone,
          ).animateSlideUp(delay: 250.ms),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: widget.onDone,
              style: TextButton.styleFrom(
                foregroundColor: context.colorScheme.primary,
                textStyle: context.textTheme.titleMedium,
              ),
              child: Text(l10n.smAvatarSkip),
            ),
          ).animateSlideUp(delay: 300.ms),
        ],
      ),
    );
  }
}

/// The 150px avatar circle (warm placeholder fill, 5px white ring, 92px person
/// glyph) with the heart badge overlapping its bottom-right corner.
class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    return SizedBox(
      width: 170,
      height: 160,
      child: Stack(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFEFE7DE),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5),
              image: path == null
                  ? null
                  : DecorationImage(
                      image: FileImage(File(path)),
                      fit: BoxFit.cover,
                    ),
            ),
            child: path == null
                ? const Center(
                    child: FaIcon(
                      FontAwesomeIcons.solidUser,
                      size: 92,
                      color: Color(0xFFCDC3B8),
                    ),
                  )
                : null,
          ),
          Positioned(
            left: 112,
            top: 108,
            child: Image.asset(
              'assets/illustrations/avatar-heart-badge.png',
              package: 'feature_auth',
              width: 47,
              height: 48,
              excludeFromSemantics: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// .pen `Content/OptionRow`: white h56 radius-16 row with a leading 22px icon,
/// body-lg label, and trailing chevron.
class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final FaIconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Material(
      color: context.brand.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: context.brand.borderSubtle),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                FaIcon(icon, size: 22, color: scheme.onSurface),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(label, style: context.textTheme.bodyLarge),
                ),
                FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
