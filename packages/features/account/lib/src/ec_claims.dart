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

import 'dart:async';

import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoTextField;
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
    this.onOpen,
    this.onCopy,
    this.onCreate,
    this.onNavOrders,
    this.onNavRecord,
    super.key,
  });

  final List<EcClaimEntry> entries;
  final ValueChanged<EcClaimEntry>? onOpen;
  final ValueChanged<EcClaimEntry>? onCopy;

  /// Dấu cộng góc phải: mở màn tạo hồ sơ. Đây là lối tạo DUY NHẤT — trang Vận
  /// đơn không còn nút gộp nào, vì việc tạo hồ sơ thuộc về màn hồ sơ.
  final VoidCallback? onCreate;

  /// Màn này là tab thứ ba, nên nó mang thanh điều hướng chứ không mang nút
  /// back.
  final VoidCallback? onNavOrders;
  final VoidCallback? onNavRecord;

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
                Expanded(
                  child: PenText(
                    l10n.claimsTitle,
                    size: 23,
                    color: PenColors.ink,
                    weight: FontWeight.w800,
                    softWrap: false,
                  ),
                ),
                if (onCreate != null)
                  EcTap(
                    onTap: onCreate,
                    child: PenBox(
                      width: 40,
                      height: 40,
                      fill: PenColors.primary,
                      radius: 999,
                      axis: PenAxis.row,
                      main: MainAxisAlignment.center,
                      cross: CrossAxisAlignment.center,
                      children: const [
                        Icon(
                          LucideIcons.plus,
                          size: 22,
                          color: PenColors.card,
                        ),
                      ],
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
          _ClaimsNavBar(onOrders: onNavOrders, onRecord: onNavRecord),
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

/// Thanh điều hướng ba tab, bản của màn Hồ sơ khiếu nại (tab thứ ba).
class _ClaimsNavBar extends StatelessWidget {
  const _ClaimsNavBar({this.onOrders, this.onRecord});

  final VoidCallback? onOrders;
  final VoidCallback? onRecord;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenTabBar(
      activeIndex: 2,
      tabs: [
        (LucideIcons.package, l10n.navOrders, onOrders),
        (LucideIcons.camera, l10n.navRecord, onRecord),
        (LucideIcons.fileText, l10n.navClaims, null),
      ],
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
  const EcClaimOrderGroup({
    required this.tracking,
    required this.items,
    this.dateLabel,
    this.timeLabel,
  });

  final String tracking;

  /// Ngày và giờ của bằng chứng mới nhất trong đơn này. `null` ở hồ sơ tạo
  /// trước khi mốc thời gian được lưu — lúc đó dòng chỉ hiện mã, không bịa ra
  /// một ngày nào.
  final String? dateLabel;
  final String? timeLabel;

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
        // Mã vận đơn + ngày giờ. Một hồ sơ gộp nhiều đơn thì các đơn có thể ở
        // khác ngày, nên chỉ hiện giờ là không đủ để phân biệt.
        Row(
          children: [
            Expanded(
              child: PenText(
                group.tracking,
                size: 15,
                color: PenColors.ink,
                weight: FontWeight.w800,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (group.dateLabel != null)
              PenText(
                '${group.dateLabel}  ${group.timeLabel ?? ''}'.trim(),
                size: 12,
                color: PenColors.mut,
                softWrap: false,
              ),
          ],
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

/// Một bằng chứng có thể tick khi tạo hồ sơ, đủ để người dùng nhận ra nó là
/// cái nào: loại, giờ quay, và ảnh hay video.
class EcClaimPickable {
  const EcClaimPickable({
    required this.id,
    required this.label,
    required this.time,
    this.isPhoto = false,
    this.capturedAt,
  });

  final String id;
  final String label;
  final String time;
  final bool isPhoto;

  /// Lúc quay/chụp, epoch ms — để hồ sơ hiện được ngày ở dòng mã vận đơn.
  final int? capturedAt;
}

/// Phần đã tick của MỘT mã vận đơn, khi bấm tạo hồ sơ.
class EcClaimOrderPicks {
  const EcClaimOrderPicks({required this.orderCode, required this.picked});

  final String orderCode;
  final List<EcClaimPickable> picked;
}

/// Màn tạo hồ sơ khiếu nại: tra một mã vận đơn, rồi tick những video/ảnh của
/// nó.
///
/// Trước đây việc này nằm ở trang Vận đơn — một nút cộng nổi mở ra chế độ tick
/// ngay trên danh sách đơn. Nhưng tạo hồ sơ là việc của màn Hồ sơ, và ở trang
/// Vận đơn nó phải sống chung với tìm kiếm, phân trang, ba chip lọc; mỗi thứ
/// đều đổi được danh sách bên dưới những gì đang tick.
///
/// Ở đây chỉ có một mã đơn tại một thời điểm, nên không có gì trôi mất.
class EcCreateClaimScreen extends StatefulWidget {
  const EcCreateClaimScreen({
    required this.onSearch,
    this.onBack,
    this.onScan,
    this.onCreate,
    super.key,
  });

  /// Tra một mã vận đơn. Trả `null` khi không có đơn nào khớp, trả danh sách
  /// rỗng khi đơn có thật nhưng chưa có bằng chứng nào.
  final Future<List<EcClaimPickable>?> Function(String code) onSearch;

  /// Mở máy quét, trả về mã đọc được.
  final Future<String?> Function()? onScan;

  final VoidCallback? onBack;

  /// Tạo hồ sơ từ MỌI mã đơn đã tra và phần đã tick của từng mã.
  final ValueChanged<List<EcClaimOrderPicks>>? onCreate;

  @override
  State<EcCreateClaimScreen> createState() => _EcCreateClaimScreenState();
}

class _EcCreateClaimScreenState extends State<EcCreateClaimScreen> {
  final _search = TextEditingController();

  String? _code;
  List<EcClaimPickable>? _items;

  /// Mọi mã đã tra trong lượt này, theo đúng thứ tự tra.
  ///
  /// Giữ lại để tra mã thứ hai KHÔNG làm mất phần đã tick ở mã thứ nhất — một
  /// hồ sơ khiếu nại thường gộp vài đơn, mà quét xong mất sạch lựa chọn cũ thì
  /// người dùng phải làm lại từ đầu và sẽ không bao giờ gộp quá một đơn.
  final Map<String, List<EcClaimPickable>> _seen = {};

  /// Id đã tick, chung cho MỌI mã. Id bằng chứng là duy nhất toàn hệ thống nên
  /// một tập phẳng là đủ.
  final Set<String> _picked = <String>{};

  bool _loading = false;
  bool _notFound = false;

  /// Số bằng chứng đã tick trên tất cả các mã — con số hiện ở nút tạo.
  int get _pickedCount => _picked.length;

  /// Gom theo mã, bỏ mã nào không còn cái nào được tick.
  List<EcClaimOrderPicks> get _batch => [
    for (final e in _seen.entries)
      if (e.value.any((i) => _picked.contains(i.id)))
        EcClaimOrderPicks(
          orderCode: e.key,
          picked: [
            for (final i in e.value)
              if (_picked.contains(i.id)) i,
          ],
        ),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _lookup(String raw) async {
    final code = raw.trim();
    if (code.isEmpty || _loading) return;
    // KHÔNG xoá `_picked`: tra mã mới là để THÊM vào hồ sơ, không phải bắt đầu
    // lại. Xoá đi thì mọi hồ sơ đều chỉ gộp được đúng một đơn.
    setState(() {
      _loading = true;
      _notFound = false;
      _items = null;
    });
    final found = await widget.onSearch(code);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _code = code;
      _items = found;
      _notFound = found == null;
      // Không tick sẵn gì cả. Đơn có chục clip mà người bán chỉ cần một cái để
      // khiếu nại thì tick sẵn hết bắt họ bỏ chín — nhiều thao tác hơn hẳn tự
      // tick một.
      if (found != null) _seen[code] = found;
    });
  }

  Future<void> _scan() async {
    final code = await widget.onScan?.call();
    if (code == null || code.isEmpty || !mounted) return;
    _search.text = code;
    await _lookup(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = _items ?? const <EcClaimPickable>[];
    return PenScreen(
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
            child: Row(
              children: [
                PenBackButton(onTap: widget.onBack),
                const SizedBox(width: 12),
                Expanded(
                  child: PenText(
                    l10n.claimsCreateTitle,
                    size: 21,
                    color: PenColors.ink,
                    weight: FontWeight.w800,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: _SearchScanBar(
              controller: _search,
              hint: l10n.claimsCreateSearchHint,
              onSubmit: _lookup,
              onScan: widget.onScan == null ? null : () => unawaited(_scan()),
            ),
          ),
          Expanded(child: _body(context, l10n, items)),
          // Nút tạo hiện NGAY KHI đã tick được thứ gì, kể cả lúc đang tra một
          // mã khác chưa ra kết quả: phần đã tick ở mã trước vẫn còn nguyên,
          // giấu nút đi thì trông như chúng đã mất.
          if (_pickedCount > 0)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: _CreateClaimButton(
                  count: _pickedCount,
                  onTap: widget.onCreate == null
                      ? null
                      : () => widget.onCreate!(_batch),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    List<EcClaimPickable> items,
  ) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    // Ba trạng thái rỗng KHÁC NHAU, không gộp thành một: chưa tra gì, tra
    // không thấy mã, và mã có thật nhưng đơn chưa có bằng chứng. Gộp lại thì
    // người dùng không biết mình gõ sai mã hay đơn thật sự trống.
    if (_notFound) {
      return _Hint(icon: LucideIcons.searchX, text: l10n.claimsCreateNoOrder);
    }
    if (_items == null) {
      return _Hint(icon: LucideIcons.scanLine, text: l10n.claimsCreateStart);
    }
    if (items.isEmpty) {
      return _Hint(icon: LucideIcons.fileText, text: l10n.timelineEmpty);
    }
    final allPicked = items.every((e) => _picked.contains(e.id));
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      children: [
        Row(
          children: [
            Expanded(
              child: PenText(
                _code ?? '',
                size: 16,
                color: PenColors.ink,
                weight: FontWeight.w800,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            EcTap(
              onTap: () => setState(() {
                if (allPicked) {
                  _picked.clear();
                } else {
                  _picked.addAll(items.map((e) => e.id));
                }
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Icon(
                  allPicked ? LucideIcons.squareCheckBig : LucideIcons.square,
                  size: 26,
                  color: allPicked ? PenColors.primary : PenColors.ink,
                ),
              ),
            ),
          ],
        ),
        for (final e in items)
          _PickRow(
            item: e,
            picked: _picked.contains(e.id),
            onTap: () => setState(() {
              if (!_picked.remove(e.id)) _picked.add(e.id);
            }),
          ),
      ],
    );
  }
}

/// Ô tra mã + nút quét, cùng khuôn với thanh tìm kiếm ở trang Vận đơn: một ô
/// duy nhất, vạch ngăn, rồi nút quét nằm BÊN TRONG ô.
class _SearchScanBar extends StatelessWidget {
  const _SearchScanBar({
    required this.controller,
    required this.hint,
    required this.onSubmit,
    this.onScan,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onSubmit;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) => PenBox(
    height: 56,
    fill: PenColors.card,
    stroke: PenColors.line,
    radius: 14,
    axis: PenAxis.row,
    gap: 10,
    cross: CrossAxisAlignment.center,
    padding: const EdgeInsets.only(left: 16, right: 8),
    children: [
      const Icon(LucideIcons.search, size: 22, color: PenColors.mut),
      Expanded(
        child: CupertinoTextField(
          controller: controller,
          padding: EdgeInsets.zero,
          decoration: const BoxDecoration(),
          placeholder: hint,
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmit,
          style: const TextStyle(fontSize: 15, color: PenColors.ink),
        ),
      ),
      if (onScan != null) ...[
        const PenBox(width: 1, height: 26, fill: PenColors.line),
        EcTap(
          onTap: onScan,
          child: const PenBox(
            width: 40,
            height: 40,
            fill: PenColors.bg,
            radius: 10,
            axis: PenAxis.row,
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.center,
            children: [
              Icon(LucideIcons.scanLine, size: 21, color: PenColors.ink),
            ],
          ),
        ),
      ],
    ],
  );
}

class _PickRow extends StatelessWidget {
  const _PickRow({
    required this.item,
    required this.picked,
    required this.onTap,
  });

  final EcClaimPickable item;
  final bool picked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => EcTap(
    onTap: onTap,
    child: PenBox(
      width: double.infinity,
      axis: PenAxis.row,
      gap: 10,
      cross: CrossAxisAlignment.center,
      padding: const EdgeInsets.symmetric(vertical: 9),
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
        PenText(item.time, size: 12, color: PenColors.mut, softWrap: false),
        Icon(
          picked ? LucideIcons.squareCheckBig : LucideIcons.square,
          size: 20,
          color: picked ? PenColors.primary : PenColors.mut,
        ),
      ],
    ),
  );
}

class _CreateClaimButton extends StatelessWidget {
  const _CreateClaimButton({required this.count, this.onTap});

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => EcTap(
    onTap: onTap,
    child: PenBox(
      width: double.infinity,
      height: 54,
      fill: onTap == null ? PenColors.soft : PenColors.primary,
      radius: 14,
      axis: PenAxis.row,
      gap: 10,
      main: MainAxisAlignment.center,
      cross: CrossAxisAlignment.center,
      children: [
        const Icon(LucideIcons.fileText, size: 20, color: PenColors.card),
        PenText(
          '${context.l10n.bundleCreateClaim} ($count)',
          size: 16,
          color: PenColors.card,
          weight: FontWeight.w700,
          softWrap: false,
        ),
      ],
    ),
  );
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: PenColors.soft),
          const SizedBox(height: 12),
          PenText(
            text,
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
