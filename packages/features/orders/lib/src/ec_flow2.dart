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
    this.shareUrl,
    this.storage,
    this.localPath,
    this.thumbUrl,
    this.type = EcEvidenceType.video,
    this.statusText,
    this.statusTone = EcStatusTone.waiting,
    this.statusIcon,
    this.durationSeconds,
    this.capturedAtMs,
    this.seal,
    this.timeDrift = false,
  });

  /// Carried through the timeline only so the detail sheet can show it — the
  /// row itself stays quiet about sealing. A clip that is still being stamped
  /// is a normal clip that happens to be a few seconds from ready, and putting
  /// a second badge next to the upload badge would read as a second problem.
  final EcSealLine? seal;
  final bool timeDrift;

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

  /// Trang tệp trên kho Drive của shop. Xem [EcVideoDetail.shareUrl].
  final String? shareUrl;

  /// Tên kho đang giữ clip. Xem [EcVideoDetail.storage].
  final String? storage;

  /// Đường dẫn bản tạm còn trên máy. Xem [EcVideoDetail.localPath].
  final String? localPath;

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
    this.shareUrl,
    this.storage,
    this.localPath,
    this.type = EcEvidenceType.video,
    this.capturedAtMs,
    this.tracking,
    this.durationSeconds,
    this.seal,
    this.timeDrift = false,
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

  /// Trang tệp trên Google Drive của shop, khi shop cắm kho Drive.
  ///
  /// Đây là thứ nút "Sao chép link" đưa ra khi có: người bán mở lên thấy clip
  /// nằm đúng trong kho Drive của chính mình, và gửi đi thì bên nhận thấy một
  /// link Drive quen thuộc chứ không phải một tên miền lạ.
  ///
  /// Kho S3 riêng cũng có chuỗi của nó: đối tượng trên chính kho của shop.
  /// Thiếu nó thì nút Sao chép link của shop S3 chép ra đúng dáng link của shop
  /// dùng kho hệ thống — vì `mediaUrl` của mọi kho riêng đều là đường vòng có
  /// vé qua máy chủ.
  ///
  /// KHÔNG dùng cho Phát / Tải về / Cắt đoạn: với Drive chuỗi này trỏ tới một
  /// TRANG WEB, không phải tới byte của clip — trình phát cắm vào chỉ nhận
  /// HTML. Ba đường đó vẫn đọc [mediaUrl]. `null` với kho hệ thống, và null khi
  /// kho S3 chặn mở công khai.
  final String? shareUrl;

  /// Tên kho đang GIỮ clip này, đã dịch sẵn — "Cloud ZenPack", "Google Drive",
  /// "Kho riêng (S3)".
  ///
  /// Hiện theo TỪNG clip chứ không theo shop: đổi kho không kéo clip cũ đi
  /// theo, nên một đơn có thể có clip nằm ở hai kho khác nhau, và người bán
  /// cần biết đúng clip nào đang nằm ở đâu.
  final String? storage;

  /// Bản clip còn nằm trên máy này, giữ lại trong đúng khoảng máy chủ còn đóng
  /// dấu. Cho người bán xem lại NGAY thay vì ngồi nhìn "đang đóng dấu".
  ///
  /// Đây là bản THÔ — không có giờ nung lên hình. Chỉ được dùng cho nút Phát.
  /// Sao chép link và Tải về phải đọc [mediaUrl]: một bản không dấu rò ra ngoài
  /// là người bán gửi cho sàn thứ trông y hệt bằng chứng nhưng không phải.
  final String? localPath;

  /// Evidence kind, driving the leading icon.
  final EcEvidenceType type;

  /// Sealing state, already turned into the one line to show. `null` hides the
  /// row entirely — used for photos, which never go through sealing.
  final EcSealLine? seal;

  /// The camera clock disagreed with the server, so the burned-in stamp also
  /// carries the server receipt time. Worth one line, because a viewer who
  /// spots two different clocks on the frame and no explanation reads it as
  /// tampering.
  final bool timeDrift;
}

/// One rendered line about sealing: what to say, and whether the clip is still
/// being worked on.
///
/// The screen takes a formatted line rather than the raw `seal_status` on
/// purpose — the five states map to five different sentences, and the choice
/// of sentence is a wording decision that belongs with the localized strings,
/// not in a widget.
class EcSealLine {
  const EcSealLine({
    required this.label,
    this.inProgress = false,
    this.anchor,
    this.signature,
    this.canVerify = false,
    this.mustSay = false,
  });

  final String label;

  /// Dòng "Chữ ký ZenPack · khoá k2" — danh tính của chữ ký, cho người bán nói
  /// với sàn "khoá k2" là bên kiểm biết lấy khoá công khai nào đối chiếu.
  /// `null` = chưa ký. Không mang tên thuật toán: thuật ngữ chỉ ở trang Kiểm
  /// chứng (design-spec/chu-ky-so-man-hinh.md).
  final String? signature;

  /// While true the API withholds the media URL by design: the stored file is
  /// still the raw upload, with no timestamp burned into it.
  final bool inProgress;

  /// One line about the independent proof: present, still being written, or
  /// absent. Kept separate from [label] because the two run on different
  /// clocks — the seal finishes in seconds, the public ledger takes hours — and
  /// folding them into one spinner makes a working feature read as a stuck one.
  final String? anchor;

  /// Whether this clip has a manifest a public page can verify. False for
  /// clips recorded before sealing existed — opening the page for one of those
  /// serves a 404, the fastest way to lose a seller's trust in the feature.
  final bool canVerify;

  /// Say this line even though the clip is no longer being worked on.
  ///
  /// [label] used to reach the screen ONLY while [inProgress] was true, so every
  /// terminal state that had something to say said nothing: a clip flagged
  /// `hash_mismatch` rendered as "Uploaded" with a check mark. Measured on the
  /// real sheet 2026-08-28 — the mismatch string existed in ten languages and
  /// had never once been drawn.
  ///
  /// Not simply "always show the line": for a clip that sealed cleanly the
  /// upload row with its check mark IS the right answer, and adding a second
  /// row saying the same thing twice is noise. This flag marks the states where
  /// silence is the wrong answer.
  final bool mustSay;
}

/// Order timeline — evidence videos for one order, grouped by day, with
/// upload status and an attach-photo action.
class EcOrderTimelineScreen extends StatefulWidget {
  const EcOrderTimelineScreen({
    this.huongDan,
    this.neoBangChung,
    required this.orderCode,
    this.subtitle,
    required this.days,
    this.pendingUploadCount = 0,
    this.onBack,
    this.onCopyCode,
    this.onRetryUpload,
    this.onVideoTap,
    this.onVideoMenu,
    this.onAttachPhoto,
    this.onAttachCode,
    this.extraCodes = const [],
    this.onCreateLink,
    super.key,
  });

  /// Thẻ hướng dẫn của màn này, đặt ngay dưới phần đầu màn.
  /// `null` = không hiện (đã xem, hoặc bên gọi không muốn).
  final Widget? huongDan;

  /// Khoá neo cho tour chỉ-vào-từng-nút, đặt quanh danh sách bằng chứng.
  ///
  /// Màn này không có nhãn chữ cố định nào để tour dò theo — phần đầu chỉ có
  /// mã vận đơn, thân màn là danh sách theo ngày. Neo bằng khoá thì đúng vùng
  /// tour đang nói tới, và không hỏng khi đổi chữ hay đổi thứ tiếng.
  final GlobalKey? neoBangChung;

  /// Shipment/tracking code shown in the header.
  final String orderCode;

  /// Dòng nhỏ dưới mã đơn — cửa hàng và sàn ("Nhà Lam · Shopee"). `null` =
  /// chỉ có mã.
  final String? subtitle;

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

  /// Quét thêm một mã (mã trả hàng, hoặc mã vận đơn thứ hai) để gắn vào ĐƠN NÀY.
  ///
  /// Không có đường này thì quay clip trả hàng sẽ đẻ ra một đơn thứ hai, và bằng
  /// chứng của cùng một kiện bị chẻ đôi — đúng lúc cần gộp lại để gửi sàn.
  final VoidCallback? onAttachCode;

  /// Các mã ĐÃ gắn thêm, ngoài mã chính ở tiêu đề. Rỗng thì không vẽ gì.
  final List<String> extraCodes;

  /// Gộp các bằng chứng đã tick thành một link hồ sơ chia sẻ được.
  final ValueChanged<List<EcTimelineVideo>>? onCreateLink;

  @override
  State<EcOrderTimelineScreen> createState() => _EcOrderTimelineScreenState();
}

class _EcOrderTimelineScreenState extends State<EcOrderTimelineScreen> {
  /// Đang ở chế độ tick chọn bằng chứng để gộp. Mặc định TẮT, nên chạm một
  /// hàng vẫn là mở chi tiết như thường.
  final bool _selecting = false;

  /// Id các bằng chứng đã tick. Dùng id thay vì object để tick không mất khi
  /// danh sách được nạp lại (xoá bằng chứng, kéo làm mới).
  final Set<String> _picked = <String>{};

  void _toggle(EcTimelineVideo video) {
    final id = video.id;
    if (id == null) return;
    setState(() {
      if (!_picked.remove(id)) _picked.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Dải cam với mã đơn trắng; thân màn là một tấm trắng bo góc đè lên mép
    // dưới dải (bộ mock 18/09). Hai hàng "thêm vào đơn" vẫn ghim đáy màn.
    return PenBannerPage(
      bannerHeight: 104,
      overlap: 26,
      header: Padding(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
        child: _EcOrderTimelineHeader(
          orderCode: widget.orderCode,
          subtitle: widget.subtitle,
          onBack: widget.onBack,
          onCopyCode: widget.onCopyCode,
        ),
      ),
      // Ghim đáy màn, NGOÀI vùng cuộn: đơn có năm chục clip thì nút nằm
      // trong danh sách đồng nghĩa phải cuộn hết mới bấm được. Đây là hành
      // động áp lên cả đơn, không thuộc về một hàng nào.
      //
      // Cả hai hàng ghim nằm TRONG vùng an toàn. Trước đó chúng nằm ngoài, nên
      // hàng dưới cùng bị đẩy xuống dưới thanh điều hướng của máy — không tràn
      // khung, không báo lỗi, chỉ là không ai nhìn thấy nó.
      //
      // Chỉ vẽ khi bên gọi thật sự có việc đính kèm. Hồ sơ khiếu nại dùng
      // chung màn này nhưng không đính ảnh — vẽ vô điều kiện là chào một nút
      // bấm vào không làm gì.
      bottom: SafeArea(
        top: false,
        child: PenBox(
          width: double.infinity,
          fill: PenColors.card,
          axis: PenAxis.column,
          cross: CrossAxisAlignment.stretch,
          children: [
            // Mã đã gắn thêm hiện NGAY DƯỚI dòng thời gian, không nhét vào
            // tiêu đề: tiêu đề chỉ có chỗ cho một mã, và mã thứ hai bị cắt
            // cụt ở đó thì người dùng không biết nó đã gắn được hay chưa.
            if (widget.extraCodes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                child: _EcExtraCodes(codes: widget.extraCodes),
              ),
            if (widget.onAttachCode != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                child: _EcAttachRow(
                  icon: LucideIcons.scanLine,
                  title: l10n.attachCodeToOrder,
                  subtitle: l10n.attachCodeToOrderHint,
                  onTap: widget.onAttachCode,
                ),
              ),
            if (widget.onAttachPhoto != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: _EcAttachRow(
                  icon: LucideIcons.plus,
                  title: l10n.attachPhotoToOrder,
                  subtitle: l10n.attachPhotoToOrderHint,
                  onTap: widget.onAttachPhoto,
                ),
              ),
          ],
        ),
      ),
      child: PenBox(
        width: double.infinity,
        fill: PenColors.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        axis: PenAxis.column,
        cross: CrossAxisAlignment.stretch,
        children: [
          ?widget.huongDan,
          Expanded(
            child: SingleChildScrollView(
              key: widget.neoBangChung,
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
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
                    if (d > 0) const SizedBox(height: 20),
                    // Ngày đậm, số mục nhỏ ngay dưới: đơn có ba ngày quay thì
                    // nhìn tiêu đề là biết ngày nào có mấy clip.
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PenText(
                            widget.days[d].date,
                            size: 20,
                            color: PenColors.ink,
                            weight: FontWeight.w800,
                          ),
                          PenText(
                            l10n.timelineEntryCount(
                              widget.days[d].videos.length,
                            ),
                            size: 13,
                            color: PenColors.mut,
                          ),
                        ],
                      ),
                    ),
                    for (var v = 0; v < widget.days[d].videos.length; v++) ...[
                      if (v > 0) const SizedBox(height: 10),
                      _EcTimelineVideoRow(
                        video: widget.days[d].videos[v],
                        selecting: _selecting,
                        picked: _picked.contains(widget.days[d].videos[v].id),
                        // Vạch dọc nối xuống mục sau; mục cuối ngày thì thôi.
                        last: v == widget.days[d].videos.length - 1,
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
                  if (widget.days.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    // Dấu chấm hết của dòng thời gian: người cuộn tới đây biết
                    // là đã xem hết, không phải danh sách còn đang tải.
                    _EcTimelineEnd(text: l10n.timelineEnd),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
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
    this.onTrim,
    this.onDelete,
    this.onVerify,
    this.onCopyVerifyLink,
    this.canDelete = true,
    this.showRecordedBy = true,
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

  /// Called when "Cắt đoạn ngắn để gửi" is tapped — tải bản đã nung về máy rồi
  /// mở màn cắt. Null thì hàng đó không hiện.
  final VoidCallback? onTrim;

  /// Called when "Xóa video" is tapped.
  final VoidCallback? onDelete;

  /// Called when "Xem trang kiểm chứng" is tapped — opens the public page a
  /// seller can hand to a marketplace.
  final VoidCallback? onVerify;

  /// Chép link trang kiểm chứng — thứ người bán dán vào Zalo/form khiếu nại
  /// của sàn. Tách khỏi [onVerify] (mở trang) vì gửi đi mới là việc chính.
  final VoidCallback? onCopyVerifyLink;

  /// Whether the current user may delete this clip. False for Nhân viên
  /// (staff) — hides the delete row.
  final bool canDelete;

  /// Hiện hàng "Người quay". Tắt khi sheet mở từ hồ sơ khiếu nại: hồ sơ đó đem
  /// đi làm việc với sàn, ai trong shop bấm nút quay không phải chuyện của bên
  /// nhận.
  final bool showRecordedBy;

  /// Viên trạng thái trên đầu sheet: đang niêm phong (xanh dương), niêm phong
  /// có chuyện phải nói (vàng), hoặc đã tải lên (xanh lá).
  (String, Color, IconData) _headline(AppLocalizations l10n) {
    final seal = video.seal;
    if (seal?.inProgress ?? false) {
      return (seal!.label, PenColors.progress, LucideIcons.lock);
    }
    if (seal?.mustSay ?? false) {
      return (seal!.label, PenColors.warning, LucideIcons.lockOpen);
    }
    return (video.uploadStatus, PenColors.success, LucideIcons.circleCheck);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (stateLabel, stateInk, stateIcon) = _headline(l10n);
    final sealing = video.seal?.inProgress ?? false;
    return PenSheet(
      onDismiss: onClose,
      // Design `Sheet`: padding [12, 20, 20, 20], over an ink `Dim`.
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      dim: const Color(0x99161616),
      children: [
        const SizedBox(height: 18),
        Row(
          children: [
            PenIconTile(
              video.type.icon,
              size: 48,
              iconSize: 24,
              radius: 12,
              fill: PenColors.soft,
              color: PenColors.ink,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  PenText(
                    l10n.videoDetailSheetTitle,
                    size: 24,
                    color: PenColors.ink,
                    weight: FontWeight.w800,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  // Tên loại và thời lượng là HAI ô, không nối chuỗi: tên
                  // loại co lại (cắt ba chấm) còn thời lượng luôn được vẽ
                  // trọn — mất con số đó nhìn như app quên ghi.
                  Row(
                    children: [
                      Flexible(
                        child: PenText(
                          video.title,
                          size: 14,
                          color: PenColors.mut,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PenText(
                        ' · ${video.duration}',
                        size: 14,
                        color: PenColors.mut,
                        softWrap: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Viên trạng thái ở dòng riêng: đứng cùng dòng với tên loại
                  // thì ở bề ngang điện thoại cả hai cùng bị cắt.
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PenPill(
                      label: stateLabel,
                      ink: stateInk,
                      icon: stateIcon,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Các dòng thông tin nằm trong MỘT thẻ trắng, mỗi dòng mở đầu bằng
        // một ô biểu tượng cam nhạt (bộ mock 18/09).
        PenCard(
          axis: PenAxis.column,
          stroke: PenColors.line,
          radius: 12,
          lifted: false,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          children: [
            _EcDetailInfoRow(
              label: l10n.detailRecordedTime,
              value: video.recordedAt,
            ),
            if (showRecordedBy) ...[
              const _EcDetailDivider(),
              _EcDetailInfoRow(
                label: l10n.detailRecordedBy,
                value: video.recordedBy,
              ),
            ],
            const _EcDetailDivider(),
            _EcDetailInfoRow(
              label: l10n.detailDevice,
              value: video.device,
            ),
            // Kho nào đang giữ CLIP NÀY. Đổi kho không kéo clip cũ đi theo,
            // nên một đơn có thể có clip nằm ở hai kho — hỏi "clip này nằm ở
            // đâu" mà phải mở màn Cài đặt kho ra đoán là câu trả lời sai chỗ.
            if (video.storage != null) ...[
              const _EcDetailDivider(),
              _EcDetailInfoRow(
                label: l10n.detailStorage,
                value: video.storage!,
              ),
            ],
            const _EcDetailDivider(),
            // MỘT hàng cho cả hai giai đoạn, không phải hai hàng chồng nhau.
            //
            // Tải lên xong chưa phải là xong: máy chủ còn nung dấu giờ lên
            // hình. Suốt quãng đó hàng này nói "đang niêm phong"; nung xong
            // nó mới đổi thành "Đã tải lên" kèm dấu tích. Nói "Đã tải lên" từ
            // sớm là mời người bán cầm một clip chưa có dấu đi khiếu nại.
            if (sealing)
              _EcDetailInfoRow(
                label: l10n.detailSeal,
                value: video.seal!.label,
                pill: true,
                pillIcon: LucideIcons.lock,
              )
            else ...[
              _EcDetailInfoRow(
                label: l10n.detailUploadStatus,
                value: video.uploadStatus,
                trailing: LucideIcons.check,
              ),
              // Trạng thái cuối cũng có thứ phải nói. Trước đây hàng này chỉ
              // hiện khi còn ĐANG chạy, nên một clip mang cờ hỏng hiện ra đúng
              // chữ "Đã tải lên" kèm dấu tích — người bán đọc thành mọi thứ
              // đều ổn.
              if (video.seal?.mustSay ?? false) ...[
                const _EcDetailDivider(),
                _EcDetailInfoRow(
                  label: l10n.detailSeal,
                  value: video.seal!.label,
                  pill: true,
                  pillIcon: LucideIcons.lock,
                ),
              ],
            ],
            // CHỮ KÝ SỐ — tầng "danh tính" giữa "Đã khoá" (kết quả) và trang
            // Kiểm chứng (kỹ thuật). Một hàng, đúng một câu: khoá nào đã ký.
            if (video.seal?.signature != null) ...[
              const _EcDetailDivider(),
              _EcDetailInfoRow(
                label: l10n.detailSignature,
                value: video.seal!.signature!,
              ),
            ],
            if (video.fileSize != null) ...[
              const _EcDetailDivider(),
              _EcDetailInfoRow(
                label: l10n.detailSize,
                value: video.fileSize!,
              ),
            ],
            if (video.seal?.anchor != null) ...[
              const _EcDetailDivider(),
              _EcDetailInfoRow(
                label: l10n.detailSealAnchor,
                value: video.seal!.anchor!,
              ),
            ],
          ],
        ),
        if (video.timeDrift) ...[
          const SizedBox(height: 10),
          PenText(
            l10n.sealTimeDrift,
            size: 13,
            color: PenColors.mut,
          ),
        ],
        const SizedBox(height: 14),
        // Mỗi hành động một thẻ rời (bộ mock 18/09), cách nhau 10.
        //
        // Đang niêm phong thì API cố tình không trả link, vì bản đang nằm ở
        // kho là bản THÔ — chưa có dấu giờ, chưa có mã vận đơn trên hình.
        // Cầm về đúng cái file đó rồi gửi cho sàn là hỏng, nên Sao chép
        // link và Tải về phải khoá.
        //
        // Nhưng XEM LẠI thì không cần bản đã đóng dấu. Máy này vẫn đang giữ
        // nguyên những byte vừa quay, nên nếu còn bản tạm thì mở nút Phát
        // ngay — người bán không phải đợi một giây nào cho việc họ thật sự
        // muốn làm. Không còn bản tạm mới rơi về dòng giải thích.
        _EcActionStack(
          children: [
            if (sealing) ...[
              if (video.localPath != null)
                _EcDetailActionRow(
                  icon: LucideIcons.play,
                  title: l10n.detailPlayVideo,
                  subtitle: l10n.playLocalCopyNote,
                  onTap: onPlay,
                ),
              _EcDetailActionRow(
                icon: LucideIcons.loader,
                title: l10n.sealWorking,
                subtitle: l10n.sealWorkingHint,
              ),
            ] else ...[
              _EcDetailActionRow(
                icon: LucideIcons.play,
                title: l10n.detailPlayVideo,
                onTap: onPlay,
              ),
              if (video.mediaUrl != null)
                _EcDetailActionRow(
                  icon: LucideIcons.copy,
                  title: l10n.detailCopyAssetLink,
                  onTap: onCopyLink,
                ),
              if (video.mediaUrl != null && onTrim != null)
                // Cắt chỉ mở khi máy chủ đã có bản phát được: thứ được cắt là
                // bản ĐÃ NUNG, nên đoạn gửi đi vẫn mang dấu giờ và mã vận đơn
                // trên hình. Cắt bản thô thì gửi cho sàn một đoạn không có gì
                // chứng minh nó quay lúc nào.
                _EcDetailActionRow(
                  icon: LucideIcons.scissors,
                  title: l10n.detailTrimVideo,
                  subtitle: l10n.detailTrimNote,
                  onTap: onTrim,
                ),
              _EcDetailActionRow(
                icon: LucideIcons.download,
                title: l10n.detailDownloadVideo,
                subtitle: l10n.detailDownloadNote,
                onTap: onDownload,
              ),
            ],
            // Nằm CÙNG nhóm với phát/tải chứ không nằm dưới cùng: đây là thứ
            // người bán gửi cho sàn khi có khiếu nại, tức là một hành động
            // chính, không phải một mục cài đặt. Chỉ hiện khi clip thật sự có
            // hồ sơ — mở trang cho clip cũ chỉ ra 404.
            if (video.seal?.canVerify ?? false) ...[
              _EcDetailActionRow(
                icon: LucideIcons.shieldCheck,
                title: l10n.sealVerifyOpen,
                subtitle: l10n.sealVerifyHint,
                onTap: onVerify,
              ),
              // Chép link đứng NGAY DƯỚI nút mở trang: hai việc của cùng một
              // link, và chép mới là việc người bán làm nhiều hơn — họ gửi
              // link cho sàn, không phải tự ngồi đọc trang kiểm chứng.
              if (onCopyVerifyLink != null)
                _EcDetailActionRow(
                  icon: LucideIcons.copy,
                  title: l10n.sealCopyVerifyLink,
                  onTap: onCopyVerifyLink,
                ),
            ],
            if (canDelete)
              _EcDetailActionRow(
                icon: LucideIcons.trash2,
                title: l10n.deleteVideoAction,
                subtitle: l10n.deleteVideoNote,
                danger: true,
                onTap: onDelete,
              ),
          ],
        ),
      ],
    );
  }
}

/// Các hành động nằm trong MỘT thẻ, ngăn nhau bằng vạch (18/09) — cách mọi app
/// thật xếp một nhóm hành động; mỗi hành động một thẻ rời là dáng của mock.
class _EcActionStack extends StatelessWidget {
  const _EcActionStack({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => PenCard(
    axis: PenAxis.column,
    stroke: PenColors.line,
    radius: 12,
    lifted: false,
    clip: true,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) const _EcDetailDivider(),
        children[i],
      ],
    ],
  );
}

/// The hairline the design puts between rows inside a sheet or card.
class _EcDetailDivider extends StatelessWidget {
  const _EcDetailDivider();

  @override
  Widget build(BuildContext context) => PenBox(
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
                            ? SizedBox(
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
                                      SizedBox(
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
    this.subtitle,
    this.onBack,
    this.onCopyCode,
  });

  final String orderCode;
  final String? subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onCopyCode;

  @override
  Widget build(BuildContext context) {
    // Header nằm trên dải cam nên chữ, mũi tên và nút chép đều trắng.
    return Row(
      children: [
        PenBackButton(onTap: onBack, color: PenColors.card),
        const SizedBox(width: 12),
        // Tiêu đề cũng quay lại: mũi tên 42pt là đích bấm nhỏ khi người dùng
        // đang cầm máy một tay, còn dải tiêu đề thì rộng gần hết bề ngang.
        Expanded(
          child: EcTap(
            onTap: onBack,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                PenText(
                  orderCode,
                  size: 24,
                  color: PenColors.card,
                  weight: FontWeight.w800,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  PenText(
                    subtitle!,
                    size: 13,
                    color: PenColors.card.withValues(alpha: 0.82),
                    weight: FontWeight.w500,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        EcTap(
          onTap: onCopyCode,
          child: Icon(LucideIcons.copy, size: 24, color: PenColors.card),
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
        Icon(LucideIcons.cloud, size: 22, color: PenColors.ink),
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

class _EcTimelineVideoRow extends StatelessWidget {
  const _EcTimelineVideoRow({
    required this.video,
    this.onPlay,
    this.onMenu,
    this.selecting = false,
    this.picked = false,
    this.last = false,
  });

  final EcTimelineVideo video;
  final VoidCallback? onPlay;
  final VoidCallback? onMenu;

  /// Đang ở chế độ chọn để gộp: hàng hiện ô tick thay cho nút ⋮, và chạm vào
  /// hàng là tick chứ không mở chi tiết.
  final bool selecting;
  final bool picked;

  /// Mục cuối của ngày: vạch dọc dưới chấm không kéo tiếp xuống.
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 48,
            child: Padding(
              padding: const EdgeInsets.only(top: 22),
              child: PenText(
                video.time,
                size: 15,
                color: PenColors.ink,
                weight: FontWeight.w600,
              ),
            ),
          ),
          // Chấm cam trên một vạch dọc nhạt — trục thời gian của ngày.
          SizedBox(
            width: 24,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!last)
                  Positioned(
                    top: 30,
                    bottom: -10,
                    child: PenBox(width: 2, fill: PenColors.line),
                  ),
                Positioned(
                  top: 22,
                  child: PenEllipse(
                    width: 14,
                    height: 14,
                    color: PenColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            // The whole card opens the evidence detail — the design's play
            // triangle was a second, smaller target for the same destination.
            child: PenCard(
              stroke: PenColors.line,
              radius: 12,
              lifted: false,
              gap: 12,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
                        size: 16,
                        color: PenColors.ink,
                        weight: FontWeight.w700,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (video.statusText != null) ...[
                        const SizedBox(height: 6),
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
                    child: Icon(
                      LucideIcons.ellipsisVertical,
                      size: 18,
                      color: PenColors.ink,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
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

  static const _size = 64.0;
  static const _radius = 10.0;

  final EcTimelineVideo video;

  @override
  Widget build(BuildContext context) {
    final url = video.thumbUrl;
    final picture = url == null
        ? _icon()
        : ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: Image.network(
              url,
              width: _size,
              height: _size,
              // A poster is 16:9 and the slot is square — crop rather than
              // letterbox, so the row keeps its rhythm down the list.
              fit: BoxFit.cover,
              // Bounded so a large source decodes small: the whole point of
              // the poster is that a timeline costs almost no memory or
              // bandwidth.
              cacheWidth: (_size * MediaQuery.devicePixelRatioOf(context))
                  .round(),
              errorBuilder: (context, error, stackTrace) => _icon(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : _icon(),
            ),
          );
    final seconds = video.durationSeconds;
    if (seconds == null) return picture;
    // Thời lượng đóng ở góc dưới ảnh, như trên mọi trình phát video: người
    // bán quét danh sách là biết clip nào 6 giây, clip nào 3 phút.
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        children: [
          picture,
          Positioned(
            left: 4,
            bottom: 4,
            child: PenBox(
              fill: const Color(0xCC1B1412),
              radius: 6,
              axis: PenAxis.row,
              gap: 3,
              hugMain: true,
              cross: CrossAxisAlignment.center,
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
              children: [
                const Icon(
                  LucideIcons.video,
                  size: 10,
                  color: Color(0xFFFFFFFF),
                ),
                PenText(
                  _clock(seconds),
                  size: 10,
                  color: const Color(0xFFFFFFFF),
                  weight: FontWeight.w600,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// `mm:ss` — clip không quá vài phút nên không cần giờ.
  static String _clock(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _icon() => PenBox(
    width: _size,
    height: _size,
    fill: PenColors.soft,
    radius: _radius,
    axis: PenAxis.row,
    main: MainAxisAlignment.center,
    cross: CrossAxisAlignment.center,
    children: [Icon(video.type.icon, size: 26, color: PenColors.mut)],
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

  /// Đúng 5 tông khung F2-02 vẽ; nền là chính màu chữ pha 12% (bộ mock
  /// 18/09) thay cho xám — viên xanh đứng trên nền xanh nhạt, viên đỏ trên nền
  /// đỏ nhạt, nhìn màu là đọc được trạng thái trước cả khi đọc chữ.
  (Color, Color) get _palette {
    final ink = switch (tone) {
      EcStatusTone.done => PenColors.success,
      EcStatusTone.uploading => PenColors.progress,
      EcStatusTone.waiting => PenColors.mut,
      EcStatusTone.quota => PenColors.warning,
      EcStatusTone.error => PenColors.danger,
    };
    return (ink.withValues(alpha: 0.12), ink);
  }
}

/// Một hàng "thêm gì đó vào đơn" ghim đáy màn: ô biểu tượng, tiêu đề cam,
/// dòng giải thích, mũi tên. Hai hành động (quét thêm mã, đính kèm ảnh) cùng
/// một khuôn, nên trông khác nhau là bắt người dùng học hai lần cùng một thứ.
class _EcAttachRow extends StatelessWidget {
  const _EcAttachRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PenCard(
      stroke: PenColors.line,
      radius: 12,
      lifted: false,
      gap: 14,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      onTap: onTap,
      children: [
        PenIconTile(
          icon,
          size: 40,
          iconSize: 21,
          radius: 10,
          fill: PenColors.selected,
          color: PenColors.primary,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              PenText(
                title,
                size: 16,
                color: PenColors.ink,
                weight: FontWeight.w600,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              PenText(
                subtitle,
                size: 13,
                color: PenColors.mut,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(LucideIcons.chevronRight, size: 20, color: PenColors.mut),
      ],
    );
  }
}

/// Các mã đã gắn thêm vào đơn, ngoài mã chính.
class _EcExtraCodes extends StatelessWidget {
  const _EcExtraCodes({required this.codes});

  final List<String> codes;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      width: double.infinity,
      fill: PenColors.card,
      stroke: PenColors.line,
      radius: 14,
      axis: PenAxis.column,
      gap: 6,
      cross: CrossAxisAlignment.start,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      children: [
        PenText(
          context.l10n.attachedCodes,
          size: 12,
          color: PenColors.mut,
          weight: FontWeight.w600,
        ),
        for (final code in codes) PenText(code, size: 15, color: PenColors.ink),
      ],
    );
  }
}

/// Viên "Không có thêm hoạt động" giữa hai vạch mờ — dấu chấm hết của dòng
/// thời gian.
class _EcTimelineEnd extends StatelessWidget {
  const _EcTimelineEnd({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: PenBox(height: 1, fill: PenColors.line)),
        const SizedBox(width: 10),
        // Viên co được: màn hẹp hay câu dịch dài thì viên nhường chỗ, hai
        // vạch bên chỉ còn là gợi ý.
        Flexible(
          flex: 6,
          child: PenPill(
            label: text,
            ink: PenColors.mut,
            fill: PenColors.soft,
            icon: LucideIcons.clock,
            size: 13,
            weight: FontWeight.w500,
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 14),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: PenBox(height: 1, fill: PenColors.line)),
      ],
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
          Icon(
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
    this.pill = false,
    this.pillIcon,
  });

  final String label;
  final String value;

  /// Optional glyph after the value, e.g. the upload-complete tick.
  final IconData? trailing;

  /// Giá trị vẽ thành viên xám (niêm phong) thay vì chữ trần.
  final bool pill;
  final IconData? pillIcon;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      width: double.infinity,
      axis: PenAxis.row,
      gap: 12,
      cross: CrossAxisAlignment.center,
      padding: const EdgeInsets.symmetric(vertical: 13),
      children: [
        // Nhãn trái, giá trị phải, không icon — hàng thông tin kiểu "Payment
        // Info" của Shopee trên Mobbin (18/09).
        PenText(label, size: 14.5, color: PenColors.mut, softWrap: false),
        // The design's spacer is the flexible one and the value hugs its text,
        // so the value gets all the leftover room and only ellipsises when it
        // genuinely cannot fit.
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: pill
                ? PenPill(
                    label: value,
                    ink: PenColors.ink,
                    fill: PenColors.soft,
                    icon: pillIcon,
                    size: 13,
                    weight: FontWeight.w500,
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 11,
                    ),
                  )
                : PenText(
                    value,
                    size: 15,
                    color: PenColors.ink,
                    weight: FontWeight.w600,
                    align: TextAlign.right,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ),
        if (trailing != null)
          Icon(trailing, size: 19, color: PenColors.success),
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
    // Hàng trong thẻ chung: icon mực trần, tiêu đề đậm, dòng phụ nhạt, mũi
    // tên — hàng xoá chỉ đổi màu chữ và icon sang đỏ (18/09).
    return EcTap(
      onTap: onTap,
      child: PenBox(
        width: double.infinity,
        axis: PenAxis.row,
        gap: 14,
        cross: CrossAxisAlignment.center,
        padding: const EdgeInsets.symmetric(vertical: 13),
        children: [
          PenIconTile(
            icon,
            size: 36,
            iconSize: 20,
            radius: 9,
            fill: danger
                ? PenColors.danger.withValues(alpha: 0.1)
                : PenColors.soft,
            color: ink,
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
                    size: 12.5,
                    color: PenColors.mut,
                    lineHeight: 1.4,
                  ),
                ],
              ],
            ),
          ),
          // Mũi tên chỉ dành cho hàng bấm được. "Đang đóng dấu thời gian…" là
          // một dòng trạng thái, chạm vào không đi đâu cả — vẽ mũi tên ở đó là
          // mời người dùng bấm vào một chỗ không phản hồi.
          if (onTap != null)
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
