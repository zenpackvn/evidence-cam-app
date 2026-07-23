import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/stamp.dart';

/// A single stamp in the Album grid (F02-S10 tem cell): the stamp image with
/// a rounded clip and a one-line caption underneath — the stamp's name, or
/// its save date when unnamed (SM-022 BR-08 default). Every stamp renders
/// identically — no source label or badge (SM-022 BR-03: no "Tem mẫu"/"Nhận
/// từ…" distinction in the Album). The caption follows the collection-grid
/// convention (item image + name label) so a stamp stays identifiable at a
/// glance.
class StampTile extends StatelessWidget {
  const StampTile({required this.stamp, required this.onTap, super.key});

  final Stamp stamp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final caption = stamp.name.isNotEmpty
        ? stamp.name
        : _formatDate(stamp.createdAt);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: AppNetworkImage(
                imageUrl: stamp.thumbUrl ?? stamp.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}
