/// EvidenceCam Flow 2 screens — "Tab Vận đơn & Hồ sơ": the order list, a
/// per-order evidence timeline, and the video detail bottom sheet. Built
/// pixel-perfect from
/// `specs/projects/evidencecam/design-spec/pencil-new.pen`.
///
/// These are presentational (data-in, callbacks-out) so they can be verified
/// in isolation now and wired to data/routing as those land. Every dimension,
/// gap, font size/weight and color is taken directly from the design file.
library;

import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoPageScaffold, CupertinoTextField;
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
  video(Icons.videocam_outlined),

  /// A still photo attached as evidence.
  image(Icons.image_outlined),

  /// A weighing/scale reading.
  scale(Icons.scale);

  const EcEvidenceType(this.icon);

  /// Icon representing this evidence type.
  final IconData icon;
}

/// A single value+label tile in [EcOrderListScreen]'s stats row.
class EcOrderListStat {
  const EcOrderListStat({required this.value, required this.label});

  /// The headline number, e.g. `24`.
  final String value;

  /// The caption below the number, e.g. `Vận đơn hôm nay`.
  final String label;
}

/// One row in [EcOrderListScreen]: a shipment code with its latest evidence
/// video.
class EcOrderRow {
  const EcOrderRow({
    required this.code,
    required this.time,
    required this.videoType,
    required this.videoCount,
    this.errorCount = 0,
  });

  /// Shipment/tracking code.
  final String code;

  /// Time of the latest video, e.g. `10:23`.
  final String time;

  /// Label of the latest video type, e.g. `Đóng hàng đi`.
  final String videoType;

  /// Total number of evidence videos recorded for this order.
  final int videoCount;

  /// Number of videos that failed to upload; `0` hides the error indicator.
  final int errorCount;
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
    this.type = EcEvidenceType.video,
    this.statusText,
    this.statusIcon,
  });

  final String? id;

  /// Time the evidence was captured, e.g. `10:23`.
  final String time;

  /// Video/photo type label, e.g. `Đóng hàng đi`.
  final String label;

  final String? recordedAt;
  final String? recordedBy;
  final String? device;
  final String? uploadStatus;
  final String? mediaUrl;

  /// Evidence kind, driving the leading icon.
  final EcEvidenceType type;

  /// Upload status pill text, e.g. `Đang tải 72%`; `null` hides the pill
  /// (evidence already fully uploaded).
  final String? statusText;

  /// Optional leading icon shown inside the status pill, e.g. a retry icon.
  final IconData? statusIcon;
}

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
  });

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

/// Order list — "Vận đơn" tab: shop header, stats, search, filters and the
/// list of orders with their evidence video counts.
class EcOrderListScreen extends StatelessWidget {
  const EcOrderListScreen({
    required this.orders,
    this.shopName = 'Shop',
    this.queueCount = 3,
    this.stats = const [
      EcOrderListStat(value: '0', label: 'Vận đơn hôm nay'),
      EcOrderListStat(value: '0', label: 'Video đã quay'),
      EcOrderListStat(value: '0', label: 'Chờ tải'),
    ],
    this.filters = const ['Tất cả', 'Mọi lúc', 'Mọi loại video'],
    this.searchController,
    this.searchHint = 'Nhập mã vận đơn',
    this.onBack,
    this.onScan,
    this.onFilterTap,
    this.onOrderTap,
    this.onNavOrders,
    this.onNavRecord,
    this.onNavAccount,
    super.key,
  });

  /// Orders to list, in display order.
  final List<EcOrderRow> orders;

  /// Shop name shown in the header.
  final String shopName;

  /// Number of items pending upload, shown in the header's queue chip.
  final int queueCount;

  /// The three summary tiles above the search box.
  final List<EcOrderListStat> stats;

  /// Filter chip labels — the three of Flow 2·1 (upload status, time, video
  /// type), each showing its "no filter" value. The live screen is
  /// `EcHomeOrdersScreen`, which drives the same three against the backend;
  /// this one is the static design-spec rendering.
  final List<String> filters;

  /// Controller for the "Nhập mã vận đơn" search field.
  final TextEditingController? searchController;

  /// Placeholder shown in the search field.
  final String searchHint;

  /// Called when the back chevron is tapped.
  final VoidCallback? onBack;

  /// Called when the barcode/scan button is tapped.
  final VoidCallback? onScan;

  /// Called with the tapped filter's label.
  final ValueChanged<String>? onFilterTap;

  /// Called with the tapped order row.
  final ValueChanged<EcOrderRow>? onOrderTap;

  /// Called when the "Vận đơn" tab is tapped.
  final VoidCallback? onNavOrders;

  /// Called when the "Ghi hình" tab is tapped.
  final VoidCallback? onNavRecord;

  /// Called when the "Tài khoản" tab is tapped.
  final VoidCallback? onNavAccount;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            _EcOrderListHeader(
              shopName: shopName,
              queueCount: queueCount,
              onBack: onBack,
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              for (var i = 0; i < stats.length; i++) ...[
                                if (i > 0) const SizedBox(width: 8),
                                Expanded(child: _EcStatTile(stat: stats[i])),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          _EcSearchBox(
                            controller: searchController,
                            hint: searchHint,
                            onScan: onScan,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final filter in filters)
                                  _EcFilterChip(
                                    label: filter,
                                    onTap: _bind(onFilterTap, filter),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) => _EcOrderRowTile(
                        order: orders[index],
                        onTap: _bind(onOrderTap, orders[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _EcBottomNav(
              onOrders: onNavOrders,
              onRecord: onNavRecord,
              onAccount: onNavAccount,
            ),
          ],
        ),
      ),
    );
  }
}

/// Order timeline — evidence videos for one order, grouped by day, with
/// upload status, a copy/share dossier link, and an attach-photo action.
class EcOrderTimelineScreen extends StatelessWidget {
  const EcOrderTimelineScreen({
    required this.orderCode,
    required this.days,
    this.pendingUploadCount = 0,
    this.dossierUrl,
    this.onBack,
    this.onCopyCode,
    this.onRetryUpload,
    this.onVideoTap,
    this.onVideoMenu,
    this.onAttachPhoto,
    this.onCreateDossier,
    this.onCopyLink,
    this.onShareLink,
    this.onRevokeDossier,
    super.key,
  });

  /// Shipment/tracking code shown in the header.
  final String orderCode;

  /// Evidence entries grouped by day, in display order.
  final List<EcTimelineDay> days;

  /// Number of evidence items still pending upload; `0` hides the warning
  /// banner.
  final int pendingUploadCount;

  /// Public dossier link shown at the bottom, when available.
  final String? dossierUrl;

  /// Called when the back chevron is tapped.
  final VoidCallback? onBack;

  /// Called when the order code's copy icon is tapped.
  final VoidCallback? onCopyCode;

  /// Called when "Thử lại" is tapped on the upload warning banner.
  final VoidCallback? onRetryUpload;

  /// Called with the tapped evidence entry's play button.
  final ValueChanged<EcTimelineVideo>? onVideoTap;

  /// Called with the tapped evidence entry's overflow (⋮) menu.
  final ValueChanged<EcTimelineVideo>? onVideoMenu;

  /// Called when "Đính kèm ảnh vào đơn" is tapped.
  final VoidCallback? onAttachPhoto;

  /// Called when "Tạo link hồ sơ khiếu nại" is tapped.
  final VoidCallback? onCreateDossier;

  /// Called when the dossier link's copy icon is tapped.
  final VoidCallback? onCopyLink;

  /// Called when the dossier link's share icon is tapped.
  final VoidCallback? onShareLink;

  /// Called when the dossier link's revoke action is tapped.
  final VoidCallback? onRevokeDossier;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            _EcOrderTimelineHeader(
              orderCode: orderCode,
              onBack: onBack,
              onCopyCode: onCopyCode,
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          if (pendingUploadCount > 0) ...[
                            _EcUploadWarnBanner(
                              pendingCount: pendingUploadCount,
                              onRetry: onRetryUpload,
                            ),
                            const SizedBox(height: 12),
                          ],
                          for (var d = 0; d < days.length; d++) ...[
                            if (d > 0) const SizedBox(height: 22),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                days[d].date,
                                style: _t(12, FontWeight.w600, BrandColors.mut),
                              ),
                            ),
                            for (final video in days[d].videos) ...[
                              const SizedBox(height: 12),
                              _EcTimelineVideoRow(
                                video: video,
                                onPlay: _bind(onVideoTap, video),
                                onMenu: _bind(onVideoMenu, video),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _EcAttachPhotoRow(onTap: onAttachPhoto),
                          if (dossierUrl == null &&
                              onCreateDossier != null) ...[
                            const SizedBox(height: 12),
                            _EcCreateDossierRow(onTap: onCreateDossier),
                          ] else if (dossierUrl != null) ...[
                            const SizedBox(height: 12),
                            _EcDossierLinkBox(
                              url: dossierUrl!,
                              onCopy: onCopyLink,
                              onShare: onShareLink,
                              onRevoke: onRevokeDossier,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  /// Called when "Tải video về máy" is tapped.
  final VoidCallback? onDownload;

  /// Called when "Xóa video" is tapped.
  final VoidCallback? onDelete;

  /// Whether the current user may delete this clip. False for Nhân viên (staff)
  /// and clips locked into a submitted dossier (FR-05) — hides the delete row.
  final bool canDelete;

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
                    top: Radius.circular(20),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                // Title + up to 5 info rows + 3 action rows can be taller
                // than the screen on smaller devices or with larger system
                // font sizes — scroll instead of silently clipping
                // Play/Download/Delete off-screen.
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
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
                                video.type.icon,
                                size: 16,
                                color: BrandColors.mut,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                video.title,
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
                      _EcDetailInfoRow(
                        label: context.l10n.detailRecordedTime,
                        value: video.recordedAt,
                      ),
                      _EcDetailInfoRow(
                        label: context.l10n.detailRecordedBy,
                        value: video.recordedBy,
                      ),
                      _EcDetailInfoRow(
                        label: context.l10n.detailDevice,
                        value: video.device,
                      ),
                      if (video.fileSize != null)
                        _EcDetailInfoRow(
                          label: context.l10n.detailSize,
                          value: video.fileSize!,
                        ),
                      _EcDetailInfoRow(
                        label: context.l10n.detailUploadStatus,
                        value: video.uploadStatus,
                      ),
                      _EcDetailActionRow(
                        icon: Icons.play_arrow,
                        label: context.l10n.detailPlayVideo,
                        onTap: onPlay,
                      ),
                      _EcDetailActionRow(
                        icon: Icons.download_outlined,
                        label: context.l10n.detailDownloadVideo,
                        subLabel: context.l10n.detailDownloadNote,
                        onTap: onDownload,
                      ),
                      const SizedBox(height: 4),
                      if (canDelete) _EcDetailDeleteRow(onTap: onDelete),
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

/// Photo detail — bottom-sheet-style "Chi tiết ảnh": the photo itself, plus
/// when and who captured it.
class EcPhotoDetailScreen extends StatelessWidget {
  const EcPhotoDetailScreen({
    required this.photo,
    this.onClose,
    this.onDownload,
    super.key,
  });

  /// The photo whose details are shown.
  final EcVideoDetail photo;

  /// Called when the dimmed area above the sheet is tapped.
  final VoidCallback? onClose;

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
                    top: Radius.circular(20),
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
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
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
                      _EcDetailActionRow(
                        icon: Icons.download_outlined,
                        label: context.l10n.detailDownloadPhoto,
                        onTap: onDownload,
                      ),
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

// --- shared pieces (pixel specs from pencil-new.pen) ---

class _EcOrderListHeader extends StatelessWidget {
  const _EcOrderListHeader({
    required this.shopName,
    required this.queueCount,
    this.onBack,
  });

  final String shopName;
  final int queueCount;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          EcTap(
            onTap: onBack,
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.chevron_left,
                size: 20,
                color: BrandColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              shopName,
              overflow: TextOverflow.ellipsis,
              style: _t(15, FontWeight.w600, BrandColors.ink),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: BrandColors.soft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_outlined,
                  size: 14,
                  color: BrandColors.ink,
                ),
                const SizedBox(width: 4),
                Text(
                  '$queueCount',
                  style: _t(12, FontWeight.w600, BrandColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EcStatTile extends StatelessWidget {
  const _EcStatTile({required this.stat});

  final EcOrderListStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: BrandColors.soft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(stat.value, style: _t(18, FontWeight.w700, BrandColors.ink)),
          const SizedBox(height: 2),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            style: _t(11, FontWeight.w400, BrandColors.mut),
          ),
        ],
      ),
    );
  }
}

class _EcSearchBox extends StatelessWidget {
  const _EcSearchBox({required this.hint, this.controller, this.onScan});

  final String hint;
  final TextEditingController? controller;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 4),
      decoration: ecSquircleDecoration(
        radius: 12,
        color: BrandColors.soft,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: BrandColors.mut),
          const SizedBox(width: 8),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              style: _t(15, FontWeight.w400, BrandColors.ink),
              placeholder: hint,
              placeholderStyle: _t(15, FontWeight.w400, BrandColors.mut),
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(),
            ),
          ),
          EcTap(
            onTap: onScan,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.qr_code_scanner_outlined,
                size: 18,
                color: BrandColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EcFilterChip extends StatelessWidget {
  const _EcFilterChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: Container(
        decoration: ecSquircleDecoration(
          radius: 999,
          side: const BorderSide(color: BrandColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: _t(13, FontWeight.w500, BrandColors.ink)),
              const SizedBox(width: 5),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 13,
                color: BrandColors.mut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EcOrderRowTile extends StatelessWidget {
  const _EcOrderRowTile({required this.order, this.onTap});

  final EcOrderRow order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: BrandColors.line)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: BrandColors.soft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 18,
                  color: BrandColors.mut,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      order.code,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(14, FontWeight.w600, BrandColors.ink),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${order.time} · ${order.videoType}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(12, FontWeight.w400, BrandColors.mut),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.videocam_outlined,
                size: 16,
                color: BrandColors.ink,
              ),
              const SizedBox(width: 4),
              Text(
                '${order.videoCount}',
                style: _t(13, FontWeight.w600, BrandColors.ink),
              ),
              if (order.errorCount > 0) ...[
                const SizedBox(width: 4),
                Text(
                  context.l10n.ordersErrorCount(order.errorCount),
                  style: _t(11, FontWeight.w600, BrandColors.rec),
                ),
              ],
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 16, color: BrandColors.mut),
            ],
          ),
        ),
      ),
    );
  }
}

class _EcBottomNav extends StatelessWidget {
  const _EcBottomNav({this.onOrders, this.onRecord, this.onAccount});

  final VoidCallback? onOrders;
  final VoidCallback? onRecord;
  final VoidCallback? onAccount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: BrandColors.bg,
        border: Border(top: BorderSide(color: BrandColors.line)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: _EcNavTab(
                icon: Icons.inventory_2_outlined,
                label: context.l10n.navOrders,
                active: true,
                onTap: onOrders,
              ),
            ),
            Expanded(
              child: _EcNavTab(
                icon: Icons.camera_alt_outlined,
                label: context.l10n.navRecord,
                onTap: onRecord,
              ),
            ),
            Expanded(
              child: _EcNavTab(
                icon: Icons.person_outline,
                label: context.l10n.navAccount,
                onTap: onAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EcNavTab extends StatelessWidget {
  const _EcNavTab({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? BrandColors.ink : BrandColors.mut;
    return EcTap(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: _t(10, active ? FontWeight.w600 : FontWeight.w400, color),
          ),
        ],
      ),
    );
  }
}

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          EcTap(
            onTap: onBack,
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.chevron_left,
                size: 24,
                color: BrandColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              orderCode,
              overflow: TextOverflow.ellipsis,
              style: _t(19, FontWeight.w700, BrandColors.ink),
            ),
          ),
          EcTap(
            onTap: onCopyCode,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.copy_outlined,
                size: 20,
                color: BrandColors.mut,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EcUploadWarnBanner extends StatelessWidget {
  const _EcUploadWarnBanner({required this.pendingCount, this.onRetry});

  final int pendingCount;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: ecSquircleDecoration(
        radius: 12,
        color: BrandColors.soft,
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_outlined, size: 18, color: BrandColors.ink),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.ordersPendingEvidenceWarning(pendingCount),
              style: _t(13, FontWeight.w500, BrandColors.ink),
            ),
          ),
          const SizedBox(width: 8),
          EcTap(
            onTap: onRetry,
            child: Text(
              context.l10n.commonRetry,
              style: _t(13, FontWeight.w600, BrandColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _EcTimelineVideoRow extends StatelessWidget {
  const _EcTimelineVideoRow({required this.video, this.onPlay, this.onMenu});

  final EcTimelineVideo video;
  final VoidCallback? onPlay;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final statusText = video.statusText;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 44,
          child: Text(
            video.time,
            style: _t(14, FontWeight.w400, BrandColors.mut),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: ecSquircleDecoration(
              radius: 12,
              side: const BorderSide(color: BrandColors.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: BrandColors.soft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    video.type.icon,
                    size: 18,
                    color: BrandColors.mut,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    video.label,
                    overflow: TextOverflow.ellipsis,
                    style: _t(15, FontWeight.w500, BrandColors.ink),
                  ),
                ),
                if (statusText != null) ...[
                  Flexible(
                    child: _EcStatusBadge(
                      text: statusText,
                      icon: video.statusIcon,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                EcTap(
                  onTap: onPlay,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.play_arrow,
                      size: 16,
                      color: BrandColors.ink,
                    ),
                  ),
                ),
                EcTap(
                  onTap: onMenu,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.more_vert,
                      size: 14,
                      color: BrandColors.mut,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EcStatusBadge extends StatelessWidget {
  const _EcStatusBadge({required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final leadingIcon = icon;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: BrandColors.soft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 12, color: BrandColors.ink),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: _t(12, FontWeight.w600, BrandColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _EcAttachPhotoRow extends StatelessWidget {
  const _EcAttachPhotoRow({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: Container(
        decoration: ecSquircleDecoration(
          radius: 10,
          side: const BorderSide(color: BrandColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 20, color: BrandColors.ink),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  context.l10n.attachPhotoToOrder,
                  overflow: TextOverflow.ellipsis,
                  style: _t(16, FontWeight.w500, BrandColors.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EcCreateDossierRow extends StatelessWidget {
  const _EcCreateDossierRow({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: ecSquircleDecoration(
          radius: 10,
          color: BrandColors.soft,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.link_outlined,
              size: 18,
              color: BrandColors.ink,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.createDossierLink,
                style: _t(14, FontWeight.w600, BrandColors.ink),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: BrandColors.mut,
            ),
          ],
        ),
      ),
    );
  }
}

class _EcDossierLinkBox extends StatelessWidget {
  const _EcDossierLinkBox({
    required this.url,
    this.onCopy,
    this.onShare,
    this.onRevoke,
  });

  final String url;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onRevoke;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ecSquircleDecoration(
        radius: 10,
        color: BrandColors.soft,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.dossierLinkLabel,
                  style: _t(12, FontWeight.w600, BrandColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  url,
                  overflow: TextOverflow.ellipsis,
                  style: _t(11, FontWeight.w400, BrandColors.mut),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          EcTap(
            onTap: onCopy,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.copy_outlined,
                size: 16,
                color: BrandColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 8),
          EcTap(
            onTap: onShare,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.share_outlined,
                size: 16,
                color: BrandColors.ink,
              ),
            ),
          ),
          if (onRevoke != null) ...[
            const SizedBox(width: 8),
            EcTap(
              onTap: onRevoke,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 5,
                ),
                child: Text(
                  context.l10n.revoke,
                  style: _t(12, FontWeight.w600, BrandColors.rec),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EcDetailInfoRow extends StatelessWidget {
  const _EcDetailInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: BrandColors.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _t(14, FontWeight.w400, BrandColors.mut)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: _t(15, FontWeight.w500, BrandColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _EcDetailActionRow extends StatelessWidget {
  const _EcDetailActionRow({
    required this.icon,
    required this.label,
    this.subLabel,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final sub = subLabel;
    return EcTap(
      onTap: onTap,
      child: DecoratedBox(
        decoration: const BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: BrandColors.ink),
              const SizedBox(width: 14),
              Expanded(
                child: sub == null
                    ? Text(
                        label,
                        style: _t(16, FontWeight.w500, BrandColors.ink),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: _t(16, FontWeight.w500, BrandColors.ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sub,
                            style: _t(13, FontWeight.w400, BrandColors.mut),
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
                      style: _t(13, FontWeight.w400, BrandColors.mut),
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
