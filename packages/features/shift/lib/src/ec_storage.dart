/// Kho lưu trữ video của shop — màn xem tình trạng và màn cắm kho riêng.
///
/// Vì sao app cần màn này khi web admin đã có: kho hỏng là chuyện xảy ra GIỮA
/// CA ĐÓNG HÀNG, và người đầu tiên chịu hậu quả là người đang cầm điện thoại
/// quay. Bắt họ mở laptop để biết clip của mình đang nằm ở vùng chờ tạm là bắt
/// họ phát hiện ra sự cố muộn nhất có thể.
///
/// Phần XEM mở cho mọi vai trò; phần ĐỔI chỉ chủ shop — máy chủ chặn bằng
/// `owner_only`, ở đây chỉ là không chào cái nút chắc chắn 403.
library;

import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';

/// Kho shop đang dùng. Không cấu hình gì = [system].
enum EcStorageKind { system, s3, gdrive }

/// Bảng tình trạng kho — bốn con số và một mốc thời gian.
class EcStorageHealth {
  const EcStorageHealth({
    this.total = 0,
    this.intact = 0,
    this.unreachable = 0,
    this.mismatched = 0,
    this.pendingRelay = 0,
    this.lastCheckedAt,
  });

  final int total;
  final int intact;

  /// Không mở được ở kho của shop. Với người bán thì bằng chứng coi như đã mất
  /// cho tới khi họ sửa quyền bên phía nhà cung cấp.
  final int unreachable;

  /// Sai lệch so với hồ sơ niêm phong — tệp đã bị sửa sau khi hệ thống nhận.
  final int mismatched;

  /// Còn ở vùng chờ tạm vì kho đang có sự cố. Chưa mất, nhưng chưa về nhà.
  final int pendingRelay;

  /// Lượt rà gần nhất. `null` = chưa rà lần nào — nói thẳng ra, vì một bảng
  /// toàn số 0 không có mốc thời gian đọc y hệt một kho hoàn hảo.
  final int? lastCheckedAt;

  bool get hasProblems => unreachable > 0 || mismatched > 0 || pendingRelay > 0;
}

/// Trạng thái kho đủ để dựng màn hình.
class EcStorageState {
  const EcStorageState({
    this.kind = EcStorageKind.system,
    this.label = '',
    this.ok = true,
    this.lastError,
    this.health = const EcStorageHealth(),
    this.byosAllowed = false,
    this.canManage = false,
    this.presignedDownload = true,
    this.objectLock = false,
    this.driveEmail,
  });

  final EcStorageKind kind;

  /// Dòng nhận diện kho: `bucket/prefix`, hoặc tên thư mục Drive.
  final String label;
  final bool ok;
  final String? lastError;
  final EcStorageHealth health;

  /// Gói có mở kho riêng không. Đọc từ máy chủ, KHÔNG suy từ mã gói ở client.
  final bool byosAllowed;

  /// Actor có phải chủ shop không.
  final bool canManage;

  /// False (Google Drive) = video đi vòng qua máy chủ, phát chậm hơn hẳn.
  final bool presignedDownload;

  /// Cơ sở duy nhất để hứa "bằng chứng không thể xoá".
  final bool objectLock;

  /// Tài khoản Google đang giữ kho. Chỉ để người dùng nhận ra mình đã cắm
  /// nhầm tài khoản nào — đổi tài khoản là cắm lại từ đầu.
  final String? driveEmail;
}

/// Màn "Kho lưu trữ": chọn một trong ba nơi cất video của shop.
class EcStorageScreen extends StatefulWidget {
  const EcStorageScreen({
    required this.state,
    this.onBack,
    this.onConnectS3,
    this.onConnectDrive,
    this.onTest,
    this.onDisconnect,
    this.onPick,
    this.busy = false,
    super.key,
  });

  final EcStorageState state;
  final VoidCallback? onBack;
  final VoidCallback? onConnectS3;
  final VoidCallback? onConnectDrive;
  final VoidCallback? onTest;
  final VoidCallback? onDisconnect;

  /// Người dùng vừa bấm chọn một kho — bắn ở MỌI lượt bấm, kể cả khi luồng
  /// cắm kho phía sau không chạy được.
  ///
  /// Bên gọi dùng nó để nhớ lựa chọn ngay trên máy. Tách khỏi
  /// `onConnectS3`/`onConnectDrive` vì hai thứ khác nhau: kia là "hãy cắm kho
  /// này", còn đây chỉ là "người dùng đã chỉ vào kho này".
  final void Function(EcStorageKind kind)? onPick;

  /// Đang chạy một thao tác mạng — khoá nút để không bấm hai lần.
  final bool busy;

  @override
  State<EcStorageScreen> createState() => _EcStorageScreenState();
}

class _EcStorageScreenState extends State<EcStorageScreen> {
  /// Kho người dùng vừa bấm. Dấu tích nhảy sang ngay lúc chạm, không đợi máy
  /// chủ trả lời — luồng cắm kho riêng còn phải qua màn nhập khoá hoặc màn cấp
  /// quyền, mà một cú chạm không thấy phản hồi thì người dùng bấm lại lần nữa.
  late EcStorageKind _picked = widget.state.kind;

  @override
  void didUpdateWidget(covariant EcStorageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Máy chủ chốt xong thì bám theo nó. Và khi một lượt thao tác kết thúc mà
    // kho vẫn như cũ (người dùng bấm huỷ giữa chừng), trả dấu tích về đúng chỗ
    // — để nó nằm lại chỗ vừa bấm là nói dối về nơi video đang được cất.
    if (oldWidget.state.kind != widget.state.kind ||
        (oldWidget.busy && !widget.busy)) {
      _picked = widget.state.kind;
    }
  }

  bool get _own => widget.state.kind != EcStorageKind.system;

  /// Chạm vào một thẻ: CHỈ nhích dấu tích sang đó. Không chạy gì cả.
  ///
  /// Trước đây chạm là chạy thẳng luồng cắm kho — người bán quệt tay vào thẻ
  /// Drive là màn cấp quyền Google bật lên, và đổi nơi cất bằng chứng của cả
  /// cửa hàng không phải việc nên xảy ra sau một cú chạm nhầm. Giờ chọn là
  /// chọn, áp dụng nằm ở nút lưu trên đầu màn.
  ///
  /// Cả ba thẻ đều chạm được, kể cả khi gói chưa mở hoặc người chạm không phải
  /// chủ shop — chỉ dấu tích di chuyển. Nút lưu mới là chỗ chặn.
  void _pick(EcStorageKind kind) {
    setState(() => _picked = kind);
  }

  /// Lựa chọn đang hiện khác với kho đang thật sự dùng.
  bool get _dirty => _picked != widget.state.kind;

  /// Bấm lưu: nhớ lựa chọn rồi chạy đúng luồng của kho vừa chọn.
  ///
  /// `onPick` bắn ở ĐÂY chứ không ở lúc chạm: nó ghi lựa chọn xuống máy, mà ghi
  /// một lựa chọn người dùng chưa xác nhận thì thoát ra vào lại sẽ thấy dấu tích
  /// nằm ở một kho chưa hề được cắm.
  void _save() {
    if (!_dirty) return;
    final flow = _flowFor(_picked);
    widget.onPick?.call(_picked);
    flow?.call();
  }

  /// Luồng ứng với một kho, hoặc `null` khi chạm vào không chạy được gì.
  VoidCallback? _flowFor(EcStorageKind kind) {
    final state = widget.state;
    if (!state.canManage || widget.busy) return null;
    return switch (kind) {
      // Đang ở kho hệ thống rồi thì chạm vào đây không có việc gì để làm.
      EcStorageKind.system => _own ? widget.onDisconnect : null,
      EcStorageKind.s3 => state.byosAllowed ? widget.onConnectS3 : null,
      EcStorageKind.gdrive => state.byosAllowed ? widget.onConnectDrive : null,
    };
  }

  /// Phần chi tiết vẽ BÊN TRONG thẻ của một kho, ngăn bằng một đường kẻ.
  ///
  /// Cùng cách bản web sắp xếp: bảng tình trạng nằm trong ô của chính cái kho
  /// nó nói về, không phải một khối lơ lửng dưới cả danh sách — treo ở ngoài
  /// thì "Cloud Zenpack" trông gọn ghẽ còn Drive/S3 kéo theo một mảng số liệu
  /// không rõ của ai.
  ///
  /// Kho ĐANG dùng → bảng tình trạng. Kho chưa dùng → lối cắm.
  Widget? _detailFor(EcStorageKind kind) {
    final state = widget.state;
    if (state.kind == kind) {
      return _StatusDetail(
        state: state,
        busy: widget.busy,
        onTest: widget.onTest,
        onDisconnect: widget.onDisconnect,
        onEdit: kind == EcStorageKind.s3 ? widget.onConnectS3 : null,
      );
    }
    // Kho CHƯA dùng không còn nút cắm riêng: có hai chỗ cùng áp dụng một thay
    // đổi thì nút lưu trên đầu màn thành đồ trang trí, và người dùng học được
    // rằng chạm vào thẻ là xong — đúng thói quen vừa bỏ đi.
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = widget.state;
    return PenScreen(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PenHeader(
                title: l10n.storageTitle,
                onBack: widget.onBack,
                // Nút lưu chỉ SÁNG khi có thay đổi chưa áp dụng. Một nút luôn
                // sáng ở màn không có gì để lưu thì bấm vào không có chuyện gì
                // xảy ra, và lần sau người dùng không tin nó nữa.
                trailing: _SaveButton(
                  enabled: _dirty && !widget.busy && state.canManage,
                  busy: widget.busy,
                  onTap: _save,
                ),
              ),
              const SizedBox(height: 10),
              // Câu này đứng ngay dưới tiêu đề vì nó trả lời nỗi lo đầu tiên
              // của người sắp đổi kho: đổi rồi bằng chứng có yếu đi không.
              PenText(l10n.storageIntro, size: 14, color: PenColors.mut),
              const SizedBox(height: 16),
              _StorageOption(
                icon: LucideIcons.cloud,
                title: l10n.storageSystemName,
                description: l10n.storageSystemDesc,
                selected: _picked == EcStorageKind.system,
                inUse: state.kind == EcStorageKind.system,
                onTap: () => _pick(EcStorageKind.system),
              ),
              const SizedBox(height: 10),
              _StorageOption(
                icon: LucideIcons.hardDrive,
                title: l10n.storageS3Title,
                description: l10n.storageS3Desc,
                selected: _picked == EcStorageKind.s3,
                inUse: state.kind == EcStorageKind.s3,
                label: state.kind == EcStorageKind.s3 ? state.label : null,
                lockNote: state.byosAllowed ? null : l10n.storageNeedProPlan,
                detail: _detailFor(EcStorageKind.s3),
                onTap: () => _pick(EcStorageKind.s3),
              ),
              const SizedBox(height: 10),
              _StorageOption(
                icon: LucideIcons.hardDrive,
                title: l10n.storageDriveTitle,
                description: l10n.storageDriveDesc,
                selected: _picked == EcStorageKind.gdrive,
                inUse: state.kind == EcStorageKind.gdrive,
                label: state.kind == EcStorageKind.gdrive ? state.label : null,
                lockNote: state.byosAllowed ? null : l10n.storageNeedProPlan,
                detail: _detailFor(EcStorageKind.gdrive),
                onTap: () => _pick(EcStorageKind.gdrive),
              ),
              // Gói chưa mở kho riêng: nói MỘT lần dưới danh sách, không lặp ở
              // từng thẻ. Ba dòng cùng nội dung cạnh nhau đọc thành nhiễu, và
              // mỗi thẻ đã có dòng khoá ngắn của riêng nó.
              if (state.canManage && !state.byosAllowed) ...[
                const SizedBox(height: 12),
                _NoteBox(text: l10n.storageNotInPlan),
              ],
              // Nhân viên xem được mọi thứ ở trên nhưng không đổi được gì. Nói
              // ra, đừng để họ đi tìm cái nút không tồn tại.
              if (!state.canManage) ...[
                const SizedBox(height: 12),
                _NoteBox(text: l10n.storageOwnerOnly),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Một dòng chọn kho: biểu tượng, tên, mô tả, và dấu tích khi đang dùng.
///
/// Kho đang dùng viền xanh + dấu tích; kho gói chưa mở thì chữ mờ đi và có
/// thêm một dòng nói RÕ vì sao không bấm được — ẩn đi thì người dùng đọc tài
/// liệu thấy có tính năng rồi đi tìm mãi không ra.
class _StorageOption extends StatelessWidget {
  const _StorageOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    this.inUse = false,
    this.label,
    this.lockNote,
    this.detail,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;

  /// Kho người dùng vừa CHỌN. Khác [inUse] — và phải nhìn ra được cả hai, vì
  /// gộp lại thì chọn xong người ta tưởng đã đổi kho rồi.
  final bool selected;

  /// Kho máy chủ đang THẬT SỰ dùng.
  final bool inUse;

  /// Dòng nhận diện kho (`bucket/prefix` hoặc thư mục Drive), chỉ ở thẻ [inUse].
  final String? label;
  final String? lockNote;

  /// Bảng tình trạng hoặc lối cắm, vẽ trong cùng khung viền với thẻ.
  final Widget? detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locked = lockNote != null;
    final ink = locked && !selected ? PenColors.mut : PenColors.ink;
    return EcTap(
      onTap: onTap,
      child: PenBox(
        width: double.infinity,
        fill: PenColors.card,
        stroke: selected ? PenColors.success : PenColors.line,
        strokeWidth: selected ? 2 : 1,
        radius: 14,
        axis: PenAxis.row,
        gap: 12,
        cross: CrossAxisAlignment.start,
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 20, color: ink),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: PenText(
                        title,
                        size: 16,
                        color: ink,
                        weight: FontWeight.w700,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        LucideIcons.check,
                        size: 18,
                        color: PenColors.success,
                      ),
                    ],
                    // Nhãn này KHÁC dấu tích: dấu tích là "đang ngắm", nhãn là
                    // "máy chủ đang thật sự cất video ở đây". Thiếu nó thì chọn
                    // xong người dùng tưởng đã đổi kho rồi.
                    if (inUse) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: PenColors.soft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: PenText(
                          context.l10n.storageInUse,
                          size: 11,
                          color: PenColors.mut,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                PenText(
                  description,
                  size: 13,
                  color: PenColors.mut,
                  lineHeight: 1.4,
                ),
                if (label?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  PenText(
                    label!,
                    size: 13,
                    color: PenColors.ink,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (locked) ...[
                  const SizedBox(height: 4),
                  PenText(
                    lockNote!,
                    size: 13,
                    color: PenColors.mut,
                    lineHeight: 1.4,
                  ),
                ],
                if (detail != null) ...[
                  const SizedBox(height: 12),
                  Container(height: 1, color: PenColors.line),
                  detail!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bảng tình trạng của kho ĐANG dùng: lỗi, cam kết không giữ được, năm con số,
/// mốc rà gần nhất, rồi tới các nút thao tác.
class _StatusDetail extends StatelessWidget {
  const _StatusDetail({
    required this.state,
    required this.busy,
    this.onTest,
    this.onDisconnect,
    this.onEdit,
  });

  final EcStorageState state;
  final bool busy;
  final VoidCallback? onTest;
  final VoidCallback? onDisconnect;

  /// Sửa cấu hình — chỉ S3. Drive không có gì để sửa ngoài cắm lại.
  final VoidCallback? onEdit;

  /// `dd/MM/yyyy HH:mm` theo giờ máy. Tự dựng thay vì kéo `intl` vào package
  /// này: đúng một chuỗi cần định dạng, và nó không đổi theo ngôn ngữ.
  static String _at(int ms) {
    final t = DateTime.fromMillisecondsSinceEpoch(ms);
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(t.day)}/${p(t.month)}/${t.year} ${p(t.hour)}:${p(t.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final health = state.health;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Câu lỗi nguyên văn của nhà cung cấp là thứ DUY NHẤT giúp chủ shop
          // tự sửa quyền bên phía họ. Không bao giờ thay bằng câu chung.
          if (!state.ok && (state.lastError?.isNotEmpty ?? false)) ...[
            _NoteBox(text: state.lastError!, danger: true),
            const SizedBox(height: 10),
          ],
          // Cam kết nào hứa được là do máy chủ ĐO, không do tên nhà cung cấp.
          if (!state.presignedDownload)
            PenText(
              l10n.storageNoPresign,
              size: 12,
              color: PenColors.mut,
              lineHeight: 1.4,
            ),
          if (!state.objectLock) ...[
            const SizedBox(height: 6),
            PenText(
              l10n.storageNoObjectLock,
              size: 12,
              color: PenColors.mut,
              lineHeight: 1.4,
            ),
          ],
          const SizedBox(height: 10),
          PenText(
            l10n.storageHealthTitle,
            size: 13,
            color: PenColors.mut,
            weight: FontWeight.w600,
          ),
          const SizedBox(height: 6),
          _HealthRow(label: l10n.storageHealthTotal, value: health.total),
          _HealthRow(label: l10n.storageHealthIntact, value: health.intact),
          // Ba dòng sự cố chỉ hiện khi KHÁC 0 — khác bản web, cố ý. Bảng lúc
          // nào cũng có "0 lỗi" thì mắt lướt qua rất nhanh, và đúng hôm có lỗi
          // thật cũng không ai thấy. Màn hình điện thoại lại càng ít chỗ.
          if (health.unreachable > 0)
            _HealthRow(
              label: l10n.storageHealthUnreachable,
              value: health.unreachable,
              danger: true,
            ),
          if (health.mismatched > 0)
            _HealthRow(
              label: l10n.storageHealthMismatched,
              value: health.mismatched,
              danger: true,
            ),
          if (health.pendingRelay > 0)
            _HealthRow(
              label: l10n.storageHealthPendingRelay,
              value: health.pendingRelay,
            ),
          if (health.hasProblems) ...[
            const SizedBox(height: 8),
            _NoteBox(text: l10n.storageProblemsNote, danger: true),
          ],
          const SizedBox(height: 8),
          PenText(
            health.lastCheckedAt == null
                ? l10n.storageNeverChecked
                : l10n.storageLastCheckAt(_at(health.lastCheckedAt!)),
            size: 12,
            color: PenColors.mut,
          ),
          if (state.driveEmail?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            PenText(l10n.storageDriveAccount, size: 12, color: PenColors.mut),
            const SizedBox(height: 2),
            PenText(
              state.driveEmail!,
              size: 13,
              color: PenColors.ink,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (state.canManage) ...[
            const SizedBox(height: 12),
            PenOutlineButton(
              label: l10n.storageTest,
              onPressed: busy ? null : onTest,
            ),
            if (onEdit != null) ...[
              const SizedBox(height: 8),
              PenOutlineButton(
                label: l10n.storageConnectS3,
                onPressed: busy ? null : onEdit,
              ),
            ],
            const SizedBox(height: 8),
            PenOutlineButton(
              label: l10n.storageDisconnect,
              onPressed: busy ? null : onDisconnect,
            ),
          ],
        ],
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({
    required this.label,
    required this.value,
    this.danger = false,
  });

  final String label;
  final int value;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: PenText(
              label,
              size: 13,
              color: danger ? PenColors.warning : PenColors.mut,
            ),
          ),
          const SizedBox(width: 8),
          PenText(
            '$value',
            size: 13,
            weight: FontWeight.w700,
            color: danger ? PenColors.warning : PenColors.ink,
          ),
        ],
      ),
    );
  }
}

class _NoteBox extends StatelessWidget {
  const _NoteBox({required this.text, this.danger = false});

  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      width: double.infinity,
      axis: PenAxis.column,
      radius: 10,
      fill: danger ? BrandColors.warningTint : PenColors.soft,
      padding: const EdgeInsets.all(12),
      cross: CrossAxisAlignment.start,
      children: [
        PenText(
          text,
          size: 13,
          color: danger ? PenColors.ink : PenColors.mut,
        ),
      ],
    );
  }
}

/// Form cắm kho S3. Google Drive không đi đường này — nó qua OAuth.
///
/// Năm ô, và không ô nào bỏ được: thiếu một là vòng kiểm tra của máy chủ đỏ ở
/// bước đầu tiên. Khoá bí mật nhập một lần rồi không bao giờ đọc lại được —
/// máy chủ mã hoá và không trả về, nên màn này luôn nhập mới chứ không sửa.
class EcStorageConnectScreen extends StatefulWidget {
  const EcStorageConnectScreen({
    required this.onSubmit,
    this.onBack,
    this.busy = false,
    this.errorText,
    super.key,
  });

  /// Trả về khi máy chủ đã chạy xong vòng kiểm tra. Bên gọi hiện lỗi qua
  /// [errorText] và tự đóng màn khi thành công.
  final void Function({
    required String endpoint,
    required String bucket,
    required String accessKeyId,
    required String secretAccessKey,
    required String region,
    required String prefix,
  })
  onSubmit;
  final VoidCallback? onBack;
  final bool busy;

  /// Câu `hint` nguyên văn từ máy chủ: thiếu quyền gì, sửa thế nào.
  final String? errorText;

  @override
  State<EcStorageConnectScreen> createState() => _EcStorageConnectScreenState();
}

class _EcStorageConnectScreenState extends State<EcStorageConnectScreen> {
  final _endpoint = TextEditingController();
  final _bucket = TextEditingController();
  final _keyId = TextEditingController();
  final _secret = TextEditingController();
  final _region = TextEditingController(text: 'auto');
  final _prefix = TextEditingController(text: 'evidencecam');

  @override
  void dispose() {
    for (final c in [_endpoint, _bucket, _keyId, _secret, _region, _prefix]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _ready =>
      _endpoint.text.trim().isNotEmpty &&
      _bucket.text.trim().isNotEmpty &&
      _keyId.text.trim().isNotEmpty &&
      _secret.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenScreen(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PenHeader(title: l10n.storageConnectS3, onBack: widget.onBack),
              const SizedBox(height: 12),
              _NoteBox(text: l10n.storageConnectHint),
              const SizedBox(height: 12),
              _Field(
                label: l10n.storageFieldEndpoint,
                controller: _endpoint,
                placeholder: 'https://s3.ap-southeast-1.amazonaws.com',
                keyboardType: TextInputType.url,
                onChanged: () => setState(() {}),
              ),
              _Field(
                label: l10n.storageFieldBucket,
                controller: _bucket,
                onChanged: () => setState(() {}),
              ),
              _Field(
                label: l10n.storageFieldAccessKey,
                controller: _keyId,
                onChanged: () => setState(() {}),
              ),
              _Field(
                label: l10n.storageFieldSecretKey,
                controller: _secret,
                obscure: true,
                onChanged: () => setState(() {}),
              ),
              _Field(label: l10n.storageFieldRegion, controller: _region),
              _Field(
                label: l10n.storageFieldPrefix,
                controller: _prefix,
                hint: l10n.storageFieldPrefixHint,
              ),
              if (widget.errorText?.isNotEmpty ?? false) ...[
                const SizedBox(height: 4),
                _NoteBox(text: widget.errorText!, danger: true),
              ],
              const SizedBox(height: 16),
              PenPrimaryButton(
                label: l10n.storageConnectSubmit,
                onPressed: widget.busy || !_ready
                    ? null
                    : () => widget.onSubmit(
                        endpoint: _endpoint.text.trim(),
                        bucket: _bucket.text.trim(),
                        accessKeyId: _keyId.text.trim(),
                        secretAccessKey: _secret.text.trim(),
                        region: _region.text.trim().isEmpty
                            ? 'auto'
                            : _region.text.trim(),
                        prefix: _prefix.text.trim(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.placeholder,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PenText(
            label,
            size: 13,
            color: PenColors.mut,
            weight: FontWeight.w600,
          ),
          const SizedBox(height: 6),
          CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            obscureText: obscure,
            keyboardType: keyboardType,
            // Endpoint và khoá phân biệt hoa thường; bàn phím tự viết hoa chữ
            // đầu là hỏng ngay ô đầu tiên và lỗi trả về không nói được vì sao.
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.none,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: PenColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: PenColors.soft),
            ),
            onChanged: (_) => onChanged?.call(),
          ),
          if (hint != null) ...[
            const SizedBox(height: 4),
            PenText(hint!, size: 12, color: PenColors.mut),
          ],
        ],
      ),
    );
  }
}

/// Nút lưu ở góc phải đầu màn Kho lưu trữ.
///
/// Dạng đĩa tròn như nút cộng ở màn Hồ sơ khiếu nại, để hai màn cùng một ngôn
/// ngữ. Mờ đi khi không có gì để lưu — vẫn chiếm chỗ chứ không biến mất, vì một
/// nút nhảy ra nhảy vào làm tiêu đề co giãn mỗi lần người dùng chạm một thẻ.
class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.enabled,
    required this.busy,
    required this.onTap,
  });

  final bool enabled;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final on = enabled && !busy;
    return Semantics(
      button: true,
      enabled: on,
      label: context.l10n.storageSave,
      child: EcTap(
        onTap: on ? onTap : null,
        child: PenBox(
          width: 40,
          height: 40,
          fill: on ? PenColors.primary : PenColors.bg,
          stroke: on ? null : PenColors.line,
          radius: 999,
          axis: PenAxis.row,
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          children: [
            if (busy)
              const SizedBox(
                width: 18,
                height: 18,
                child: CupertinoActivityIndicator(),
              )
            else
              Icon(
                LucideIcons.save,
                size: 20,
                color: on ? PenColors.card : PenColors.soft,
              ),
          ],
        ),
      ),
    );
  }
}
