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
    this.busy = false,
    super.key,
  });

  final EcStorageState state;
  final VoidCallback? onBack;
  final VoidCallback? onConnectS3;
  final VoidCallback? onConnectDrive;
  final VoidCallback? onTest;
  final VoidCallback? onDisconnect;

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

  /// Chạm vào một thẻ: nhích dấu tích sang đó, rồi chạy luồng của kho đó nếu
  /// thật sự chạy được.
  ///
  /// Dấu tích nhảy TRƯỚC, không đợi máy chủ: luồng cắm kho riêng còn phải qua
  /// màn nhập khoá hoặc màn cấp quyền của Google, mà một cú chạm không thấy
  /// phản hồi thì người dùng bấm lại lần nữa.
  ///
  /// Cả ba thẻ đều bấm được, kể cả khi gói chưa mở hoặc người bấm không phải
  /// chủ shop — lúc đó chỉ có dấu tích di chuyển, không có gì chạy. Dòng nhắc
  /// về gói nằm ngay trong thẻ để không ai tưởng đã cắm xong.
  void _pick(EcStorageKind kind, VoidCallback? action) {
    setState(() => _picked = kind);
    action?.call();
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
              PenHeader(title: l10n.storageTitle, onBack: widget.onBack),
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
                onTap: () =>
                    _pick(EcStorageKind.system, _flowFor(EcStorageKind.system)),
              ),
              const SizedBox(height: 10),
              _StorageOption(
                icon: LucideIcons.hardDrive,
                title: l10n.storageS3Title,
                description: l10n.storageS3Desc,
                selected: _picked == EcStorageKind.s3,
                lockNote: state.byosAllowed ? null : l10n.storageNeedProPlan,
                onTap: () =>
                    _pick(EcStorageKind.s3, _flowFor(EcStorageKind.s3)),
              ),
              const SizedBox(height: 10),
              _StorageOption(
                icon: LucideIcons.hardDrive,
                title: l10n.storageDriveTitle,
                description: l10n.storageDriveDesc,
                selected: _picked == EcStorageKind.gdrive,
                lockNote: state.byosAllowed ? null : l10n.storageNeedProPlan,
                onTap: () =>
                    _pick(EcStorageKind.gdrive, _flowFor(EcStorageKind.gdrive)),
              ),
              // Câu lỗi nguyên văn của nhà cung cấp là thứ DUY NHẤT giúp chủ
              // shop tự sửa quyền bên phía họ, nên nó ở lại kể cả khi màn này
              // đã gọn còn ba thẻ.
              if (_own && !state.ok && (state.lastError?.isNotEmpty ?? false))
                ...[
                  const SizedBox(height: 12),
                  _NoteBox(text: state.lastError!, danger: true),
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
    this.lockNote,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final String? lockNote;
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
                  ],
                ),
                const SizedBox(height: 4),
                PenText(
                  description,
                  size: 13,
                  color: PenColors.mut,
                  lineHeight: 1.4,
                ),
                if (locked) ...[
                  const SizedBox(height: 4),
                  PenText(
                    lockNote!,
                    size: 13,
                    color: PenColors.mut,
                    lineHeight: 1.4,
                  ),
                ],
              ],
            ),
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
