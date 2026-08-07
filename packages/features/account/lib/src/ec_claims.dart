/// Màn "Hồ sơ khiếu nại" — hai lớp.
///
/// **Lớp cha** ([EcClaimListScreen]): mỗi hồ sơ một dòng, hiện ngày giờ tạo và
/// một icon sao chép. **Lớp con** ([EcClaimDetailScreen]): mở ra thì thấy từng
/// mã vận đơn và các video/ảnh nằm trong nó, cộng một hàng đính kèm ảnh ở đáy
/// cho lúc người bán muốn bổ sung.
///
/// Package giao diện nên KHÔNG chạm tới `EcClaimDossier` của `shared_contracts`
/// — nó nhận những kiểu nhỏ khai ngay dưới đây. Việc quy đổi là của app shell.
library;

import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// Một hồ sơ trên màn danh sách.
class EcClaimEntry {
  const EcClaimEntry({
    required this.id,
    required this.dateLabel,
    required this.timeLabel,
    required this.orderCount,
    required this.evidenceCount,
  });

  final String id;

  /// `06/08/2026` — tách khỏi giờ để hai thứ vẽ hai cỡ chữ khác nhau.
  final String dateLabel;

  /// `17:42`.
  final String timeLabel;

  final int orderCount;
  final int evidenceCount;
}

/// Lớp cha: danh sách hồ sơ đã tạo, mới nhất trước.
class EcClaimListScreen extends StatelessWidget {
  const EcClaimListScreen({
    this.entries = const [],
    this.onBack,
    this.onOpen,
    this.onCopy,
    super.key,
  });

  final List<EcClaimEntry> entries;
  final VoidCallback? onBack;
  final ValueChanged<EcClaimEntry>? onOpen;
  final ValueChanged<EcClaimEntry>? onCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenScreen(
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
            child: Row(
              children: [
                PenBackButton(onTap: onBack),
                const SizedBox(width: 12),
                Expanded(
                  child: PenText(
                    l10n.claimsTitle,
                    size: 23,
                    color: PenColors.ink,
                    weight: FontWeight.w800,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
          // Dòng "lưu trên máy này" đứng NGAY dưới tiêu đề, không nhét xuống
          // đáy: người bán phải biết bằng chứng khiếu nại của mình chưa ở chỗ
          // nào an toàn TRƯỚC khi họ dựa vào nó, không phải sau khi đổi máy.
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: _LocalOnlyNote(text: l10n.claimsLocalOnlyNote),
          ),
          Expanded(child: _body(context, l10n)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.fileText,
                size: 44,
                color: PenColors.soft,
              ),
              const SizedBox(height: 12),
              PenText(
                l10n.claimsEmpty,
                size: 14,
                color: PenColors.mut,
                align: TextAlign.center,
                lineHeight: 1.5,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _ClaimRow(
        entry: entries[index],
        onTap: onOpen == null ? null : () => onOpen!(entries[index]),
        onCopy: onCopy == null ? null : () => onCopy!(entries[index]),
      ),
    );
  }
}

class _LocalOnlyNote extends StatelessWidget {
  const _LocalOnlyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => PenBox(
    width: double.infinity,
    fill: PenColors.bg,
    stroke: PenColors.line,
    radius: 12,
    axis: PenAxis.row,
    gap: 10,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    children: [
      const Icon(LucideIcons.info, size: 17, color: PenColors.mut),
      Expanded(
        child: PenText(text, size: 12, color: PenColors.mut, lineHeight: 1.45),
      ),
    ],
  );
}

class _ClaimRow extends StatelessWidget {
  const _ClaimRow({required this.entry, this.onTap, this.onCopy});

  final EcClaimEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EcTap(
      onTap: onTap,
      child: PenCard(
        axis: PenAxis.row,
        gap: 12,
        cross: CrossAxisAlignment.center,
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                PenText(
                  '${entry.dateLabel}  ${entry.timeLabel}',
                  size: 15,
                  color: PenColors.ink,
                  weight: FontWeight.w700,
                ),
                const SizedBox(height: 3),
                PenText(
                  l10n.claimsSummary(entry.orderCount, entry.evidenceCount),
                  size: 13,
                  color: PenColors.mut,
                ),
              ],
            ),
          ),
          // Sao chép là hành động RIÊNG, không phải mở hồ sơ — nên nó có vùng
          // chạm riêng chứ không nằm chung với phần bấm-để-mở.
          EcTap(
            onTap: onCopy,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(LucideIcons.copy, size: 20, color: PenColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Một mã vận đơn trong hồ sơ, cùng các bằng chứng của nó.
class EcClaimOrderGroup {
  const EcClaimOrderGroup({required this.tracking, required this.items});

  final String tracking;
  final List<EcClaimItem> items;
}

/// Một video/ảnh trong hồ sơ.
class EcClaimItem {
  const EcClaimItem({
    required this.id,
    required this.label,
    required this.time,
    this.isPhoto = false,
    this.thumbUrl,
    this.addedLater = false,
  });

  /// Khoá để bên gọi biết gỡ cái nào ra khỏi hồ sơ.
  final String id;
  final String label;
  final String time;
  final bool isPhoto;
  final String? thumbUrl;

  /// Người dùng đính thêm sau khi hồ sơ đã tạo — có nhãn riêng để phân biệt
  /// với bằng chứng quay trong ca.
  final bool addedLater;
}

/// Lớp con: nội dung một hồ sơ.
class EcClaimDetailScreen extends StatelessWidget {
  const EcClaimDetailScreen({
    required this.dateLabel,
    required this.timeLabel,
    this.groups = const [],
    this.onBack,
    this.onCopy,
    this.onDelete,
    this.onAttachPhoto,
    this.onRemoveItem,
    super.key,
  });

  final String dateLabel;
  final String timeLabel;
  final List<EcClaimOrderGroup> groups;
  final VoidCallback? onBack;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;

  /// Đính thêm ảnh vào MỘT mã vận đơn của hồ sơ. Nhận mã đơn vì hồ sơ có thể
  /// gồm nhiều đơn — không có nó thì ảnh không biết thuộc về đơn nào.
  final ValueChanged<String>? onAttachPhoto;

  /// Gỡ một bằng chứng khỏi hồ sơ: `(mã đơn, id bằng chứng)`. Cùng lý do với
  /// [onAttachPhoto] — id bằng chứng là duy nhất, nhưng mã đơn nói cho bên gọi
  /// biết phải sửa nhánh nào của hồ sơ.
  final void Function(String tracking, String evidenceId)? onRemoveItem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenScreen(
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
            child: Row(
              children: [
                PenBackButton(onTap: onBack),
                const SizedBox(width: 12),
                Expanded(
                  child: PenText(
                    '$dateLabel  $timeLabel',
                    size: 20,
                    color: PenColors.ink,
                    weight: FontWeight.w800,
                    softWrap: false,
                  ),
                ),
                EcTap(
                  onTap: onCopy,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      LucideIcons.copy,
                      size: 21,
                      color: PenColors.primary,
                    ),
                  ),
                ),
                if (onDelete != null)
                  EcTap(
                    onTap: onDelete,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        LucideIcons.trash2,
                        size: 21,
                        color: PenColors.danger,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              children: [
                for (final group in groups) ...[
                  _OrderGroupCard(
                    group: group,
                    onAttachPhoto: onAttachPhoto,
                    onRemoveItem: onRemoveItem,
                  ),
                  const SizedBox(height: 12),
                ],
                if (groups.isEmpty)
                  PenText(
                    l10n.timelineEmpty,
                    size: 14,
                    color: PenColors.mut,
                    align: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderGroupCard extends StatelessWidget {
  const _OrderGroupCard({
    required this.group,
    this.onAttachPhoto,
    this.onRemoveItem,
  });

  final EcClaimOrderGroup group;
  final ValueChanged<String>? onAttachPhoto;
  final void Function(String tracking, String evidenceId)? onRemoveItem;

  @override
  Widget build(BuildContext context) {
    return PenCard(
      axis: PenAxis.column,
      gap: 10,
      cross: CrossAxisAlignment.stretch,
      padding: const EdgeInsets.all(14),
      children: [
        PenText(
          group.tracking,
          size: 15,
          color: PenColors.ink,
          weight: FontWeight.w800,
        ),
        for (final item in group.items)
          _ClaimItemRow(
            item: item,
            onRemove: onRemoveItem == null
                ? null
                : () => onRemoveItem!(group.tracking, item.id),
          ),
        // Đính kèm ảnh ở ĐÁY mỗi mã đơn, không phải đáy màn: hồ sơ gồm nhiều
        // đơn thì một nút chung không nói được ảnh sắp thuộc về đơn nào.
        if (onAttachPhoto != null)
          _AttachPhotoRow(onTap: () => onAttachPhoto!(group.tracking)),
      ],
    );
  }
}

class _ClaimItemRow extends StatelessWidget {
  const _ClaimItemRow({required this.item, this.onRemove});

  final EcClaimItem item;

  /// Gỡ khỏi hồ sơ. `null` = không hiện icon.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => PenBox(
    width: double.infinity,
    axis: PenAxis.row,
    gap: 10,
    cross: CrossAxisAlignment.center,
    padding: const EdgeInsets.symmetric(vertical: 7),
    children: [
      Icon(
        item.isPhoto ? LucideIcons.image : LucideIcons.video,
        size: 17,
        color: PenColors.primary,
      ),
      Expanded(
        child: PenText(
          item.label,
          size: 14,
          color: PenColors.ink,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (item.addedLater)
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: PenText(
            context.l10n.claimsAddedLater,
            size: 11,
            color: PenColors.mut,
            softWrap: false,
          ),
        ),
      PenText(item.time, size: 12, color: PenColors.mut, softWrap: false),
      if (onRemove != null)
        // Vùng chạm rộng hơn icon: hàng chỉ cao 31pt và icon 17pt thì một ngón
        // tay chạm trượt sang dòng bên cạnh là chuyện thường.
        EcTap(
          onTap: onRemove,
          child: const Padding(
            padding: EdgeInsets.only(left: 4, top: 6, bottom: 6),
            child: Icon(LucideIcons.trash2, size: 17, color: PenColors.danger),
          ),
        ),
    ],
  );
}

class _AttachPhotoRow extends StatelessWidget {
  const _AttachPhotoRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => EcTap(
    onTap: onTap,
    child: PenBox(
      width: double.infinity,
      height: 44,
      fill: PenColors.card,
      stroke: PenColors.line,
      radius: 12,
      axis: PenAxis.row,
      gap: 8,
      main: MainAxisAlignment.center,
      cross: CrossAxisAlignment.center,
      children: [
        const Icon(LucideIcons.imagePlus, size: 18, color: PenColors.ink),
        PenText(
          context.l10n.attachPhotoToOrder,
          size: 14,
          color: PenColors.ink,
          weight: FontWeight.w600,
          softWrap: false,
        ),
      ],
    ),
  );
}
