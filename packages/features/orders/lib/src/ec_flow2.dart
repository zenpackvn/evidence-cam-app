/// EvidenceCam Flow 2 screens — "Tab Vận đơn & Hồ sơ": the order list, a
/// per-order evidence timeline, and the video detail bottom sheet. Built
/// pixel-perfect from
/// `specs/projects/evidencecam/design-spec/pencil-app-dna.pen`.
///
/// These are presentational (data-in, callbacks-out) so they can be verified
/// in isolation now and wired to data/routing as those land. Every dimension,
/// gap, font size/weight and color is taken directly from the design file.
library;

import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

// Shared text style (Inter is inherited from AppTheme's textTheme).
TextStyle _t(double size, FontWeight weight, Color color) =>
    TextStyle(fontSize: size, fontWeight: weight, color: color, height: 1.3);

/// Binds [value] into [callback], or returns `null` if [callback] is `null`
/// — keeps optional per-item callbacks (row taps, menu taps, ...) concise.
VoidCallback? _bind<T>(ValueChanged<T>? callback, T value) =>
    callback == null ? null : () => callback(value);

/// The kind of evidence captured by a video/photo entry, driving its icon.
enum EcEvidenceType {
  /// A recorded video clip.
  video(LucideIcons.video),

  /// A still photo attached as evidence.
  image(LucideIcons.image),

  /// A weighing/scale reading.
  scale(LucideIcons.scale);

  const EcEvidenceType(this.icon);

  /// Icon representing this evidence type.
  final IconData icon;
}

/// One evidence entry in [EcOrderTimelineScreen], grouped under a
/// [EcTimelineDay].
class EcTimelineVideo {
  const EcTimelineVideo({
    required this.time,
    required this.label,
    this.id,
    this.recordedAt,
    this.recordedBy,
    this.device,
    this.uploadStatus,
    this.mediaUrl,
    this.thumbUrl,
    this.type = EcEvidenceType.video,
    this.statusText,
    this.statusTone = EcStatusTone.waiting,
    this.statusIcon,
    this.durationSeconds,
    this.capturedAtMs,
  });

  final String? id;

  /// Mốc quay, epoch-ms. [time] chỉ có `HH:mm` nên không dựng lại được đồng hồ
  /// chạy theo giây mà màn ghi hình và dấu đóng vào clip đều cần.
  final int? capturedAtMs;

  /// Time the evidence was captured, e.g. `10:23`.
  final String time;

  /// Video/photo type label, e.g. `Đóng hàng đi`.
  final String label;

  final String? recordedAt;
  final String? recordedBy;
  final String? device;
  final String? uploadStatus;
  final String? mediaUrl;

  /// Poster frame URL — a few dozen KB, shown in place of the leading icon so
  /// the row is recognisable without downloading any video. Null falls back to
  /// the icon (photos, expired evidence, older clips with no poster).
  final String? thumbUrl;

  /// Evidence kind, driving the leading icon.
  final EcEvidenceType type;

  /// Upload status pill text, e.g. `Đang tải 72%`; `null` hides the pill
  /// (evidence already fully uploaded).
  final String? statusText;

  /// Màu của viên trạng thái. Tách khỏi [statusText] vì đoán tông từ nhãn đã
  /// dịch là sai: "Waiting to upload" chứa "upload", "Đang chờ tải" chứa
  /// "tải", và "Server-side processing error" không chứa "lỗi".
  final EcStatusTone statusTone;

  /// Optional leading icon shown inside the status pill, e.g. a retry icon.
  final IconData? statusIcon;

  /// Recorded clip length in seconds; null for photos.
  final int? durationSeconds;
}

/// Năm tông viên trạng thái khung F2-02 vẽ: xong / đang tải / chờ / chờ quota
/// / lỗi.
enum EcStatusTone { done, uploading, waiting, quota, error }

/// A day-grouped section of [EcOrderTimelineScreen]'s evidence timeline.
class EcTimelineDay {
  const EcTimelineDay({required this.date, required this.videos});

  /// Group header, e.g. `23/07/2026`.
  final String date;

  /// Evidence entries recorded on this day, in display order.
  final List<EcTimelineVideo> videos;
}

/// Data shown by [EcVideoDetailScreen]'s bottom sheet.
class EcVideoDetail {
  const EcVideoDetail({
    required this.title,
    required this.duration,
    required this.recordedAt,
    required this.recordedBy,
    required this.device,
    required this.uploadStatus,
    this.fileSize,
    this.mediaUrl,
    this.type = EcEvidenceType.video,
    this.capturedAtMs,
    this.tracking,
    this.durationSeconds,
  });

  /// Mốc quay, epoch-ms — gốc của đồng hồ chạy lúc phát lại và của dấu đóng
  /// vào clip khi xuất. `null` với bằng chứng cũ chưa có trường này.
  final int? capturedAtMs;

  /// Thời lượng clip, giây. Dấu đóng vào clip cần con số này để biết phải vẽ
  /// sẵn bao nhiêu ô đồng hồ; [duration] chỉ là chuỗi `mm:ss` để hiện.
  final int? durationSeconds;

  /// Mã vận đơn của bằng chứng, để hiện lại đúng như lúc quay.
  final String? tracking;

  /// Video type label, e.g. `Đóng hàng đi`.
  final String title;

  /// Clip duration, e.g. `02:45`.
  final String duration;

  /// Recording date + time, e.g. `23/07/2026 · 10:23`.
  final String recordedAt;

  /// Who recorded it, e.g. `Trần Thị B (Nhân viên)`.
  final String recordedBy;

  /// Device + app version, e.g. `iPhone 12 · app 1.0`.
  final String device;

  /// Upload status text, e.g. `Đã upload ✓`.
  final String uploadStatus;

  /// Human-readable file size, e.g. `48,2 MB`; `null` hides the row.
  final String? fileSize;

  /// Public, authenticated-safe media URL exposed by the API for playback and
  /// sharing once upload is complete.
  final String? mediaUrl;

  /// Evidence kind, driving the leading icon.
  final EcEvidenceType type;
}

/// Order timeline — evidence videos for one order, grouped by day, with
/// upload status and an attach-photo action.
class EcOrderTimelineScreen extends StatefulWidget {
  const EcOrderTimelineScreen({
    required this.orderCode,
    required this.days,
    this.pendingUploadCount = 0,
    this.onBack,
    this.onCopyCode,
    this.onRetryUpload,
    this.onVideoTap,
    this.onVideoMenu,
    this.onAttachPhoto,
    this.onCreateLink,
    super.key,
  });

  /// Shipment/tracking code shown in the header.
  final String orderCode;

  /// Evidence entries grouped by day, in display order.
  final List<EcTimelineDay> days;

  /// Number of evidence items still pending upload; `0` hides the warning
  /// banner.
  final int pendingUploadCount;

  /// Called when the back chevron is tapped.
  final VoidCallback? onBack;

  /// Called when the order code's copy icon is tapped.
  final VoidCallback? onCopyCode;

  /// Called when "Thử lại" is tapped on the upload warning banner.
  final VoidCallback? onRetryUpload;

  /// Called when an evidence entry's card is tapped.
  final ValueChanged<EcTimelineVideo>? onVideoTap;

  /// Called with the tapped evidence entry's overflow (⋮) menu.
  final ValueChanged<EcTimelineVideo>? onVideoMenu;

  /// Called when "Đính kèm ảnh vào đơn" is tapped.
  final VoidCallback? onAttachPhoto;

  /// Gộp các bằng chứng đã tick thành một link hồ sơ chia sẻ được.
  final ValueChanged<List<EcTimelineVideo>>? onCreateLink;

  @override
  State<EcOrderTimelineScreen> createState() => _EcOrderTimelineScreenState();
}

class _EcOrderTimelineScreenState extends State<EcOrderTimelineScreen> {
  /// Đang ở chế độ tick chọn bằng chứng để gộp. Mặc định TẮT, nên chạm một
  /// hàng vẫn là mở chi tiết như thường.
  bool _selecting = false;

  /// Id các bằng chứng đã tick. Dùng id thay vì object để tick không mất khi
  /// danh sách được nạp lại (xoá bằng chứng, kéo làm mới).
  final Set<String> _picked = <String>{};

  List<EcTimelineVideo> get _pickedVideos => [
    for (final day in widget.days)
      for (final v in day.videos)
        if (v.id != null && _picked.contains(v.id)) v,
  ];

  void _toggle(EcTimelineVideo video) {
    final id = video.id;
    if (id == null) return;
    setState(() {
      if (!_picked.remove(id)) _picked.add(id);
    });
  }

  void _exitSelection() => setState(() {
    _selecting = false;
    _picked.clear();
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenScreen(
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 0),
            child: _EcOrderTimelineHeader(
              orderCode: widget.orderCode,
              onBack: widget.onBack,
              onCopyCode: widget.onCopyCode,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.pendingUploadCount > 0) ...[
                    _EcUploadWarnBanner(
                      pendingCount: widget.pendingUploadCount,
                      onRetry: widget.onRetryUpload,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (widget.days.isEmpty)
                    _EcTimelineEmpty(text: l10n.timelineEmpty),
                  for (var d = 0; d < widget.days.length; d++) ...[
                    if (d > 0) const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: PenText(
                        widget.days[d].date,
                        size: 16,
                        color: PenColors.ink,
                        weight: FontWeight.w700,
                      ),
                    ),
                    for (var v = 0; v < widget.days[d].videos.length; v++) ...[
                      if (v > 0) const SizedBox(height: 9),
                      _EcTimelineVideoRow(
                        video: widget.days[d].videos[v],
                        selecting: _selecting,
                        picked: _picked.contains(widget.days[d].videos[v].id),
                        onPlay: _selecting
                            ? () => _toggle(widget.days[d].videos[v])
                            : _bind(
                                widget.onVideoTap,
                                widget.days[d].videos[v],
                              ),
                        onMenu: _selecting
                            ? null
                            : _bind(
                                widget.onVideoMenu,
                                widget.days[d].videos[v],
                              ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Ghim đáy màn, NGOÀI vùng cuộn: đơn có năm chục clip thì nút nằm
          // trong danh sách đồng nghĩa phải cuộn hết mới bấm được. Đây là hành
          // động áp lên cả đơn, không thuộc về một hàng nào.
          // Đính kèm ảnh GHIM cùng chỗ với nút gộp, ngoài vùng cuộn.
          //
          // Trước đây nó nằm cuối danh sách bằng chứng: đơn có vài chục clip
          // thì phải cuộn hết mới bấm được, trong khi đính ảnh là việc làm bất
          // cứ lúc nào chứ không phải sau khi xem xong.
          if (!_selecting)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: _EcAttachPhotoRow(onTap: widget.onAttachPhoto),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: _EcBundleSection(
              selecting: _selecting,
              pickedCount: _picked.length,
              onStart: () => setState(() => _selecting = true),
              onCancel: _exitSelection,
              onCreateLink: _picked.isEmpty
                  ? null
                  : () => widget.onCreateLink?.call(_pickedVideos),
            ),
          ),
        ],
      ),
    );
  }
}

/// Video detail — bottom-sheet-style "Chi tiết video": type + duration, when
/// and who recorded it, device, upload status, and play/download/delete
/// actions.
class EcVideoDetailScreen extends StatelessWidget {
  const EcVideoDetailScreen({
    required this.video,
    this.onClose,
    this.onPlay,
    this.onCopyLink,
    this.onDownload,
    this.onDelete,
    this.canDelete = true,
    super.key,
  });

  /// The video whose details are shown.
  final EcVideoDetail video;

  /// Called when the dimmed area above the sheet is tapped.
  final VoidCallback? onClose;

  /// Called when "Phát video" is tapped.
  final VoidCallback? onPlay;

  /// Called when "Sao chép link" is tapped.
  final VoidCallback? onCopyLink;

  /// Called when "Tải video về máy" is tapped.
  final VoidCallback? onDownload;

  /// Called when "Xóa video" is tapped.
  final VoidCallback? onDelete;

  /// Whether the current user may delete this clip. False for Nhân viên
  /// (staff) — hides the delete row.
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenSheet(
      onDismiss: onClose,
      // Design `Sheet`: padding [12, 20, 20, 20], over an ink `Dim`.
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      dim: const Color(0x99161616),
      children: [
        const SizedBox(height: 18),
        Row(
          children: [
            PenBox(
              width: 48,
              height: 48,
              fill: PenColors.line,
              radius: 14,
              axis: PenAxis.row,
              main: MainAxisAlignment.center,
              cross: CrossAxisAlignment.center,
              children: [
                Icon(video.type.icon, size: 24, color: PenColors.ink),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: PenText(
                l10n.videoDetailSheetTitle,
                size: 24,
                color: PenColors.ink,
                weight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 170),
              child: PenText(
                '${video.title} · ${video.duration}',
                size: 16,
                color: PenColors.mut,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _EcDetailInfoRow(
          label: l10n.detailRecordedTime,
          value: video.recordedAt,
        ),
        const _EcDetailDivider(),
        _EcDetailInfoRow(
          label: l10n.detailRecordedBy,
          value: video.recordedBy,
        ),
        const _EcDetailDivider(),
        _EcDetailInfoRow(label: l10n.detailDevice, value: video.device),
        const _EcDetailDivider(),
        _EcDetailInfoRow(
          label: l10n.detailUploadStatus,
          value: video.uploadStatus,
          trailing: LucideIcons.check,
        ),
        if (video.fileSize != null) ...[
          const _EcDetailDivider(),
          _EcDetailInfoRow(
            label: l10n.detailSize,
            value: video.fileSize!,
          ),
        ],
        const SizedBox(height: 18),
        PenCard(
          axis: PenAxis.column,
          clip: true,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          children: [
            _EcDetailActionRow(
              icon: LucideIcons.play,
              title: l10n.detailPlayVideo,
              onTap: onPlay,
            ),
            if (video.mediaUrl != null) ...[
              const _EcDetailDivider(),
              _EcDetailActionRow(
                icon: LucideIcons.copy,
                title: l10n.detailCopyAssetLink,
                onTap: onCopyLink,
              ),
            ],
            const _EcDetailDivider(),
            _EcDetailActionRow(
              icon: LucideIcons.download,
              title: l10n.detailDownloadVideo,
              subtitle: l10n.detailDownloadNote,
              onTap: onDownload,
            ),
            if (canDelete) ...[
              const _EcDetailDivider(),
              _EcDetailActionRow(
                icon: LucideIcons.trash2,
                title: l10n.deleteVideoAction,
                subtitle: l10n.deleteVideoNote,
                danger: true,
                onTap: onDelete,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// The hairline the design puts between rows inside a sheet or card.
class _EcDetailDivider extends StatelessWidget {
  const _EcDetailDivider();

  @override
  Widget build(BuildContext context) => const PenBox(
    width: double.infinity,
    height: 1,
    fill: PenColors.line,
  );
}

/// Photo detail — bottom-sheet-style "Chi tiết ảnh": the photo itself, plus
/// when and who captured it.
class EcPhotoDetailScreen extends StatelessWidget {
  const EcPhotoDetailScreen({
    required this.photo,
    this.onClose,
    this.onCopyLink,
    this.onDownload,
    this.onDelete,
    this.canDelete = true,
    super.key,
  });

  /// The photo whose details are shown.
  final EcVideoDetail photo;

  /// Xoá ảnh khỏi đơn. Màn ảnh trước đây KHÔNG có mục này, dù màn video thì
  /// có — nên ảnh đính nhầm là không gỡ ra được bằng đường nào.
  final VoidCallback? onDelete;
  final bool canDelete;

  /// Called when the dimmed area above the sheet is tapped.
  final VoidCallback? onClose;

  /// Called when "Sao chép link" is tapped.
  final VoidCallback? onCopyLink;

  /// Called when "Tải ảnh về máy" is tapped.
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.9,
            ),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: BrandColors.bg,
                shape: SmoothRectangleBorder(
                  smoothness: ecCornerSmoothing,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                // The photo can be tall enough (up to 360dp) that the header
                // + info rows + download button no longer fit on smaller
                // screens — scroll instead of silently clipping the download
                // button off-screen.
                child: SingleChildScrollView(
                  // Đáy chỉ 10: SafeArea ở trên đã chừa chỗ cho home
                  // indicator, cộng thêm 28 nữa là dải trắng thừa.
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: BrandColors.line,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: BrandColors.soft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                photo.type.icon,
                                size: 16,
                                color: BrandColors.mut,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                photo.title,
                                overflow: TextOverflow.ellipsis,
                                style: _t(
                                  16,
                                  FontWeight.w600,
                                  BrandColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: photo.mediaUrl == null
                            ? const SizedBox(
                                width: double.infinity,
                                height: 160,
                                child: ColoredBox(
                                  color: BrandColors.soft,
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 40,
                                    color: BrandColors.mut,
                                  ),
                                ),
                              )
                            : ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 360,
                                ),
                                child: Image.network(
                                  photo.mediaUrl!,
                                  // Show the whole photo uncropped — the
                                  // sheet just bounds its height, it doesn't
                                  // force a square crop like the video
                                  // thumbnail does.
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const SizedBox(
                                      width: double.infinity,
                                      height: 160,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox(
                                        width: double.infinity,
                                        height: 160,
                                        child: ColoredBox(
                                          color: BrandColors.soft,
                                          child: Icon(
                                            Icons.broken_image_outlined,
                                            size: 40,
                                            color: BrandColors.mut,
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                      _EcDetailInfoRow(
                        label: context.l10n.detailCapturedTime,
                        value: photo.recordedAt,
                      ),
                      _EcDetailInfoRow(
                        label: context.l10n.detailCapturedBy,
                        value: photo.recordedBy,
                      ),
                      if (photo.mediaUrl != null)
                        _EcDetailActionRow(
                          icon: LucideIcons.copy,
                          title: context.l10n.detailCopyAssetLink,
                          onTap: onCopyLink,
                        ),
                      _EcDetailActionRow(
                        icon: LucideIcons.download,
                        title: context.l10n.detailDownloadPhoto,
                        onTap: onDownload,
                      ),
                      if (canDelete) ...[
                        const _EcDetailDivider(),
                        _EcDetailActionRow(
                          icon: LucideIcons.trash2,
                          title: context.l10n.deletePhotoAction,
                          subtitle: context.l10n.deleteVideoNote,
                          danger: true,
                          onTap: onDelete,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- shared pieces (pixel specs from pencil-app-dna.pen) ---

class _EcOrderTimelineHeader extends StatelessWidget {
  const _EcOrderTimelineHeader({
    required this.orderCode,
    this.onBack,
    this.onCopyCode,
  });

  final String orderCode;
  final VoidCallback? onBack;
  final VoidCallback? onCopyCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PenBackButton(onTap: onBack),
        const SizedBox(width: 12),
        // Tiêu đề cũng quay lại: mũi tên 42pt là đích bấm nhỏ khi người dùng
        // đang cầm máy một tay, còn dải tiêu đề thì rộng gần hết bề ngang.
        Expanded(
          child: EcTap(
            onTap: onBack,
            child: PenText(
              orderCode,
              size: 24,
              color: PenColors.ink,
              weight: FontWeight.w800,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 12),
        EcTap(
          onTap: onCopyCode,
          child: const Icon(LucideIcons.copy, size: 24, color: PenColors.ink),
        ),
      ],
    );
  }
}

class _EcUploadWarnBanner extends StatelessWidget {
  const _EcUploadWarnBanner({required this.pendingCount, this.onRetry});

  final int pendingCount;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenBox(
      width: double.infinity,
      fill: PenColors.bg,
      radius: 14,
      axis: PenAxis.row,
      gap: 12,
      cross: CrossAxisAlignment.center,
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(LucideIcons.cloud, size: 22, color: PenColors.ink),
        Expanded(
          child: PenText(
            l10n.ordersPendingEvidenceWarning(pendingCount),
            size: 12,
            color: PenColors.ink,
          ),
        ),
        EcTap(
          onTap: onRetry,
          child: PenText(
            l10n.commonRetry,
            size: 12,
            color: PenColors.link,
            weight: FontWeight.w700,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

class _EcBundleSection extends StatelessWidget {
  const _EcBundleSection({
    required this.selecting,
    required this.pickedCount,
    this.onStart,
    this.onCancel,
    this.onCreateLink,
  });

  final bool selecting;
  final int pickedCount;
  final VoidCallback? onStart;
  final VoidCallback? onCancel;
  final VoidCallback? onCreateLink;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!selecting) {
      return EcTap(
        onTap: onStart,
        child: PenBox(
          width: double.infinity,
          height: 52,
          fill: PenColors.card,
          stroke: PenColors.line,
          radius: 14,
          axis: PenAxis.row,
          gap: 8,
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          children: [
            const Icon(LucideIcons.plus, size: 20, color: PenColors.ink),
            PenText(
              // Nói thẳng ra cái sắp nhận được. Từ khi "Đẩy lên Drive" tạm gỡ
              // thì gộp bằng chứng chỉ còn một đường ra là link, nên "Tạo"
              // chung chung bắt người dùng bấm vào mới biết mình được gì.
              l10n.bundleCreateLink,
              size: 15,
              color: PenColors.ink,
              weight: FontWeight.w600,
              softWrap: false,
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: PenText(
                l10n.bundleSelected(pickedCount),
                size: 13,
                color: PenColors.mut,
              ),
            ),
            EcTap(
              onTap: onCancel,
              child: PenText(
                l10n.commonCancel,
                size: 13,
                color: PenColors.link,
                weight: FontWeight.w700,
                softWrap: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Chỉ còn đường tạo link. Nút "Đẩy lên Drive" tạm gỡ vì chưa
        // có gì đứng sau nó — chuỗi l10n `bundleUploadDrive` vẫn giữ, dựng lại
        // là thêm một `_BundleAction` nữa ở đây.
        _BundleAction(
          icon: LucideIcons.link,
          label: l10n.bundleCreateLink,
          onTap: onCreateLink,
          primary: true,
        ),
      ],
    );
  }
}

class _BundleAction extends StatelessWidget {
  const _BundleAction({
    required this.icon,
    required this.label,
    this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final fg = primary
        ? PenColors.card
        : (enabled ? PenColors.ink : PenColors.mut);
    return EcTap(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: PenBox(
          width: double.infinity,
          height: 52,
          fill: primary ? PenColors.primary : PenColors.card,
          stroke: primary ? null : PenColors.line,
          radius: 14,
          axis: PenAxis.row,
          gap: 8,
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 19, color: fg),
            PenText(
              label,
              size: 15,
              color: fg,
              weight: FontWeight.w700,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _EcTimelineVideoRow extends StatelessWidget {
  const _EcTimelineVideoRow({
    required this.video,
    this.onPlay,
    this.onMenu,
    this.selecting = false,
    this.picked = false,
  });

  final EcTimelineVideo video;
  final VoidCallback? onPlay;
  final VoidCallback? onMenu;

  /// Đang ở chế độ chọn để gộp: hàng hiện ô tick thay cho nút ⋮, và chạm vào
  /// hàng là tick chứ không mở chi tiết.
  final bool selecting;
  final bool picked;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 46,
          child: PenText(video.time, size: 14, color: PenColors.mut),
        ),
        const SizedBox(
          width: 22,
          height: 58,
          child: Center(
            child: PenEllipse(width: 11, height: 11, color: PenColors.ink),
          ),
        ),
        Expanded(
          // The whole card opens the evidence detail — the design's play
          // triangle was a second, smaller target for the same destination.
          child: PenCard(
            lifted: false,
            gap: 12,
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 11,
            ),
            onTap: onPlay,
            children: [
              _EcTimelineThumb(video: video),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PenText(
                      video.label,
                      size: 14,
                      color: PenColors.ink,
                      weight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (video.statusText != null) ...[
                      const SizedBox(height: 4),
                      _EcStatusBadge(
                        text: video.statusText!,
                        tone: video.statusTone,
                        icon: video.statusIcon,
                      ),
                    ],
                  ],
                ),
              ),
              if (selecting)
                Icon(
                  picked ? LucideIcons.squareCheckBig : LucideIcons.square,
                  size: 20,
                  color: picked ? PenColors.primary : PenColors.mut,
                )
              else
                EcTap(
                  onTap: onMenu,
                  child: const Icon(
                    LucideIcons.ellipsisVertical,
                    size: 16,
                    color: PenColors.ink,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Leading square of a timeline row: the clip's own poster frame when there is
/// one, otherwise the kind icon.
///
/// Every fallback lands on the same icon square, so a missing, still-uploading
/// or broken poster looks like the old design rather than like a bug.
class _EcTimelineThumb extends StatelessWidget {
  const _EcTimelineThumb({required this.video});

  static const _size = 42.0;
  static const _radius = 10.0;

  final EcTimelineVideo video;

  @override
  Widget build(BuildContext context) {
    final url = video.thumbUrl;
    if (url == null) return _icon();
    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: Image.network(
        url,
        width: _size,
        height: _size,
        // A poster is 16:9 and the slot is square — crop rather than letterbox,
        // so the row keeps its rhythm down the list.
        fit: BoxFit.cover,
        // Bounded so a large source decodes small: the whole point of the
        // poster is that a timeline costs almost no memory or bandwidth.
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
    children: [Icon(video.type.icon, size: 21, color: PenColors.ink)],
  );
}

class _EcStatusBadge extends StatelessWidget {
  const _EcStatusBadge({required this.text, required this.tone, this.icon});

  final String text;
  final EcStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // The design colours the pill by what the status means: green done,
    // blue in-flight, amber blocked, red failed — the fill stays grey except
    // for the failure case, which gets a wash.
    final (fill, ink) = _palette;
    return PenBox(
      fill: fill,
      radius: 999,
      axis: PenAxis.row,
      gap: 5,
      cross: CrossAxisAlignment.center,
      hugMain: true,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 9),
      children: [
        if (icon != null) Icon(icon, size: 12, color: ink),
        Flexible(
          child: PenText(
            text,
            size: 12,
            color: ink,
            weight: FontWeight.w500,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Đúng 5 viên khung F2-02 vẽ.
  (Color, Color) get _palette => switch (tone) {
    EcStatusTone.done => (PenColors.soft, PenColors.success),
    EcStatusTone.uploading => (PenColors.line, PenColors.link),
    EcStatusTone.waiting => (PenColors.line, PenColors.mut),
    EcStatusTone.quota => (PenColors.line, const Color(0xFFB6770B)),
    EcStatusTone.error => (const Color(0xFFF8E7E7), PenColors.danger),
  };
}

class _EcAttachPhotoRow extends StatelessWidget {
  const _EcAttachPhotoRow({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: PenBox(
        width: double.infinity,
        height: 54,
        fill: PenColors.card,
        stroke: PenColors.line,
        radius: 14,
        axis: PenAxis.row,
        gap: 12,
        main: MainAxisAlignment.center,
        cross: CrossAxisAlignment.center,
        children: [
          const Icon(LucideIcons.plus, size: 21, color: PenColors.ink),
          Flexible(
            child: PenText(
              context.l10n.attachPhotoToOrder,
              size: 16,
              color: PenColors.link,
              weight: FontWeight.w600,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown in place of the timeline when a shipment has no evidence yet.
class _EcTimelineEmpty extends StatelessWidget {
  const _EcTimelineEmpty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(
            Icons.videocam_off_outlined,
            size: 36,
            color: BrandColors.mut,
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: _t(14, FontWeight.w400, BrandColors.mut),
          ),
        ],
      ),
    );
  }
}

class _EcDetailInfoRow extends StatelessWidget {
  const _EcDetailInfoRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;

  /// Optional glyph after the value, e.g. the upload-complete tick.
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      width: double.infinity,
      axis: PenAxis.row,
      gap: 10,
      cross: CrossAxisAlignment.center,
      padding: const EdgeInsets.symmetric(vertical: 14),
      children: [
        PenText(label, size: 14, color: PenColors.mut, softWrap: false),
        // The design's spacer is the flexible one and the value hugs its text,
        // so the value gets all the leftover room and only ellipsises when it
        // genuinely cannot fit.
        Expanded(
          child: PenText(
            value,
            size: 14,
            color: PenColors.ink,
            weight: FontWeight.w500,
            align: TextAlign.right,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) Icon(trailing, size: 19, color: PenColors.ink),
      ],
    );
  }
}

class _EcDetailActionRow extends StatelessWidget {
  const _EcDetailActionRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Destructive actions take `--destructive` for the tile, label and chevron.
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ink = danger ? PenColors.danger : PenColors.ink;
    return EcTap(
      onTap: onTap,
      child: PenBox(
        width: double.infinity,
        axis: PenAxis.row,
        gap: 14,
        cross: CrossAxisAlignment.center,
        padding: const EdgeInsets.symmetric(vertical: 13),
        children: [
          PenBox(
            width: 44,
            height: 44,
            fill: danger ? const Color(0xFFFDECEC) : PenColors.bg,
            radius: 10,
            axis: PenAxis.row,
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.center,
            children: [Icon(icon, size: 22, color: ink)],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                PenText(
                  title,
                  size: 16,
                  color: ink,
                  weight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  PenText(
                    subtitle!,
                    size: 12,
                    color: PenColors.mut,
                    lineHeight: 1.4,
                  ),
                ],
              ],
            ),
          ),
          Icon(
            LucideIcons.chevronRight,
            size: 19,
            color: danger ? PenColors.danger : PenColors.mut,
          ),
        ],
      ),
    );
  }
}

class _EcDetailDeleteRow extends StatelessWidget {
  const _EcDetailDeleteRow({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: Container(
        decoration: ecSquircleDecoration(
          radius: 10,
          color: BrandColors.soft,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline,
                size: 22,
                color: BrandColors.ink,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.deleteVideoAction,
                      style: _t(16, FontWeight.w500, BrandColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.deleteVideoNote,
                      style: _t(14, FontWeight.w400, BrandColors.mut),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
