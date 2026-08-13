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
import 'dart:io';

import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoActivityIndicator, CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MaxLengthEnforcement;
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
    this.onRemoveItem,
    this.onItemTap,
    super.key,
  });

  final String dateLabel;
  final String timeLabel;
  final List<EcClaimOrderGroup> groups;
  final VoidCallback? onBack;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;

  /// Gỡ một bằng chứng khỏi hồ sơ: `(mã đơn, id bằng chứng)`. Id bằng chứng là
  /// duy nhất, nhưng mã đơn nói cho bên gọi biết phải sửa nhánh nào của hồ sơ.
  final void Function(String tracking, String evidenceId)? onRemoveItem;

  /// Mở chi tiết một bằng chứng: `(mã đơn, id bằng chứng)`. `null` = hàng không
  /// bấm được, dùng khi bên gọi chưa có đường đọc chi tiết.
  final void Function(String tracking, String evidenceId)? onItemTap;

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
                    onRemoveItem: onRemoveItem,
                    onItemTap: onItemTap,
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
    this.onRemoveItem,
    this.onItemTap,
  });

  final EcClaimOrderGroup group;
  final void Function(String tracking, String evidenceId)? onRemoveItem;
  final void Function(String tracking, String evidenceId)? onItemTap;

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
            onTap: onItemTap == null
                ? null
                : () => onItemTap!(group.tracking, item.id),
          ),
      ],
    );
  }
}

/// Một bằng chứng trong hồ sơ, vẽ theo ĐÚNG hình dạng hàng ở dòng thời gian
/// của mã vận đơn: giờ bên trái, chấm tròn, rồi một thẻ có ảnh thu nhỏ và nhãn.
///
/// Cố ý dựng lại ở đây thay vì dùng chung widget của package `orders`: hai bên
/// bám vào hai kiểu dữ liệu khác nhau (`EcTimelineVideo` có trạng thái niêm
/// phong, thời lượng, link phát; `EcClaimItem` chỉ có id/nhãn/giờ/ảnh). Ghép
/// chúng vào một widget chung sẽ đẻ ra một kiểu thứ ba mà chẳng bên nào dùng
/// trọn vẹn. Thứ phải giống nhau là HÌNH DẠNG, và nó nằm trọn trong hàm này.
class _ClaimItemRow extends StatelessWidget {
  const _ClaimItemRow({required this.item, this.onRemove, this.onTap});

  final EcClaimItem item;

  /// Gỡ khỏi hồ sơ. `null` = không hiện icon.
  final VoidCallback? onRemove;

  /// Mở chi tiết bằng chứng. `null` = thẻ không bấm được.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: 46,
        child: PenText(item.time, size: 14, color: PenColors.mut),
      ),
      const SizedBox(
        width: 22,
        height: 58,
        child: Center(
          child: PenEllipse(width: 11, height: 11, color: PenColors.ink),
        ),
      ),
      Expanded(
        child: PenCard(
          lifted: false,
          gap: 12,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 11),
          onTap: onTap,
          children: [
            _ClaimItemThumb(item: item),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  PenText(
                    item.label,
                    size: 14,
                    color: PenColors.ink,
                    weight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.addedLater) ...[
                    const SizedBox(height: 4),
                    PenText(
                      context.l10n.claimsAddedLater,
                      size: 11,
                      color: PenColors.mut,
                      softWrap: false,
                    ),
                  ],
                ],
              ),
            ),
            if (onRemove != null)
              // Vùng chạm rộng hơn icon: ngón tay chạm trượt sang thẻ bên cạnh
              // là chuyện thường.
              EcTap(
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    LucideIcons.x,
                    size: 17,
                    color: PenColors.danger,
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

/// Ô vuông đầu hàng: ảnh thu nhỏ của bằng chứng, không có thì rơi về icon.
///
/// Mọi đường rơi đều về cùng một ô icon, nên ảnh thiếu hay hỏng nhìn vẫn giống
/// thiết kế chứ không giống một lỗi.
class _ClaimItemThumb extends StatelessWidget {
  const _ClaimItemThumb({required this.item});

  final EcClaimItem item;

  @override
  Widget build(BuildContext context) {
    final url = item.thumbUrl;
    final fallback = PenBox(
      width: 38,
      height: 38,
      fill: PenColors.line,
      radius: 10,
      axis: PenAxis.row,
      main: MainAxisAlignment.center,
      cross: CrossAxisAlignment.center,
      children: [
        Icon(
          item.isPhoto ? LucideIcons.image : LucideIcons.video,
          size: 18,
          color: PenColors.ink,
        ),
      ],
    );
    if (url == null || url.isEmpty) return fallback;
    // Ảnh đính kèm chưa tải lên thì `url` là ĐƯỜNG DẪN FILE trên máy, không
    // phải link mạng. Đưa nó cho `Image.network` là hỏng im lặng, rơi về icon
    // đúng lúc người dùng vừa tự tay chọn ảnh đó.
    final remote = url.startsWith('http');
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: remote
          ? Image.network(
              url,
              width: 38,
              height: 38,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : fallback,
            )
          : Image.file(
              File(url),
              width: 38,
              height: 38,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

class EcClaimPickable {
  const EcClaimPickable({
    required this.id,
    required this.label,
    required this.time,
    this.orderId,
    this.isPhoto = false,
    this.capturedAt,
    this.day,
    this.thumbUrl,
  });

  final String id;

  /// Id của ĐƠN chứa bằng chứng này trên máy chủ. Hồ sơ giữ lại để về sau còn
  /// đọc được chi tiết bằng chứng (thời lượng, thiết bị, trạng thái niêm
  /// phong) — những thứ hồ sơ không tự lưu.
  final String? orderId;

  final String label;
  final String time;
  final bool isPhoto;

  /// Lúc quay/chụp, epoch ms — để hồ sơ hiện được ngày ở dòng mã vận đơn.
  final int? capturedAt;

  /// Nhãn ngày đã định dạng sẵn ("07/08/2026"), dùng làm tiêu đề nhóm.
  ///
  /// Định dạng ở tầng app chứ không ở đây, để màn này và dòng thời gian của
  /// một đơn luôn ghi ngày giống hệt nhau.
  final String? day;

  /// Ảnh đại diện của clip. `null` → rơi về ô icon.
  final String? thumbUrl;
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

  /// Tạo hồ sơ từ MỌI mã đơn đã tra và phần đã tick của từng mã, kèm tên hồ sơ.
  ///
  /// Tên rỗng là hợp lệ — máy chủ tự đặt theo mã vận đơn đầu tiên. Không chặn
  /// người dùng ở đây: bắt gõ tên mới cho tạo, giữa ca đóng hàng, là đổi một
  /// hồ sơ có tên xấu lấy một hồ sơ không bao giờ được tạo.
  final void Function(List<EcClaimOrderPicks> batch, String title)? onCreate;

  @override
  State<EcCreateClaimScreen> createState() => _EcCreateClaimScreenState();
}

class _EcCreateClaimScreenState extends State<EcCreateClaimScreen> {
  final _search = TextEditingController();

  /// Tên hồ sơ. Điền sẵn bằng mã đầu tiên tra được, sửa được.
  final _title = TextEditingController();

  /// Mọi mã đã tra trong lượt này, theo đúng thứ tự tra.
  ///
  /// Giữ lại để tra mã thứ hai KHÔNG làm mất phần đã tick ở mã thứ nhất — một
  /// hồ sơ khiếu nại thường gộp vài đơn, mà quét xong mất sạch lựa chọn cũ thì
  /// người dùng phải làm lại từ đầu và sẽ không bao giờ gộp quá một đơn.
  final Map<String, List<EcClaimPickable>> _seen = {};

  /// Thứ tự hiện ra: mã quét gần nhất đứng đầu.
  final List<String> _order = [];

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
    _title.dispose();
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
    });
    final found = await widget.onSearch(code);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _notFound = found == null;
      // Không tick sẵn gì cả. Đơn có chục clip mà người bán chỉ cần một cái để
      // khiếu nại thì tick sẵn hết bắt họ bỏ chín — nhiều thao tác hơn hẳn tự
      // tick một.
      if (found != null) {
        // Mã mới lên ĐẦU: người bán vừa quét cái gì thì muốn thấy ngay cái đó,
        // không phải cuộn qua mọi mã đã quét trước để tìm.
        _seen
          ..remove(code)
          ..[code] = found;
        _order
          ..remove(code)
          ..insert(0, code);
        // Tên mặc định là mã ĐẦU TIÊN tra được. Người bán bấm tạo ngay thì hồ
        // sơ đã có một cái tên phân biệt được với vụ khác, khỏi phải nghĩ ra
        // tên giữa ca đóng hàng. Chỉ điền khi ô còn trống — gõ rồi mà lượt tra
        // sau đè lên là mất chữ vừa gõ.
        if (_title.text.trim().isEmpty) _title.text = code;
      }
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
          Expanded(child: _body(context, l10n)),
          // Nút tạo hiện NGAY KHI đã tick được thứ gì, kể cả lúc đang tra một
          // mã khác chưa ra kết quả: phần đã tick ở mã trước vẫn còn nguyên,
          // giấu nút đi thì trông như chúng đã mất.
          if (_pickedCount > 0)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ô tên đứng NGAY TRÊN nút tạo chứ không ở đầu màn: lúc mới
                    // mở màn chưa có gì để đặt tên, còn ở đây người bán vừa tick
                    // xong và đang nhìn đúng những đơn sắp gộp lại.
                    _ClaimNameField(
                      controller: _title,
                      hint: l10n.claimsCreateNameHint,
                    ),
                    const SizedBox(height: 10),
                    _CreateClaimButton(
                      count: _pickedCount,
                      onTap: widget.onCreate == null
                          ? null
                          : () => widget.onCreate!(_batch, _title.text.trim()),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n) {
    // Chưa quét được mã nào: ba trạng thái rỗng KHÁC NHAU, không gộp thành một
    // — đang tra, tra không thấy mã, và chưa tra gì. Gộp lại thì người dùng
    // không biết mình gõ sai mã hay app đang bận.
    if (_order.isEmpty) {
      if (_loading) {
        return const Center(child: CircularProgressIndicator.adaptive());
      }
      if (_notFound) {
        return _Hint(icon: LucideIcons.searchX, text: l10n.claimsCreateNoOrder);
      }
      return _Hint(icon: LucideIcons.scanLine, text: l10n.claimsCreateStart);
    }
    // Đã có mã trên màn: lượt tra mới KHÔNG được thay chỗ chúng. Báo trạng
    // thái bằng một dòng ở đầu, còn danh sách cũ vẫn nguyên bên dưới — quét
    // nhầm một mã mà mất sạch phần đã tick là hỏng cả buổi làm.
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Center(child: CupertinoActivityIndicator()),
          )
        else if (_notFound)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: PenText(
              l10n.claimsCreateNoOrder,
              size: 13,
              color: PenColors.danger,
            ),
          ),
        for (final code in _order) ...[
          _OrderPickSection(
            code: code,
            items: _seen[code]!,
            picked: _picked,
            onToggle: (id) => setState(() {
              if (!_picked.remove(id)) _picked.add(id);
            }),
            onToggleAll: (select) => setState(() {
              for (final e in _seen[code]!) {
                if (select) {
                  _picked.add(e.id);
                } else {
                  _picked.remove(e.id);
                }
              }
            }),
          ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

/// Một mã vận đơn đã quét, cùng mọi bằng chứng của nó.
///
/// Mỗi mã là một khối riêng, xếp chồng theo thứ tự quét — mã mới trên cùng.
/// Quét mã thứ hai KHÔNG đẩy mã thứ nhất đi đâu cả: một hồ sơ khiếu nại thường
/// gộp vài đơn, mà mất khối cũ là người dùng phải làm lại từ đầu.
class _OrderPickSection extends StatelessWidget {
  const _OrderPickSection({
    required this.code,
    required this.items,
    required this.picked,
    required this.onToggle,
    required this.onToggleAll,
  });

  final String code;
  final List<EcClaimPickable> items;
  final Set<String> picked;
  final ValueChanged<String> onToggle;
  final ValueChanged<bool> onToggleAll;

  @override
  Widget build(BuildContext context) {
    final allPicked =
        items.isNotEmpty && items.every((e) => picked.contains(e.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: PenText(
                code,
                size: 16,
                color: PenColors.ink,
                weight: FontWeight.w800,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (items.isNotEmpty)
              EcTap(
                onTap: () => onToggleAll(!allPicked),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Icon(
                    allPicked ? LucideIcons.squareCheckBig : LucideIcons.square,
                    size: 26,
                    color: allPicked ? PenColors.primary : PenColors.ink,
                  ),
                ),
              ),
          ],
        ),
        if (items.isEmpty)
          PenText(
            context.l10n.timelineEmpty,
            size: 13,
            color: PenColors.mut,
          )
        else
          for (final group in _byDay) ...[
            const SizedBox(height: 10),
            if (group.$1.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: PenText(
                  group.$1,
                  size: 16,
                  color: PenColors.ink,
                  weight: FontWeight.w700,
                ),
              ),
            for (var i = 0; i < group.$2.length; i++) ...[
              if (i > 0) const SizedBox(height: 9),
              _PickRow(
                item: group.$2[i],
                picked: picked.contains(group.$2[i].id),
                onTap: () => onToggle(group.$2[i].id),
              ),
            ],
          ],
      ],
    );
  }

  /// Gom bằng chứng theo ngày, GIỮ NGUYÊN thứ tự máy chủ trả về.
  ///
  /// Không sắp lại: dòng thời gian của một đơn đã xếp sẵn, và xếp lại ở đây sẽ
  /// cho hai màn cùng dữ liệu mà khác thứ tự.
  List<(String, List<EcClaimPickable>)> get _byDay {
    final groups = <(String, List<EcClaimPickable>)>[];
    for (final item in items) {
      final day = item.day ?? '';
      if (groups.isEmpty || groups.last.$1 != day) {
        groups.add((day, [item]));
      } else {
        groups.last.$2.add(item);
      }
    }
    return groups;
  }
}

/// Ô tra mã + nút quét, cùng khuôn với thanh tìm kiếm ở trang Vận đơn: một ô
/// duy nhất, vạch ngăn, rồi nút quét nằm BÊN TRONG ô.
/// Ô đặt tên hồ sơ.
///
/// Tên là thứ người bán đọc ba tuần sau, lúc sàn mới trả lời và trong danh sách
/// đã có chục hồ sơ. Nên ô này điền sẵn mã vận đơn chứ không để trống: một cái
/// tên phân biệt được, có ngay, mà vẫn sửa được.
class _ClaimNameField extends StatelessWidget {
  const _ClaimNameField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) => PenBox(
    height: 52,
    fill: PenColors.card,
    stroke: PenColors.line,
    radius: 14,
    axis: PenAxis.row,
    gap: 10,
    cross: CrossAxisAlignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    children: [
      const Icon(LucideIcons.tag, size: 20, color: PenColors.mut),
      Expanded(
        child: CupertinoTextField(
          controller: controller,
          padding: EdgeInsets.zero,
          decoration: const BoxDecoration(),
          placeholder: hint,
          textInputAction: TextInputAction.done,
          maxLength: 120,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          // Bộ đếm ký tự của Cupertino không có sẵn; giới hạn 120 khớp với
          // trần của máy chủ nên chữ bị cắt ở đây thay vì bị từ chối sau khi
          // người dùng đã bấm tạo.
          style: const TextStyle(fontSize: 15, color: PenColors.ink),
        ),
      ),
    ],
  );
}

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

/// Một bằng chứng trong màn tạo hồ sơ, dựng theo đúng khuôn dòng thời gian của
/// một mã vận đơn: giờ ở cột trái, chấm mốc, rồi thẻ có ảnh đại diện.
///
/// Cùng dữ liệu thì phải cùng hình dạng. Bản trước là một dòng chữ trơn có
/// icon, nên người bán vừa xem đơn xong mở màn này ra không nhận ra đây vẫn là
/// những clip ấy — và không có ảnh đại diện thì "Đóng hàng 14:02" với "Đóng
/// hàng 14:06" trông y hệt nhau.
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
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: 46,
        child: PenText(item.time, size: 14, color: PenColors.mut),
      ),
      const SizedBox(
        width: 22,
        height: 58,
        child: Center(
          child: PenEllipse(width: 11, height: 11, color: PenColors.ink),
        ),
      ),
      Expanded(
        // Cả thẻ là vùng bấm, không riêng ô tick: ở đây chạm vào một bằng
        // chứng chỉ có đúng một nghĩa — chọn hoặc bỏ chọn nó.
        child: PenCard(
          lifted: false,
          gap: 12,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 11),
          onTap: onTap,
          children: [
            _PickThumb(item: item),
            Expanded(
              child: PenText(
                item.label,
                size: 14,
                color: PenColors.ink,
                weight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              picked ? LucideIcons.squareCheckBig : LucideIcons.square,
              size: 20,
              color: picked ? PenColors.primary : PenColors.mut,
            ),
          ],
        ),
      ),
    ],
  );
}

/// Ô vuông đầu hàng: ảnh đại diện thật của clip, nếu không có thì icon.
///
/// Mọi đường rơi đều về cùng một ô icon, nên ảnh thiếu, đang tải hay hỏng đều
/// trông như thiết kế chứ không như lỗi.
class _PickThumb extends StatelessWidget {
  const _PickThumb({required this.item});

  static const _size = 42.0;
  static const _radius = 10.0;

  final EcClaimPickable item;

  @override
  Widget build(BuildContext context) {
    final url = item.thumbUrl;
    if (url == null) return _icon();
    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: Image.network(
        url,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        cacheWidth: (_size * MediaQuery.devicePixelRatioOf(context)).round(),
        errorBuilder: (context, error, stackTrace) => _icon(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _icon(),
      ),
    );
  }

  Widget _icon() => PenBox(
    width: _size,
    height: _size,
    fill: PenColors.bg,
    radius: _radius,
    axis: PenAxis.row,
    main: MainAxisAlignment.center,
    cross: CrossAxisAlignment.center,
    children: [
      Icon(
        item.isPhoto ? LucideIcons.image : LucideIcons.video,
        size: 21,
        color: PenColors.ink,
      ),
    ],
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
        // Nhãn co được, SỐ ĐẾM thì không. Trên màn hẹp cả cụm tràn khỏi nút;
        // để nguyên một chuỗi thì thứ bị cắt lại đúng là con số — thông tin
        // duy nhất thay đổi theo thao tác của người dùng.
        Flexible(
          child: PenText(
            context.l10n.bundleCreateClaim,
            size: 16,
            color: PenColors.card,
            weight: FontWeight.w700,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PenText(
          '($count)',
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
