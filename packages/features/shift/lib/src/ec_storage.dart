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

/// Màn "Kho lưu trữ": kho đang dùng, tình trạng, và các thao tác đổi kho.
class EcStorageScreen extends StatelessWidget {
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

  bool get _own => state.kind != EcStorageKind.system;

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
              PenHeader(title: l10n.storageTitle, onBack: onBack),
              const SizedBox(height: 16),
              _CurrentStorageCard(state: state),
              const SizedBox(height: 12),
              _HealthCard(health: state.health),
              const SizedBox(height: 16),
              // Nhân viên và quản lý dừng ở đây: họ cần BIẾT kho đang ra sao,
              // không cần đổi nó.
              if (state.canManage) ...[
                if (_own) ...[
                  PenOutlineButton(
                    label: l10n.storageTest,
                    onPressed: busy ? null : onTest,
                  ),
                  const SizedBox(height: 10),
                  PenPrimaryButton(
                    label: l10n.storageDisconnect,
                    color: PenColors.danger,
                    onPressed: busy ? null : onDisconnect,
                  ),
                ] else if (state.byosAllowed) ...[
                  PenPrimaryButton(
                    label: l10n.storageConnectS3,
                    onPressed: busy ? null : onConnectS3,
                  ),
                  const SizedBox(height: 10),
                  PenOutlineButton(
                    label: l10n.storageConnectDrive,
                    onPressed: busy ? null : onConnectDrive,
                  ),
                ] else
                  // Gói chưa mở kho riêng. Nói thẳng ra thay vì ẩn im lặng —
                  // ẩn thì người dùng đọc tài liệu thấy có tính năng rồi đi
                  // tìm mãi không ra.
                  _NoteBox(text: l10n.storageNotInPlan),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentStorageCard extends StatelessWidget {
  const _CurrentStorageCard({required this.state});

  final EcStorageState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final system = state.kind == EcStorageKind.system;
    return PenCard(
      axis: PenAxis.column,
      stroke: null,
      gap: 10,
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(
              system ? LucideIcons.cloud : LucideIcons.hardDrive,
              size: 22,
              color: PenColors.ink,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PenText(
                switch (state.kind) {
                  EcStorageKind.system => l10n.storageSystemName,
                  EcStorageKind.s3 => l10n.storageS3Name,
                  EcStorageKind.gdrive => l10n.storageDriveName,
                },
                size: 16,
                color: PenColors.ink,
                weight: FontWeight.w700,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!system) _StatusDot(ok: state.ok),
          ],
        ),
        if (state.label.isNotEmpty)
          PenText(state.label, size: 13, color: PenColors.mut),
        PenText(
          system ? l10n.storageSystemDesc : l10n.storageOwnDesc,
          size: 13,
          color: PenColors.mut,
        ),
        // Câu lỗi của nhà cung cấp, nguyên văn. Đây là thứ duy nhất giúp khách
        // tự sửa được quyền IAM bên phía họ — diễn giải lại là mất manh mối.
        if (!state.ok && (state.lastError?.isNotEmpty ?? false))
          _NoteBox(text: state.lastError!, danger: true),
        // Hai cam kết KHÔNG giữ được ở mọi kho. Nói trước, chứ không để người
        // bán phát hiện lúc đang tranh chấp với sàn.
        if (!system && !state.presignedDownload)
          _NoteBox(text: l10n.storageNoPresign),
        if (!system && !state.objectLock)
          _NoteBox(text: l10n.storageNoObjectLock),
      ],
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.health});

  final EcStorageHealth health;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenCard(
      axis: PenAxis.column,
      stroke: null,
      gap: 8,
      padding: const EdgeInsets.all(16),
      children: [
        PenText(
          l10n.storageHealthTitle.toUpperCase(),
          size: 13,
          color: PenColors.mut,
          weight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
        _HealthRow(label: l10n.storageHealthTotal, value: health.total),
        _HealthRow(label: l10n.storageHealthIntact, value: health.intact),
        // Ba con số dưới là VẤN ĐỀ, nên chỉ hiện khi khác 0 và hiện màu cảnh
        // báo. Một bảng lúc nào cũng có "0 lỗi" thì mắt bỏ qua nó rất nhanh.
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
            danger: true,
          ),
        if (health.hasProblems)
          _NoteBox(text: l10n.storageProblemsNote, danger: true),
      ],
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
    return Row(
      children: [
        Expanded(
          child: PenText(
            label,
            size: 14,
            color: danger ? BrandColors.warning : PenColors.mut,
          ),
        ),
        PenText(
          '$value',
          size: 14,
          color: danger ? BrandColors.warning : PenColors.ink,
          weight: FontWeight.w700,
          softWrap: false,
        ),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.ok});

  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ok ? PenColors.success : BrandColors.warning,
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
