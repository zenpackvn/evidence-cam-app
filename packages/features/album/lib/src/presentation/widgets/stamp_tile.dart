import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/stamp.dart';

/// A single stamp in the Album grid (F02-S10 tem cell): just the stamp image
/// with a rounded clip. Every stamp renders identically — no source label or
/// badge (SM-022 BR-03: no "Tem mẫu"/"Nhận từ…" distinction in the Album).
class StampTile extends StatelessWidget {
  const StampTile({required this.stamp, required this.onTap, super.key});

  final Stamp stamp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: AppNetworkImage(
          imageUrl: stamp.thumbUrl ?? stamp.imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
