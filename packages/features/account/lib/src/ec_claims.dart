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
import 'package:flutter/cupertino.dart'
    show CupertinoActivityIndicator, CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MaxLengthEnforcement;
import 'package:localization/localization.dart';

/// Một đơn tra được ở màn tạo hồ sơ: mã ĐẦY ĐỦ của đơn kèm bằng chứng của nó.
///
/// Mang theo mã đầy đủ vì người dùng được phép gõ một mẩu: máy chủ tìm gần
/// đúng, nên thứ hiện lên phải là mã thật của đơn tìm được, không phải mẩu đã
/// gõ.
class EcClaimLookup {
  const EcClaimLookup({required this.code, required this.items});

  /// Mã vận đơn đầy đủ.
  final String code;

  /// Bằng chứng của đơn. Rỗng = đơn có thật nhưng chưa quay gì.
  final List<EcClaimPickable> items;
}

/// Một hồ sơ trên màn danh sách.
class EcClaimEntry {
  const EcClaimEntry({
    required this.id,
    required this.dateLabel,
    this.title = '',
    required this.timeLabel,
    required this.orderCount,
    required this.evidenceCount,
    this.revoked = false,
    this.localOnly = false,
  });

  final String id;

  /// Tên do người tạo đặt — dòng ĐẦU của hàng. Rỗng với hồ sơ tạo trước khi tên
  /// là bắt buộc; lúc đó hàng lùi về ngày giờ chứ không để trống một dòng.
  final String title;

  /// `06/08/2026` — tách khỏi giờ để hai thứ vẽ hai cỡ chữ khác nhau.
  final String dateLabel;

  /// `17:42`.
  final String timeLabel;

  final int orderCount;
  final int evidenceCount;

  /// Link đã bị thu hồi — có thể do người khác thu hồi ở máy khác hoặc trên
  /// web. Hàng vẫn nằm trong danh sách: người bán cần thấy mình ĐÃ từng phát
  /// link nào, nhưng phải thấy ngay là cái này không còn mở được.
  final bool revoked;

  /// Chỉ có trên máy này, chưa lên máy chủ (tạo lúc mất mạng). Quyết định dòng
  /// cảnh báo ở đầu màn — hồ sơ đã đồng bộ thì dòng đó là lời cảnh báo sai.
  final bool localOnly;
}

/// Lớp cha: danh sách hồ sơ đã tạo, mới nhất trước.
class EcClaimListScreen extends StatelessWidget {
  const EcClaimListScreen({
    this.entries = const [],
    this.onOpen,
    this.onCopy,
    this.onRevoke,
    this.onCreate,
    this.onNavOrders,
    this.onNavRecord,
    super.key,
  });

  final List<EcClaimEntry> entries;
  final ValueChanged<EcClaimEntry>? onOpen;
  final ValueChanged<EcClaimEntry>? onCopy;

  /// Nhấn giữ một hàng: thu hồi link của hồ sơ đó. Chỗ DUY NHẤT thu hồi được —
  /// màn bên trong cố tình không có nút này (xem `_ClaimPageActions`).
  final ValueChanged<EcClaimEntry>? onRevoke;

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
          //
          // Chỉ hiện khi THẬT SỰ còn hồ sơ chưa lên máy chủ. Danh sách giờ đọc
          // từ máy chủ, nên để dòng này đứng vĩnh viễn là dọa người dùng về một
          // rủi ro không còn nữa — và cảnh báo lúc nào cũng sáng thì tới lúc nó
          // đúng cũng không ai đọc.
          if (entries.any((e) => e.localOnly))
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
        onLongPress: onRevoke == null ? null : () => onRevoke!(entries[index]),
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
  const _ClaimRow({
    required this.entry,
    this.onTap,
    this.onCopy,
    this.onLongPress,
  });

  final EcClaimEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onCopy;

  /// Nhấn giữ để thu hồi link. Không có nút lộ thiên nào cho việc này — thu hồi
  /// giết một link đã gửi cho sàn và không lùi lại được.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EcTap(
      onTap: onTap,
      onLongPress: onLongPress,
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
                // Tên người dùng đặt là thứ họ tìm bằng mắt ba tuần sau, lúc
                // sàn mới trả lời và danh sách đã có chục hồ sơ. Ngày giờ thì
                // mọi hồ sơ đều có, nên để nó làm dòng đầu là bắt người ta đọc
                // hết cả cột mới thấy vụ mình cần.
                Row(
                  children: [
                    Flexible(
                      child: PenText(
                        entry.title.trim().isEmpty
                            ? '${entry.dateLabel}  ${entry.timeLabel}'
                            : entry.title,
                        size: 15,
                        color: entry.revoked ? PenColors.mut : PenColors.ink,
                        weight: FontWeight.w700,
                        maxLines: 1,
                      ),
                    ),
                    // Thu hồi có thể xảy ra ở MÁY KHÁC hoặc trên web, nên hàng
                    // này là chỗ duy nhất người dùng ở máy đang cầm biết link
                    // đã chết mà không phải mở từng hồ sơ ra xem.
                    if (entry.revoked) ...[
                      const SizedBox(width: 8),
                      PenBox(
                        fill: PenColors.bg,
                        stroke: PenColors.line,
                        radius: 999,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        children: [
                          PenText(
                            l10n.claimRevokedBadge,
                            size: 11,
                            color: PenColors.mut,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                PenText(
                  // Hồ sơ chưa có tên đã hiện ngày giờ ở dòng trên rồi — lặp
                  // lại lần nữa ở đây là hai dòng nói cùng một điều.
                  entry.title.trim().isEmpty
                      ? l10n.claimsSummary(
                          entry.orderCount,
                          entry.evidenceCount,
                        )
                      // Số bằng chứng và thời gian, KHÔNG kèm số đơn: ba thứ
                      // ghép vào một dòng thì trên màn hẹp là bị cắt, mà cắt
                      // thì mất đúng cái mốc thời gian ở cuối. Số đơn vẫn đọc
                      // được đầy đủ trong chi tiết hồ sơ.
                      : '${l10n.claimsEvidenceOnly(entry.evidenceCount)}'
                            '  ·  ${entry.dateLabel}  ${entry.timeLabel}',
                  size: 13,
                  color: PenColors.mut,
                  maxLines: 1,
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
/// Hồ sơ khiếu nại: MỘT KHỐI THÔNG TIN và MỘT CÁI LINK.
///
/// Không phải thư viện video — muốn xem clip thì vào chi tiết đơn, nơi việc đó
/// thuộc về và nơi mọi nút sửa/xoá đã nằm sẵn. Ở đây hồ sơ là thứ ĐÃ CHỐT: đọc
/// để đối chiếu, sao chép link để gửi, thu hồi khi không muốn ai xem nữa.
///
/// Đúng ba việc đó. Thêm bất kỳ đường sửa nào vào đây là biến một hồ sơ đã phát
/// đi thành thứ không đối chứng được — đó là lý do màn này KHÔNG còn nhận
/// `onRemoveItem`, giống hệt bản web.
class EcClaimDetailScreen extends StatelessWidget {
  const EcClaimDetailScreen({
    required this.title,
    required this.shopName,
    required this.channel,
    required this.trackings,
    required this.orderDateLabel,
    required this.videos,
    required this.photos,
    required this.createdAtLabel,
    required this.url,
    this.revoked = false,
    this.onBack,
    this.onCopy,
    this.onRevoke,
    super.key,
  });

  /// Tên hồ sơ. Rỗng thì hiện "Hồ sơ không đặt tên" — hồ sơ cũ tạo trước khi
  /// tên là bắt buộc vẫn phải mở được.
  final String title;
  final String shopName;
  final String channel;

  /// MỌI mã vận đơn, xếp dọc theo thời gian tạo đơn. Hồ sơ gộp nhiều kiện là
  /// chuyện thường — hiện một mã rồi ẩn phần còn lại là giấu đúng thứ người đọc
  /// cần đối chiếu.
  final List<String> trackings;

  /// Một mốc khi hồ sơ có một đơn, một khoảng khi nhiều đơn.
  final String orderDateLabel;
  final int videos;
  final int photos;
  final String createdAtLabel;
  final String url;
  final bool revoked;
  final VoidCallback? onBack;
  final VoidCallback? onCopy;
  final VoidCallback? onRevoke;

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
                    title.trim().isEmpty ? l10n.claimUntitled : title,
                    size: 20,
                    color: PenColors.ink,
                    weight: FontWeight.w800,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              children: [
                PenCard(
                  axis: PenAxis.column,
                  gap: 12,
                  cross: CrossAxisAlignment.stretch,
                  padding: const EdgeInsets.all(14),
                  children: [
                    PenText(
                      l10n.claimInfoTitle,
                      size: 15,
                      color: PenColors.ink,
                      weight: FontWeight.w700,
                    ),
                    _ClaimKv(
                      label: l10n.claimTrackingLabel,
                      valueLines: trackings,
                      mono: true,
                    ),
                    _ClaimKv(
                      label: l10n.claimShopLabel,
                      valueLines: [shopName],
                    ),
                    _ClaimKv(
                      label: l10n.claimChannelLabel,
                      valueLines: [channel],
                    ),
                    _ClaimKv(
                      label: l10n.claimOrderCreatedAt,
                      valueLines: [orderDateLabel],
                    ),
                    _ClaimKv(
                      label: l10n.claimEvidenceLabel,
                      valueLines: [l10n.claimEvidenceCount(videos, photos)],
                    ),
                    _ClaimKv(
                      label: l10n.claimCreatedAtLabel,
                      valueLines: [createdAtLabel],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PenCard(
                  axis: PenAxis.column,
                  gap: 10,
                  cross: CrossAxisAlignment.stretch,
                  padding: const EdgeInsets.all(14),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: PenText(
                            l10n.claimLinkLabel,
                            size: 15,
                            color: PenColors.ink,
                            weight: FontWeight.w700,
                          ),
                        ),
                        if (revoked)
                          PenBox(
                            fill: PenColors.bg,
                            stroke: PenColors.line,
                            radius: 999,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            children: [
                              PenText(
                                l10n.claimRevokedBadge,
                                size: 12,
                                color: PenColors.mut,
                              ),
                            ],
                          ),
                      ],
                    ),
                    // Nói link làm được gì TRƯỚC khi đưa link ra — người sắp gửi
                    // nó cho nhân viên sàn cần biết mình đang phát ra cái gì.
                    PenText(
                      revoked ? l10n.claimRevokedHint : l10n.claimLinkHint,
                      size: 13,
                      color: PenColors.mut,
                    ),
                    if (!revoked) ...[
                      // Link nằm trong một ô chỉ-đọc kèm nút chép NGAY TRONG ô,
                      // giống web: bôi đen tay rồi hụt một ký tự là gửi đi một
                      // link chết.
                      PenBox(
                        fill: PenColors.bg,
                        stroke: PenColors.line,
                        radius: 12,
                        axis: PenAxis.row,
                        gap: 8,
                        cross: CrossAxisAlignment.center,
                        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                        children: [
                          Expanded(
                            child: PenText(
                              url,
                              size: 12,
                              color: PenColors.ink,
                              maxLines: 2,
                            ),
                          ),
                          EcTap(
                            onTap: onCopy,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                LucideIcons.copy,
                                size: 20,
                                color: PenColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Thu hồi là nút VIỀN, không phải nút đỏ đặc đứng cạnh nút
                      // chép. Hai nút nổi bật ngang nhau ở cạnh nhau là mời bấm
                      // nhầm — mà nhầm ở đây nghĩa là giết một link đã gửi cho
                      // sàn.
                      if (onRevoke != null)
                        EcTap(
                          onTap: onRevoke,
                          child: PenBox(
                            fill: PenColors.card,
                            stroke: PenColors.danger,
                            radius: 12,
                            axis: PenAxis.row,
                            gap: 8,
                            main: MainAxisAlignment.center,
                            cross: CrossAxisAlignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            children: [
                              const Icon(
                                LucideIcons.trash2,
                                size: 18,
                                color: PenColors.danger,
                              ),
                              PenText(
                                l10n.claimRevoke,
                                size: 14,
                                color: PenColors.danger,
                                weight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Một dòng nhãn — giá trị của khối thông tin. Nhiều dòng giá trị cho ô "Mã vận
/// đơn" của hồ sơ gộp.
class _ClaimKv extends StatelessWidget {
  const _ClaimKv({
    required this.label,
    required this.valueLines,
    this.mono = false,
  });

  final String label;
  final List<String> valueLines;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final lines = valueLines.where((v) => v.trim().isNotEmpty).toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 116,
          child: PenText(label, size: 13, color: PenColors.mut),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (lines.isEmpty)
                PenText('—', size: 13, color: PenColors.mut)
              else
                for (final v in lines)
                  PenText(
                    v,
                    size: 13,
                    color: PenColors.ink,
                    align: TextAlign.right,
                  ),
            ],
          ),
        ),
      ],
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

  /// Tra một mã vận đơn — hoặc một MẨU của nó.
  ///
  /// Trả danh sách rỗng khi không đơn nào khớp. Mỗi phần tử là một đơn có
  /// thật, mang mã ĐẦY ĐỦ của nó ([EcClaimLookup.code]) chứ không phải chuỗi
  /// người dùng vừa gõ: gõ "0035" mà tiêu đề nhóm cũng ghi "0035" thì người
  /// bán không biết mình đang tick bằng chứng của kiện nào.
  final Future<List<EcClaimLookup>> Function(String query) onSearch;

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
      _notFound = found.isEmpty;
      // Không tick sẵn gì cả. Đơn có chục clip mà người bán chỉ cần một cái để
      // khiếu nại thì tick sẵn hết bắt họ bỏ chín — nhiều thao tác hơn hẳn tự
      // tick một.
      // Duyệt NGƯỢC rồi chèn lên đầu: đơn máy chủ xếp đầu (hoạt động gần đây
      // nhất) phải nằm trên cùng sau khi mọi thứ đã vào chỗ.
      for (final hit in found.reversed) {
        // Mã mới lên ĐẦU: người bán vừa quét cái gì thì muốn thấy ngay cái đó,
        // không phải cuộn qua mọi mã đã quét trước để tìm.
        _seen
          ..remove(hit.code)
          ..[hit.code] = hit.items;
        _order
          ..remove(hit.code)
          ..insert(0, hit.code);
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
          // Ô tên đứng ĐẦU TIÊN, trên cả ô tra mã, và LUÔN hiện — giống hệt
          // bản web. Bản trước giấu nó xuống đáy và chỉ hiện sau khi đã tick
          // được thứ gì: mở màn ra không thấy ô tên nào, nên người dùng không
          // biết hồ sơ cần đặt tên cho tới lúc đã làm xong mọi việc khác.
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: _ClaimNameField(
              controller: _title,
              label: l10n.claimsCreateNameLabel,
              hint: l10n.claimsCreateNameHint,
              // Gõ tới đâu bật/tắt nút tạo tới đó — thiếu `onChanged` thì xoá
              // trắng ô mà nút vẫn sáng, và máy chủ mới là chỗ nói không.
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
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
                // Tên hồ sơ BẮT BUỘC: nút tắt khi ô tên trống. Chặn bằng
                // cách TẮT nút chứ không báo lỗi sau khi bấm — lỗi sau khi bấm
                // là bắt người ta làm hai lần.
                child: _CreateClaimButton(
                  count: _pickedCount,
                  onTap: widget.onCreate == null || _title.text.trim().isEmpty
                      ? null
                      : () => widget.onCreate!(_batch, _title.text.trim()),
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
  const _ClaimNameField({
    required this.controller,
    required this.label,
    required this.hint,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Dấu sao đỏ ngay cạnh nhãn: người dùng biết ô này bắt buộc TRƯỚC khi
      // làm mọi việc khác, chứ không phát hiện ra lúc bấm nút tạo thì nút mờ.
      Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 6),
        child: Row(
          children: [
            PenText(label, size: 13, color: PenColors.mut),
            const SizedBox(width: 4),
            const PenText('*', size: 13, color: PenColors.danger),
          ],
        ),
      ),
      _field(),
    ],
  );

  Widget _field() => PenBox(
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
          onChanged: onChanged,
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
      // Kính lúp là NÚT, không phải hình trang trí.
      //
      // Bản trước chỉ có phím "tìm" trên bàn phím kích hoạt được lượt tra. Ai
      // gõ xong rồi bấm vào kính lúp — thao tác tự nhiên nhất, và là thứ mọi ô
      // tìm kiếm khác trên đời đều làm — thì màn hình đứng im, không báo gì.
      EcTap(
        onTap: () => onSubmit(controller.text),
        child: const SizedBox(
          width: 34,
          height: 44,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Icon(LucideIcons.search, size: 22, color: PenColors.mut),
          ),
        ),
      ),
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
