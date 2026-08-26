/// EvidenceCam Flow 3 (Ghi hình / recording) screens, built pixel-perfect
/// from `specs/projects/evidencecam/design-spec/pencil-new.pen`.
///
/// These are presentational (data-in, callbacks-out) — no real camera, BLoC
/// or backend wiring. The camera screens render a full-bleed black preview
/// placeholder with floating controls overlaid on top, matching the design's
/// absolutely-positioned `CameraArea` + `Header` + `CamRail` + `BottomOverlay`
/// composition. `UploadQueue` is a regular white list screen; `ManualEntry`,
/// `NoMatch` and `TypeSheet` are modal overlays shown on top of the (black)
/// camera preview.
library;

import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoPageScaffold, CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

// Shared text style helper (Inter is inherited from AppTheme's textTheme).
TextStyle _t(double size, FontWeight weight, Color color) =>
    TextStyle(fontSize: size, fontWeight: weight, color: color, height: 1.3);

// --- WaitBill2 --------------------------------------------------------

/// Idle recording screen — camera waiting for a bill to be framed.
class EcWaitBill2Screen extends StatelessWidget {
  const EcWaitBill2Screen({
    this.queueCount = 3,
    this.typeLabel = 'Đóng hàng',
    this.resolutionLabel = '720p',
    this.preview,
    this.onBack,
    this.onQueueTap,
    this.onPickType,
    this.onSettings,
    this.onFlipCamera,
    this.onManualEntry,
    this.onResolution,
    this.onNavOrders,
    this.onNavClaims,
    super.key,
  });

  final int queueCount;
  final String typeLabel;
  final String resolutionLabel;

  /// Live camera preview rendered full-bleed behind the overlay; a black
  /// placeholder is shown when `null` (design mock / no camera).
  final Widget? preview;
  final VoidCallback? onBack;
  final VoidCallback? onQueueTap;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onResolution;
  final VoidCallback? onNavOrders;
  final VoidCallback? onNavClaims;

  @override
  Widget build(BuildContext context) {
    return _CamScaffold(
      queueCount: queueCount,
      typeLabel: typeLabel,
      resolutionLabel: resolutionLabel,
      preview: preview,
      onBack: onBack,
      onQueueTap: onQueueTap,
      onPickType: onPickType,
      onSettings: onSettings,
      onFlipCamera: onFlipCamera,
      onManualEntry: onManualEntry,
      onResolution: onResolution,
      showScanFrame: true,
      // Matches _FramingCorners' frame fractions so the hint reads inside the
      // frame and the manual-entry pill sits just below it, never overlapping.
      centerArea: LayoutBuilder(
        builder: (context, constraints) {
          final frameTop = constraints.maxHeight * 0.253;
          final frameBottom = constraints.maxHeight * (1 - 0.313);
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: frameTop,
                height: frameBottom - frameTop,
                child: Center(
                  child: SizedBox(
                    width: 244,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PenText(
                          context.l10n.captureFramePrompt,
                          size: 16,
                          color: PenColors.card,
                          weight: FontWeight.w700,
                          align: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        PenText(
                          context.l10n.captureCameraDownHint,
                          size: 13,
                          color: const Color(0x99FFFFFF),
                          align: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: frameBottom + 24,
                child: Center(
                  // Tooltip doubles as the accessible name for the pill — it
                  // is the only way into manual entry now that the rail is
                  // gone.
                  child: Tooltip(
                    message: context.l10n.tooltipEnterTracking,
                    child: EcTap(
                      onTap: onManualEntry,
                      child: PenBox(
                        width: 214,
                        height: 42,
                        fill: const Color(0xCC050505),
                        stroke: const Color(0x1AFFFFFF),
                        radius: 999,
                        axis: PenAxis.row,
                        gap: 9,
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.keyboard,
                            size: 18,
                            color: PenColors.card,
                          ),
                          Flexible(
                            child: PenText(
                              context.l10n.tooltipEnterTracking,
                              size: 14,
                              color: PenColors.card,
                              weight: FontWeight.w700,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            LucideIcons.chevronRight,
                            size: 16,
                            color: Color(0x99FFFFFF),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- Recording2 ---------------------------------------------------------

/// Active recording screen — mã vận đơn badge and REC dot. The header's
/// live clock already covers "what time is it", so this doesn't duplicate
/// it with an elapsed-time counter.
class EcRecording2Screen extends StatelessWidget {
  const EcRecording2Screen({
    this.queueCount = 3,
    required this.code,
    this.elapsed = '00:00',
    this.typeLabel = 'Đóng hàng',
    this.resolutionLabel = '720p',
    this.preview,
    this.onBack,
    this.onQueueTap,
    this.onPickType,
    this.onSettings,
    this.onFlipCamera,
    this.onManualEntry,
    this.onResolution,
    this.onNavOrders,
    this.onNavClaims,
    this.onStop,
    super.key,
  });

  final int queueCount;
  final String code;

  /// Running clip length shown next to REC, `mm:ss`.
  final String elapsed;
  final String typeLabel;
  final String resolutionLabel;

  /// Live camera preview rendered full-bleed behind the overlay; a black
  /// placeholder is shown when `null` (design mock / no camera).
  final Widget? preview;
  final VoidCallback? onBack;
  final VoidCallback? onQueueTap;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onResolution;
  final VoidCallback? onNavOrders;
  final VoidCallback? onNavClaims;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return _CamScaffold(
      queueCount: queueCount,
      onQueueTap: onQueueTap,
      typeLabel: typeLabel,
      resolutionLabel: resolutionLabel,
      preview: preview,
      onBack: onBack,
      onPickType: onPickType,
      onSettings: onSettings,
      onFlipCamera: onFlipCamera,
      onManualEntry: onManualEntry,
      onResolution: onResolution,
      showStopButton: true,
      onStop: onStop,
      stampCode: code,
      // Chỉ còn pill REC dưới header: mã vận đơn đã nằm trong khối mốc thời
      // gian góc phải, để giữa khung ngắm hai lần là che mất cảnh đang quay.
      centerArea: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 76),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [_RecRow(elapsed: elapsed)],
          ),
        ),
      ),
    );
  }
}

// --- CutoverB ---------------------------------------------------------

/// Order-cutover transition screen — order A just closed, order B started.
class EcCutoverBScreen extends StatelessWidget {
  const EcCutoverBScreen({
    this.queueCount = 3,
    required this.closedCode,
    required this.newCode,
    this.newMeta = 'Đóng hàng • 10:28',
    this.typeLabel = 'Đóng hàng',
    this.resolutionLabel = '720p',
    this.preview,
    this.onBack,
    this.onQueueTap,
    this.onPickType,
    this.onSettings,
    this.onFlipCamera,
    this.onManualEntry,
    this.onStop,
    super.key,
  });

  final int queueCount;

  /// Mã vừa được chốt — khung F3-04 để nó ở pill trên cùng, đúng chỗ mã đang
  /// quay vẫn đứng ở màn REC, nên mắt người quay không phải đi tìm.
  final String closedCode;

  /// Giây còn lại trước khi phiên kế tiếp bắt đầu, và tổng để vẽ vòng tiến độ.

  final String newCode;

  /// Dòng phụ của thẻ "Đơn tiếp theo": loại video • giờ, ví dụ `Đóng hàng • 10:28`.
  final String newMeta;
  final String typeLabel;
  final String resolutionLabel;

  /// The live camera texture — recording keeps running underneath this
  /// confirmation moment, so it must stay visible, not go black.
  final Widget? preview;
  final VoidCallback? onBack;
  final VoidCallback? onQueueTap;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return _CamScaffold(
      queueCount: queueCount,
      onQueueTap: onQueueTap,
      typeLabel: typeLabel,
      resolutionLabel: resolutionLabel,
      preview: preview,
      onBack: onBack,
      onPickType: onPickType,
      onSettings: onSettings,
      onFlipCamera: onFlipCamera,
      onManualEntry: onManualEntry,
      showStopButton: true,
      onStop: onStop,
      // Khoảng cách lấy thẳng từ toạ độ khung F3-04 (CodePill y=76, SavedPill
      // y=128, Countdown y=286, phụ đề y=381, NextCard y=426) chuyển thành hiệu
      // số, để khung cao hơn 844px không dồn hết xuống đáy.
      centerArea: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 76),
              _CamCodeBadge(code: closedCode),
              const SizedBox(height: 12),
              _SavedPill(text: context.l10n.cutoverSavedVideo),
              // Không còn vòng đếm 3-2-1: cutover là chuyện tự động, người quay
              // không phải canh tay theo con số nào — tiếng tút đã báo máy nhận
              // mã mới, nên màn này chỉ cần nói rõ đơn vừa lưu và đơn kế tiếp.
              const SizedBox(height: 128),
              Text(
                context.l10n.cutoverPreparingNext,
                style: _t(16, FontWeight.w400, BrandColors.card),
              ),
              const SizedBox(height: 26),
              _NextOrderCard(
                label: context.l10n.cutoverNextOrder,
                code: newCode,
                meta: newMeta,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill "Đã lưu video" — xác nhận clip vừa đóng đã nằm trong hàng đợi. Đây là
/// điều duy nhất người quay cần biết trước khi tay họ chạm vào gói hàng kế tiếp.
class _SavedPill extends StatelessWidget {
  const _SavedPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => PenBox(
    fill: const Color(0xCC161616),
    stroke: const Color(0xFF636363),
    strokeWidth: 1,
    radius: 999,
    axis: PenAxis.row,
    gap: 9,
    cross: CrossAxisAlignment.center,
    // Pill ôm sát chữ như khung design; thiếu cờ này nó kéo hết bề ngang cột.
    hugMain: true,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
    children: [
      const Icon(LucideIcons.check, size: 18, color: Color(0xFF67BB75)),
      Flexible(
        child: PenText(
          text,
          size: 16,
          weight: FontWeight.w700,
          color: PenColors.card,
        ),
      ),
    ],
  );
}

/// Vòng đếm ngược trước khi phiên kế tiếp bắt đầu.
///
class _CountdownRing extends StatelessWidget {
  const _CountdownRing({required this.seconds, required this.totalSeconds});

  final int seconds;
  final int totalSeconds;

  static const _fullSweep = -250.0;

  @override
  Widget build(BuildContext context) {
    final ratio = totalSeconds <= 0
        ? 1.0
        : (seconds.clamp(0, totalSeconds)) / totalSeconds;
    return SizedBox(
      width: 86,
      height: 86,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const PenEllipse(
            width: 86,
            height: 86,
            color: Color(0x80636363),
            ring: 0.93,
          ),
          PenEllipse(
            width: 86,
            height: 86,
            color: PenColors.ink,
            ring: 0.93,
            sweep: _fullSweep * ratio,
          ),
          const PenEllipse(width: 74, height: 74, color: Color(0x80161616)),
          PenText(
            '$seconds',
            size: 36,
            weight: FontWeight.w800,
            color: PenColors.card,
          ),
        ],
      ),
    );
  }
}

/// Thẻ "Đơn tiếp theo" — mã của đơn sắp quay, viền xanh như khung design.
class _NextOrderCard extends StatelessWidget {
  const _NextOrderCard({
    required this.label,
    required this.code,
    required this.meta,
  });

  final String label;
  final String code;
  final String meta;

  @override
  Widget build(BuildContext context) => PenBox(
    width: double.infinity,
    fill: const Color(0xCC161616),
    stroke: const Color(0xFF1F9047),
    strokeWidth: 1,
    radius: 14,
    axis: PenAxis.row,
    gap: 14,
    cross: CrossAxisAlignment.center,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    children: [
      const PenBox(
        width: 46,
        height: 46,
        fill: Color(0x99161616),
        stroke: Color(0xFFE4E4E4),
        strokeWidth: 1,
        radius: 999,
        axis: PenAxis.row,
        main: MainAxisAlignment.center,
        cross: CrossAxisAlignment.center,
        children: [
          Icon(LucideIcons.package, size: 23, color: PenColors.card),
        ],
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            PenText(label, size: 12, color: const Color(0x99FFFFFF)),
            PenText(
              code,
              size: 20,
              weight: FontWeight.w700,
              color: PenColors.card,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
            PenText(meta, size: 12, color: const Color(0x80FFFFFF)),
          ],
        ),
      ),
    ],
  );
}

// --- NearLimit ---------------------------------------------------------

/// Recording screen showing the near-cap warning banner. The cap itself is
/// the shop's setting (FR-18), so the caller passes the text.
class EcNearLimitScreen extends StatelessWidget {
  const EcNearLimitScreen({
    this.queueCount = 3,
    this.warningText = 'Sắp chạm trần 2 phút — video sẽ tự chốt',
    required this.code,
    this.duration = '14:12',
    this.countdownText = 'Tự chốt sau 00:48',
    this.typeLabel = 'Đóng hàng',
    this.resolutionLabel = '720p',
    this.preview,
    this.onBack,
    this.onQueueTap,
    this.onPickType,
    this.onSettings,
    this.onFlipCamera,
    this.onManualEntry,
    this.onResolution,
    this.onNavOrders,
    this.onNavClaims,
    this.onStop,
    super.key,
  });

  final int queueCount;
  final String warningText;
  final String code;
  final String duration;

  /// Time left before the clip auto-closes, shown under the elapsed counter so
  /// the seller can see exactly how long they have.
  final String countdownText;
  final String typeLabel;
  final String resolutionLabel;
  final Widget? preview;
  final VoidCallback? onBack;
  final VoidCallback? onQueueTap;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onResolution;
  final VoidCallback? onNavOrders;
  final VoidCallback? onNavClaims;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return _CamScaffold(
      queueCount: queueCount,
      onQueueTap: onQueueTap,
      typeLabel: typeLabel,
      resolutionLabel: resolutionLabel,
      preview: preview,
      onBack: onBack,
      onPickType: onPickType,
      onSettings: onSettings,
      onFlipCamera: onFlipCamera,
      onManualEntry: onManualEntry,
      onResolution: onResolution,
      showStopButton: true,
      onStop: onStop,
      centerArea: Padding(
        padding: const EdgeInsets.fromLTRB(12, 100, 12, 0),
        child: Column(
          children: [
            _WarnBanner(text: warningText),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CamCodeBadge(code: code),
                    const SizedBox(height: 10),
                    Text(
                      duration,
                      style: _t(30, FontWeight.w600, BrandColors.ink),
                    ),
                    const SizedBox(height: 8),
                    _CountdownPill(text: countdownText),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The "tự chốt sau mm:ss" countdown shown under the elapsed counter once the
/// clip enters its final minute.
class _CountdownPill extends StatelessWidget {
  const _CountdownPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      fill: BrandColors.dark,
      radius: 999,
      axis: PenAxis.row,
      gap: 6,
      cross: CrossAxisAlignment.center,
      hugMain: true,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      children: [
        const Icon(Icons.timer_outlined, size: 14, color: Colors.white),
        PenText(
          text,
          size: 13,
          color: Colors.white,
          weight: FontWeight.w700,
          softWrap: false,
        ),
      ],
    );
  }
}

class _WarnBanner extends StatelessWidget {
  const _WarnBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: BrandColors.dark,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text, style: _t(12, FontWeight.w500, Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ReturnRec ---------------------------------------------------------

/// Recording screen for a return ("hoàn") video, auto-linked to the
/// original order.
class EcReturnRecScreen extends StatelessWidget {
  const EcReturnRecScreen({
    this.queueCount = 3,
    required this.code,
    this.duration = '00:32',
    this.linkNote = 'Tự liên kết về hồ sơ mã vận đơn gốc',
    this.typeLabel = 'Trả hàng',
    this.resolutionLabel = '720p',
    this.preview,
    this.onBack,
    this.onQueueTap,
    this.onPickType,
    this.onSettings,
    this.onFlipCamera,
    this.onManualEntry,
    this.onStop,
    super.key,
  });

  final int queueCount;
  final String code;
  final String duration;
  final String linkNote;
  final String typeLabel;
  final String resolutionLabel;
  final Widget? preview;
  final VoidCallback? onBack;
  final VoidCallback? onQueueTap;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return _CamScaffold(
      queueCount: queueCount,
      onQueueTap: onQueueTap,
      typeLabel: typeLabel,
      resolutionLabel: resolutionLabel,
      preview: preview,
      onBack: onBack,
      onPickType: onPickType,
      onSettings: onSettings,
      onFlipCamera: onFlipCamera,
      onManualEntry: onManualEntry,
      showStopButton: true,
      onStop: onStop,
      stampCode: code,
      // Khung F3-07 dựng giống hệt F3-03: pill REC nằm ngay dưới header, mã ở
      // khối mốc thời gian góc phải. Quay trả hàng khác quay đóng gói ở chỗ có
      // mã và loại video, không phải ở cách bố trí — nên dùng chung đúng khối
      // này thay vì dựng riêng.
      centerArea: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 76),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RecRow(elapsed: duration),
              // ⚠️ Lệch design có chủ ý: khung F3-07 không có dòng này. Giữ vì
              // nó là thứ duy nhất nói cho nhân viên biết clip hoàn sẽ được nối
              // về hồ sơ của mã gốc — bỏ đi là mất thông tin, không phải mất
              // trang trí.
              const SizedBox(height: 10),
              Text(linkNote, style: _t(12, FontWeight.w400, BrandColors.mut)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- shared camera-screen chrome ---------------------------------------

/// Full-bleed black preview + floating chrome shared by every Flow 3
/// recording screen (header, right-hand rail, type chip and the optional stop
/// button).
class _CamScaffold extends StatelessWidget {
  const _CamScaffold({
    required this.queueCount,
    required this.typeLabel,
    required this.resolutionLabel,
    required this.centerArea,
    this.preview,
    this.onBack,
    this.onQueueTap,
    this.onPickType,
    this.onSettings,
    this.onFlipCamera,
    this.onManualEntry,
    this.onResolution,
    this.showScanFrame = false,
    this.showStopButton = false,
    this.onStop,
    this.stampCode,
  });

  final int queueCount;
  final String typeLabel;
  final String resolutionLabel;
  final Widget centerArea;

  /// Mã vận đơn đang quay; `null` ở màn chờ, lúc đó header không có khối mốc.
  final String? stampCode;

  final Widget? preview;
  final VoidCallback? onBack;

  /// Chạm chip mây ở header → mở màn trạng thái tải lên.
  final VoidCallback? onQueueTap;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onResolution;

  /// Framing brackets + sweeping scan line. Only the idle screen shows them —
  /// once recording starts the frame would just crop the operator's view.
  final bool showScanFrame;
  final bool showStopButton;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: PenColors.ink,
      child: Stack(
        children: [
          Positioned.fill(
            child: preview ?? const ColoredBox(color: PenColors.ink),
          ),
          // The design darkens the whole viewfinder so white chrome stays
          // legible over any scene.
          const Positioned.fill(
            child: IgnorePointer(child: ColoredBox(color: Color(0x73161616))),
          ),
          if (showScanFrame) const Positioned.fill(child: _FramingCorners()),
          Positioned.fill(child: centerArea),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _CamHeader(
                queueCount: queueCount,
                stampCode: stampCode,
                onBack: onBack,
                onQueueTap: onQueueTap,
              ),
            ),
          ),
          // Shutter floats clear of the footer panel.
          if (showStopButton)
            Positioned(
              left: 0,
              right: 0,
              bottom: 152,
              child: Center(child: _StopButton(onTap: onStop)),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _CamFooter(
              typeLabel: typeLabel,
              resolutionLabel: resolutionLabel,
              onPickType: onPickType,
              onSettings: onSettings,
              onResolution: onResolution,
              onFlipCamera: onFlipCamera,
            ),
          ),
        ],
      ),
    );
  }
}

/// The four white framing brackets the design draws around the bill area,
/// plus the line that sweeps the window while the bill/QR scanner is live —
/// which on every Flow 3 camera screen it is, recording included (the scanner
/// keeps watching for the next bill so it can cut over).
class _FramingCorners extends StatefulWidget {
  const _FramingCorners();

  @override
  State<_FramingCorners> createState() => _FramingCornersState();
}

class _FramingCornersState extends State<_FramingCorners>
    with SingleTickerProviderStateMixin {
  static const _topLeft = 'M2 34l0-26q0-6 6-6l26 0';
  static const _topRight = 'M0 2l26 0q6 0 6 6l0 26';
  static const _bottomLeft = 'M2 0l0 26q0 6 6 6l26 0';
  static const _bottomRight = 'M0 32l26 0q6 0 6-6l0-26';

  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  /// Giữ riêng để còn `dispose` được.
  ///
  /// `CurvedAnimation` gắn listener lên parent của nó, nên nó là một tài nguyên
  /// phải trả chứ không phải một giá trị thuần. Bản trước dựng nó ẩn danh ngay
  /// trong biểu thức `.drive(...)` và chỉ `dispose` mỗi `_sweep` — rò đúng một
  /// đối tượng cho mỗi lần màn quay được dựng.
  ///
  /// Nằm im lâu vì không test nào tới được trạng thái ĐANG QUAY: chúng dừng ở
  /// bước quét do bơm thiếu thời gian cho hai lần chờ âm thanh. Sửa chỗ bơm là
  /// leak_tracker bắt ra ngay.
  late final CurvedAnimation _sweepCurve = CurvedAnimation(
    parent: _sweep,
    curve: Curves.easeInOut,
  );
  late final Animation<Alignment> _sweepAlignment = _sweepCurve.drive(
    AlignmentTween(begin: Alignment.topCenter, end: Alignment.bottomCenter),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduce Motion parks the line in the middle instead of sweeping.
    if (MediaQuery.disableAnimationsOf(context)) {
      _sweep
        ..stop()
        ..value = 0.5;
    } else if (!_sweep.isAnimating) {
      _sweep.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _sweepCurve.dispose();
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The design frames a 222x300 window centred a little above middle;
          // keep that proportion instead of the artboard's absolute offsets.
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          const frameW = 222.0;
          final left = (width - frameW) / 2;
          final top = height * 0.253;
          final bottom = height * 0.313;
          return Stack(
            children: [
              Positioned(
                left: left,
                right: left,
                top: top,
                bottom: bottom,
                child: ClipRect(
                  child: AlignTransition(
                    alignment: _sweepAlignment,
                    child: const _ScanLine(),
                  ),
                ),
              ),
              Positioned(left: left, top: top, child: const _Corner(_topLeft)),
              Positioned(
                right: left,
                top: top,
                child: const _Corner(_topRight),
              ),
              Positioned(
                left: left,
                bottom: bottom,
                child: const _Corner(_bottomLeft),
              ),
              Positioned(
                right: left,
                bottom: bottom,
                child: const _Corner(_bottomRight),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The sweeping scan line: a hairline that fades out at both frame edges.
class _ScanLine extends StatelessWidget {
  const _ScanLine();

  @override
  Widget build(BuildContext context) => Container(
    height: 2,
    decoration: BoxDecoration(
      // `--chart-2`, the design system's lighter green: the only token that
      // stays legible against an arbitrary (and darkened) camera scene.
      gradient: LinearGradient(
        colors: [
          PenColors.success.withValues(alpha: 0),
          PenColors.success,
          PenColors.success.withValues(alpha: 0),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: PenColors.success.withValues(alpha: 0.35),
          blurRadius: 8,
        ),
      ],
    ),
  );
}

class _Corner extends StatelessWidget {
  const _Corner(this.geometry);

  final String geometry;

  @override
  Widget build(BuildContext context) => PenPath(
    geometry,
    viewBox: const [0, 0, 34, 36],
    width: 32,
    height: 36,
    color: PenColors.card,
    strokeWidth: 3,
    roundCap: true,
  );
}

/// The dark footer panel: resolution, video-type selector and flip camera,
/// all in one row.
class _CamFooter extends StatelessWidget {
  const _CamFooter({
    required this.typeLabel,
    required this.resolutionLabel,
    this.onPickType,
    this.onSettings,
    this.onResolution,
    this.onFlipCamera,
  });

  final String typeLabel;
  final String resolutionLabel;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onResolution;
  final VoidCallback? onFlipCamera;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF050505),
        border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _RailPill(label: resolutionLabel, onTap: onResolution),
              const SizedBox(width: 10),
              Expanded(
                child: Center(
                  child: _TypeChipRow(
                    typeLabel: typeLabel,
                    onPickType: onPickType,
                    onSettings: onSettings,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _RailIconButton(
                icon: LucideIcons.refreshCw,
                tooltip: context.l10n.tooltipSwitchCamera,
                onTap: onFlipCamera,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CamHeader extends StatelessWidget {
  const _CamHeader({
    required this.queueCount,
    this.stampCode,
    this.onBack,
    this.onQueueTap,
  });

  final int queueCount;
  final String? stampCode;
  final VoidCallback? onBack;
  final VoidCallback? onQueueTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Sát mép trên hết mức: khối mốc thời gian bên phải cao hơn một nút bấm,
      // đẩy xuống nữa là nó ăn vào khung ngắm.
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      // Stack chứ không phải Row: khối mốc thời gian được phép lấn sang nửa
      // trái khi mã dài, thay vì bị bóp lại rồi xuống dòng. Trong Row nó phải
      // chia phần rộng với nút back và chip mây.
      //
      // `Clip.none` là bắt buộc: Stack cao bằng hàng nút (50) còn khối mốc ba
      // dòng cao hơn thế, cắt mặc định là nuốt mất đúng dòng mã vận đơn.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nút back chỉ hiện khi có người nhận: màn quay bỏ nó đi vì lối
              // ra đã nằm ở sheet chọn loại (bấm back ở đó là sang tab Vận
              // đơn), và thanh tab dưới cùng vẫn luôn ở đó.
              if (onBack != null)
                _Tap(
                  onTap: onBack,
                  tooltip: context.l10n.tooltipBack,
                  child: const PenBox(
                    width: 42,
                    height: 42,
                    fill: Color(0xBF161616),
                    stroke: PenColors.mut,
                    radius: 999,
                    axis: PenAxis.row,
                    main: MainAxisAlignment.center,
                    cross: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.chevronLeft,
                        size: 22,
                        color: PenColors.card,
                      ),
                    ],
                  ),
                ),
              if (onBack != null) const SizedBox(width: 2),
              // Đệm 4 giống hệt `_Tap` bọc nút back: nếu không, hai khối cùng
              // cao 42 nhưng nút back bị đẩy xuống 4 còn chip thì không, nhìn
              // ra ngay là chip cao hơn. 2 + 4 + 4 = khoảng cách thấy được 10.
              Padding(
                padding: const EdgeInsets.all(4),
                child: EcTap(
                  onTap: onQueueTap,
                  child: _QueueChip(count: queueCount),
                ),
              ),
            ],
          ),
          if (stampCode case final code?)
            Positioned(right: 0, top: 0, child: _RecStamp(code: code)),
        ],
      ),
    );
  }
}

/// Mốc thời gian + mã vận đơn ở góc phải khi đang quay.
///
/// Hai hàng, đúng bố cục mà hệ thống đóng vào khung hình lúc render: hàng trên
/// là ngày kèm giờ đến giây, hàng dưới là mã vận đơn. Người quay nhìn thấy
/// trước đúng thứ người nhận bằng chứng sẽ đọc — sai ngày giờ máy hay quay
/// nhầm mã thì lộ ra ngay tại chỗ, không phải đợi tới lúc gửi cho sàn.
///
/// Chỉ GIÁ TRỊ thời gian được phép khác bản render (ở đây là đồng hồ máy chạy
/// trực tiếp, bên kia là trục giờ hệ thống chốt). Bố cục thì không.
class _RecStamp extends StatefulWidget {
  const _RecStamp({required this.code});

  final String code;

  @override
  State<_RecStamp> createState() => _RecStampState();
}

class _RecStampState extends State<_RecStamp> {
  late final Timer _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ngày và giờ CÙNG một hàng. Có cả giây: hai clip liền nhau của cùng
        // một ca chỉ khác nhau ở đây.
        Text(
          '${_two(now.day)}/${_two(now.month)}/${now.year} '
          '${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}',
          style: _stampStyle(18, FontWeight.w700),
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
        // Một hàng, không cắt bằng `...` và không xuống dòng: một mã vận đơn
        // thiếu đuôi thì vô dụng. Mã dài thì để nó dài sang trái.
        Text(
          widget.code,
          style: _stampStyle(15, FontWeight.w600),
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }
}

/// Chữ trắng nổi thẳng trên khung ngắm, không có nền.
///
/// Nền là cảnh đóng gói nên sáng tối thất thường — bóng đổ tối dưới chữ là
/// thứ duy nhất giữ cho nó đọc được trên cả nền trắng lẫn nền tối, thay cho
/// cái khung đã bỏ. Cùng cách xử lý với dấu đóng vào clip lúc xuất.
TextStyle _stampStyle(double size, FontWeight weight) => TextStyle(
  fontSize: size,
  height: 1.25,
  color: PenColors.card,
  fontWeight: weight,
  shadows: const [
    Shadow(color: Color(0xCC000000), blurRadius: 6),
    Shadow(color: Color(0x99000000), offset: Offset(0, 1)),
  ],
);

class _QueueChip extends StatelessWidget {
  const _QueueChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      // Cùng chiều cao với nút back (42) để hai cái thẳng hàng cả trên lẫn
      // dưới — chip tự co theo chữ thì thấp hơn và nhìn ra ngay là lệch.
      height: 42,
      fill: const Color(0xBF161616),
      stroke: PenColors.mut,
      radius: 999,
      axis: PenAxis.row,
      gap: 8,
      cross: CrossAxisAlignment.center,
      hugMain: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        const Icon(
          LucideIcons.cloudUpload,
          size: 19,
          color: PenColors.card,
        ),
        PenText(
          '$count',
          size: 16,
          color: PenColors.card,
          weight: FontWeight.w700,
          softWrap: false,
        ),
      ],
    );
  }
}

class _CamCodeBadge extends StatelessWidget {
  const _CamCodeBadge({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      fill: PenColors.ink,
      stroke: PenColors.mut,
      radius: 999,
      axis: PenAxis.row,
      gap: 10,
      cross: CrossAxisAlignment.center,
      hugMain: true,
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 15),
      children: [
        const PenBox(
          width: 22,
          height: 22,
          fill: PenColors.soft,
          radius: 6,
          axis: PenAxis.row,
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          children: [
            Icon(LucideIcons.package, size: 16, color: PenColors.ink),
          ],
        ),
        Flexible(
          child: PenText(
            code,
            size: 14,
            color: PenColors.card,
            weight: FontWeight.w700,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _RecRow extends StatelessWidget {
  const _RecRow({this.elapsed = '00:00'});

  /// Running clip length, `mm:ss`.
  final String elapsed;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      fill: const Color(0xCC161616),
      stroke: PenColors.mut,
      radius: 999,
      axis: PenAxis.row,
      gap: 11,
      cross: CrossAxisAlignment.center,
      hugMain: true,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      children: [
        const PenEllipse(width: 14, height: 14, color: PenColors.danger),
        const PenText(
          'REC',
          size: 18,
          color: PenColors.card,
          weight: FontWeight.w700,
          softWrap: false,
        ),
        PenText(
          elapsed,
          size: 18,
          color: PenColors.card,
          weight: FontWeight.w700,
          softWrap: false,
        ),
      ],
    );
  }
}

class _RailPill extends StatelessWidget {
  const _RailPill({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _Tap(
      onTap: onTap,
      tooltip: label,
      child: PenBox(
        width: 58,
        height: 42,
        fill: const Color(0xCC1C1C1E),
        stroke: const Color(0x1AFFFFFF),
        radius: 999,
        axis: PenAxis.row,
        main: MainAxisAlignment.center,
        cross: CrossAxisAlignment.center,
        children: [
          PenText(
            label,
            size: 13,
            color: PenColors.card,
            weight: FontWeight.w700,
            softWrap: false,
          ),
        ],
      ),
    );
  }
}

class _RailIconButton extends StatelessWidget {
  const _RailIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _Tap(
      onTap: onTap,
      tooltip: tooltip,
      child: PenBox(
        width: 58,
        height: 42,
        fill: const Color(0xCC1C1C1E),
        stroke: const Color(0x1AFFFFFF),
        radius: 999,
        axis: PenAxis.row,
        main: MainAxisAlignment.center,
        cross: CrossAxisAlignment.center,
        children: [Icon(icon, size: 21, color: PenColors.card)],
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _Tap(
      onTap: onTap,
      tooltip: context.l10n.tooltipStopRecording,
      child: const PenBox(
        width: 86,
        height: 86,
        stroke: PenColors.card,
        strokeWidth: 5,
        radius: 999,
        axis: PenAxis.row,
        main: MainAxisAlignment.center,
        cross: CrossAxisAlignment.center,
        children: [
          PenBox(width: 34, height: 34, fill: PenColors.danger, radius: 8),
        ],
      ),
    );
  }
}

class _TypeChipRow extends StatelessWidget {
  const _TypeChipRow({
    required this.typeLabel,
    this.onPickType,
    this.onSettings,
  });
  final String typeLabel;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      fill: const Color(0xCC1C1C1E),
      radius: 999,
      axis: PenAxis.row,
      gap: 2,
      cross: CrossAxisAlignment.center,
      hugMain: true,
      padding: const EdgeInsets.all(4),
      children: [
        Flexible(
          child: Opacity(
            // Khoá đổi loại video giữa lúc quay (xem RecordingSession) — chip
            // phải trông bị khoá chứ không sáng như thường.
            opacity: onPickType == null ? kEcDisabledOpacity : 1,
            child: EcTap(
              onTap: onPickType,
              child: PenBox(
                fill: const Color(0x1FFFFFFF),
                radius: 999,
                axis: PenAxis.row,
                hugMain: true,
                padding: const EdgeInsets.symmetric(
                  vertical: 9,
                  horizontal: 16,
                ),
                children: [
                  Flexible(
                    child: PenText(
                      typeLabel,
                      size: 15,
                      color: const Color(0xFF67BB75),
                      weight: FontWeight.w800,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onSettings != null)
          Tooltip(
            message: context.l10n.videoTypeSettings,
            child: EcTap(
              onTap: onSettings,
              child: const PenBox(
                radius: 999,
                axis: PenAxis.row,
                hugMain: true,
                padding: EdgeInsets.symmetric(vertical: 9, horizontal: 16),
                children: [
                  Icon(
                    LucideIcons.settings,
                    size: 16,
                    color: Color(0x8CFFFFFF),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Small tap target wrapper (Material + InkWell — never `IconButton` with
/// implicit padding assumptions, to keep hit areas predictable).
class _Tap extends StatelessWidget {
  const _Tap({required this.child, this.tooltip, this.onTap});
  final Widget child;
  final String? tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final button = EcTap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        // Đang quay thì đổi camera / độ phân giải bị chặn. Không làm mờ thì
        // nút trông y hệt lúc bấm được, người dùng bấm mãi không hiểu vì sao.
        child: Opacity(
          opacity: onTap == null ? kEcDisabledOpacity : 1,
          child: child,
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}

/// Độ mờ của control camera đang bị khoá — dùng chung để mọi nút bị khoá
/// trông giống nhau.
const kEcDisabledOpacity = 0.4;

// --- UploadQueue ---------------------------------------------------------

/// Upload status of a queued evidence video.
enum EcUploadStatus {
  /// Currently uploading, [EcUploadItem.progressPercent] is set.
  uploading,

  /// Waiting for its turn in the queue.
  waiting,

  /// Uploaded successfully.
  done,

  /// Failed, [EcUploadItem.retryCount] tracks the retry attempts so far.
  error,

  /// Waiting for the monthly upload quota to free up.
  quotaWait,

  /// Paused by the user — excluded from the upload rotation until resumed.
  paused,
}

/// A single row of the upload queue list.
class EcUploadItem {
  const EcUploadItem({
    required this.code,
    required this.typeLabel,
    required this.when,
    required this.status,
    this.id,
    this.progressPercent,
    this.retryCount,
    this.errorMessage,
    this.playable = false,
  });

  /// Stable id used to route retry actions back to the queue.
  final String? id;

  final String code;
  final String typeLabel;

  /// NGÀY và GIỜ clip vào hàng đợi, ví dụ `17/08/2026 09:12`.
  ///
  /// Từng tên là `timeRange` và chỉ mang `HH:mm`. Hàng đợi giữ clip qua đêm khi
  /// mạng chập hoặc hết hạn mức, nên một cột chỉ có giờ thì "09:12" của hôm nay
  /// và "09:12" của ba hôm trước trông y hệt nhau — đúng lúc người bán cần biết
  /// clip nào đã kẹt lâu.
  ///
  /// Giờ theo đồng hồ 24 giờ, không AM/PM.
  final String when;
  final EcUploadStatus status;
  final int? progressPercent;
  final int? retryCount;

  /// Human-readable reason the last attempt failed, only set for
  /// [EcUploadStatus.error] — shown under the retry count so a seller isn't
  /// left staring at an unexplained "Lỗi".
  final String? errorMessage;

  /// Bấm vào hàng này thì xem lại được clip.
  ///
  /// Chỉ đúng với clip ĐÃ tải lên xong: trước đó thứ duy nhất tồn tại là tệp
  /// thô trên máy, và hàng đợi cố ý không mời người dùng xem nó — họ đang đợi
  /// nó lên, không đợi nó phát. Ảnh đính kèm cũng không bật, vì màn mở ra là
  /// trình phát video.
  ///
  /// Bên gọi quyết định, không phải giao diện: chỉ nó biết clip còn bản xem
  /// tạm trên máy hay còn link ở máy chủ hay không.
  final bool playable;
}

/// The upload queue list — quota banner and one status per video.
class EcUploadQueueScreen extends StatelessWidget {
  const EcUploadQueueScreen({
    this.items = const [],
    this.onBack,
    this.onSettings,
    this.onRetry,
    this.onPause,
    this.onResume,
    this.onDelete,
    this.onClear,
    this.onOpen,
    super.key,
  });

  final List<EcUploadItem> items;
  final VoidCallback? onBack;

  /// Xoá CẢ hàng đợi. Bên gọi phải hỏi lại trước — thứ mất đi là những clip
  /// chưa lên máy chủ, chỉ tồn tại trên đúng cái máy này.
  final VoidCallback? onClear;

  /// F3-06's header gear. Optional: no upload-settings screen exists yet, so
  /// the icon only appears once a caller has somewhere to send it.
  final VoidCallback? onSettings;

  /// Called with an errored item when its "Thử lại" affordance is tapped.
  final ValueChanged<EcUploadItem>? onRetry;

  /// Called with an item when its "Tạm dừng" affordance is tapped.
  final ValueChanged<EcUploadItem>? onPause;

  /// Called with a paused item when its "Tiếp tục" affordance is tapped.
  final ValueChanged<EcUploadItem>? onResume;

  /// Called with an item when its remove affordance is tapped.
  final ValueChanged<EcUploadItem>? onDelete;

  /// Bấm vào một hàng [EcUploadItem.playable] để xem lại clip.
  final ValueChanged<EcUploadItem>? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Row(
                children: [
                  _Tap(
                    onTap: onBack,
                    child: const Icon(
                      LucideIcons.chevronLeft,
                      size: 26,
                      color: BrandColors.ink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.uploadQueueTitle,
                      overflow: TextOverflow.ellipsis,
                      style: _t(22, FontWeight.w800, BrandColors.ink),
                    ),
                  ),
                  // F3-06 draws a gear here, but nothing routes to upload
                  // settings yet — drawing it unconditionally would be a
                  // button that does nothing.
                  if (onClear != null)
                    _Tap(
                      onTap: onClear,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          context.l10n.queueClearAction,
                          style: _t(16, FontWeight.w700, BrandColors.rec),
                        ),
                      ),
                    ),
                  if (onSettings != null)
                    _Tap(
                      onTap: onSettings,
                      child: const Icon(
                        LucideIcons.settings,
                        size: 25,
                        color: BrandColors.ink,
                      ),
                    )
                  // Chỗ trống giữ cân đối cho tiêu đề khi góc phải rỗng. Có
                  // nút Xoá hết rồi thì bỏ đi, không thì nó đẩy chữ đó thụt
                  // vào trong thay vì nằm sát mép.
                  else if (onClear == null)
                    const SizedBox(width: 26),
                ],
              ),
            ),
            Expanded(
              child: EcUploadQueueList(
                items: items,
                onRetry: onRetry,
                onPause: onPause,
                onResume: onResume,
                onDelete: onDelete,
                onOpen: onOpen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Phần thân của hàng đợi — băng hạn mức, các hàng clip, và câu ghi chú.
///
/// Tách khỏi [EcUploadQueueScreen] để dùng lại được trong sheet nửa màn mở từ
/// màn quay: sheet đó có tiêu đề và tay nắm riêng, không dùng được khung màn
/// đầy đủ, nhưng nội dung phải giống hệt — hai bản chép tay sẽ lệch nhau ngay
/// lần sửa trạng thái tiếp theo.
class EcUploadQueueList extends StatelessWidget {
  const EcUploadQueueList({
    this.items = const [],
    this.onRetry,
    this.onPause,
    this.onResume,
    this.onDelete,
    this.onOpen,
    this.padding = const EdgeInsets.fromLTRB(18, 18, 18, 18),
    super.key,
  });

  final List<EcUploadItem> items;
  final ValueChanged<EcUploadItem>? onRetry;
  final ValueChanged<EcUploadItem>? onPause;
  final ValueChanged<EcUploadItem>? onResume;
  final ValueChanged<EcUploadItem>? onDelete;

  /// Bấm vào một hàng [EcUploadItem.playable] để xem lại clip.
  final ValueChanged<EcUploadItem>? onOpen;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final quotaWaiting = items
        .where((i) => i.status == EcUploadStatus.quotaWait)
        .length;
    // ponytail: the whole page scrolls as one column so the footer note sits
    // right under the card like the design, instead of being pinned to the
    // bottom. A queue is tens of rows, not thousands — swap in a sliver list
    // if that ever changes.
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Only real when something is actually waiting on quota — this used
          // to render unconditionally, showing "out of quota" even when
          // nothing was quota-blocked.
          if (quotaWaiting > 0) ...[
            const _QuotaBanner(),
            const SizedBox(height: 16),
          ],
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  l10n.queueEmpty,
                  style: _t(14, FontWeight.w400, BrandColors.mut),
                ),
              ),
            )
          else
            DecoratedBox(
              decoration: ecSquircleDecoration(
                radius: 14,
                color: BrandColors.card,
                shadows: const [
                  BoxShadow(
                    color: Color(0x12161616),
                    offset: Offset(0, 2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) Container(height: 1, color: BrandColors.line),
                      _UploadRow(
                        item: items[i],
                        onRetry: onRetry,
                        onPause: onPause,
                        onResume: onResume,
                        onDelete: onDelete,
                        onOpen: onOpen,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              l10n.queueAutoUploadNote,
              textAlign: TextAlign.center,
              style: _t(13, FontWeight.w400, BrandColors.mut),
            ),
          ),
        ],
      ),
    );
  }
}

/// Băng cảnh báo hạn mức trên màn hàng đợi.
///
/// Nói đúng MỘT sự thật mà người đóng gói cần biết ngay: những clip này đang
/// nằm trên chính cái điện thoại họ đang cầm, và chưa được bảo vệ. Bản cũ viết
/// "video sẽ chờ quota" — nghe như máy chủ đang giữ hộ, đúng cái hiểu nhầm nguy
/// hiểm nhất ở đây.
///
/// KHÔNG có link "Nâng gói". Người cầm máy thường không phải người trả tiền, và
/// quy tắc chống dẫn dắt của Apple (App Review 3.1) cấm mọi lối chỉ sang trang
/// thanh toán trong app. Việc nhắc mua đi qua email tới chủ shop.
class _QuotaBanner extends StatelessWidget {
  const _QuotaBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
      decoration: ecSquircleDecoration(
        radius: 14,
        color: BrandColors.warningTint,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.circleAlert,
            size: 20,
            color: BrandColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.quotaExhaustedNote,
                  style: _t(13, FontWeight.w400, BrandColors.ink),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.quotaExhaustedWarn,
                  style: _t(12.5, FontWeight.w700, BrandColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bọc [child] trong một vùng bấm CHỈ KHI có [onTap].
///
/// Không có việc để làm thì không dựng thêm một lớp widget nào: một danh sách
/// dài mà mỗi hàng đội thêm một `StatefulWidget` chỉ để không làm gì là phí, và
/// quan trọng hơn — cây widget không đổi thì bản dựng ra không đổi.
class _MaybeTap extends StatelessWidget {
  const _MaybeTap({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) =>
      onTap == null ? child : EcTap(onTap: onTap, child: child);
}

class _UploadRow extends StatelessWidget {
  const _UploadRow({
    required this.item,
    this.onRetry,
    this.onPause,
    this.onResume,
    this.onDelete,
    this.onOpen,
  });
  final EcUploadItem item;
  final ValueChanged<EcUploadItem>? onRetry;

  /// Called when "Tạm dừng" is tapped — only offered for a not-yet-uploading
  /// item (waiting/error/quota-wait).
  final ValueChanged<EcUploadItem>? onPause;

  /// Called when "Tiếp tục" is tapped on a paused item.
  final ValueChanged<EcUploadItem>? onResume;

  /// Called when the item's remove icon is tapped.
  final ValueChanged<EcUploadItem>? onDelete;

  /// Bấm vào phần thân hàng để xem lại clip. Xem [EcUploadItem.playable].
  final ValueChanged<EcUploadItem>? onOpen;

  @override
  Widget build(BuildContext context) {
    final canPause =
        onPause != null &&
        (item.status == EcUploadStatus.waiting ||
            item.status == EcUploadStatus.error ||
            item.status == EcUploadStatus.quotaWait);
    final canResume = onResume != null && item.status == EcUploadStatus.paused;
    final canOpen = onOpen != null && item.playable;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          // Dấu tích đứng TRƯỚC mã vận đơn: người quay rà danh sách bằng cách
          // liếc dọc mép trái, nên "đơn này xong chưa" phải nằm ngay ở mép đó
          // chứ không phải cuối hàng, sau một đoạn mã dài ngắn khác nhau.
          if (item.status == EcUploadStatus.done) ...[
            Semantics(
              label: context.l10n.uploaded,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: BrandColors.ring,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.check,
                  size: 13,
                  color: BrandColors.onRec,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            // Bấm vào THÂN hàng, không phải vào một nút riêng: chỗ bấm rộng
            // bằng cả hàng nên không phải ngắm, và dấu × vẫn nằm ngoài vùng
            // này nên không có chuyện định xem lại mà bấm trúng xoá.
            //
            // `EcTap` trần chứ KHÔNG phải `_Tap`: `_Tap` là vỏ cho nút icon và
            // nó tự thêm `Padding(all: 4)`, đủ để đẩy lệch mọi hàng trong danh
            // sách. Và chỉ bọc khi hàng thật sự bấm được — hàng chưa lên xong
            // phải dựng ra đúng từng điểm ảnh như trước.
            child: _MaybeTap(
              onTap: canOpen ? () => onOpen!(item) : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.code,
                          overflow: TextOverflow.ellipsis,
                          style: _t(16, FontWeight.w700, BrandColors.ink),
                        ),
                      ),
                      // Dấu phát nhỏ: không có nó thì không ai đoán được hàng
                      // này bấm vào được, và tính năng coi như không tồn tại.
                      if (canOpen) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.circlePlay,
                          size: 16,
                          color: BrandColors.mut,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${item.typeLabel} · ${item.when} · ${_statusWord(context, item.status)}',
                    overflow: TextOverflow.ellipsis,
                    style: _t(12, FontWeight.w400, BrandColors.mut),
                  ),
                  if (item.status == EcUploadStatus.uploading) ...[
                    const SizedBox(height: 8),
                    _UploadProgressBar(percent: item.progressPercent ?? 0),
                  ],
                  if (item.status == EcUploadStatus.error &&
                      item.errorMessage != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      item.errorMessage!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(12, FontWeight.w400, BrandColors.rec),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _UploadStatusTrailing(
            item: item,
            onRetry: onRetry,
          ),
          if (canPause)
            _RowIconButton(
              icon: Icons.pause_circle_outline,
              tooltip: context.l10n.queuePauseAction,
              onTap: () => onPause!(item),
            ),
          if (canResume)
            _RowIconButton(
              icon: Icons.play_circle_outline,
              tooltip: context.l10n.queueResumeAction,
              onTap: () => onResume!(item),
            ),
          // Dấu × chứ không phải thùng rác: thùng rác nói "vứt bỏ vĩnh viễn",
          // mà việc thật ở đây là gạt một hàng khỏi danh sách.
          if (onDelete != null)
            _RowIconButton(
              icon: Icons.close,
              tooltip: context.l10n.queueDeleteAction,
              onTap: () => onDelete!(item),
            ),
        ],
      ),
    );
  }
}

class _RowIconButton extends StatelessWidget {
  const _RowIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: EcTap(
        onTap: onTap,
        child: Semantics(
          label: tooltip,
          button: true,
          child: Icon(icon, size: 20, color: BrandColors.mut),
        ),
      ),
    );
  }
}

/// The full-width progress track F3-06 puts under an uploading row's status.
class _UploadProgressBar extends StatelessWidget {
  const _UploadProgressBar({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      decoration: ecSquircleDecoration(radius: 999, color: BrandColors.line),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (percent.clamp(0, 100)) / 100,
        child: DecoratedBox(
          decoration: ecSquircleDecoration(radius: 999, color: BrandColors.ink),
        ),
      ),
    );
  }
}

/// The row's whole status, at the trailing edge. One place per row: the status
/// used to be a text line under the meta line *and* a glyph out here, which
/// said the same thing twice and pushed every row three lines tall.
/// Trạng thái của một hàng, bằng CHỮ.
///
/// Phần đuôi hàng đã có phần trăm, nút thử lại, hoặc nhãn chờ — nhưng hàng đã
/// xong thì chỉ có một dấu tích, và một dấu tích không nói được "đã lên cloud"
/// với người chưa quen app. Đưa trạng thái vào dòng thông tin để mọi hàng đều
/// đọc được thành lời, không phải đoán qua biểu tượng.
String _statusWord(BuildContext context, EcUploadStatus status) {
  final l10n = context.l10n;
  return switch (status) {
    EcUploadStatus.done => l10n.uploaded,
    EcUploadStatus.uploading => l10n.queueUploading,
    EcUploadStatus.waiting => l10n.waitingUpload,
    EcUploadStatus.paused => l10n.pausedUpload,
    // Bản dài ("Chờ hạn mức · còn trên máy") dành cho nhãn ở đuôi hàng, nơi nó
    // có chỗ xuống dòng. Ở dòng thông tin thì nó đẩy ngày giờ ra khỏi màn.
    EcUploadStatus.quotaWait => l10n.queueQuotaShort,
    EcUploadStatus.error => l10n.queueUploadFailed,
  };
}

class _UploadStatusTrailing extends StatelessWidget {
  const _UploadStatusTrailing({required this.item, this.onRetry});
  final EcUploadItem item;
  final ValueChanged<EcUploadItem>? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (item.status) {
      // The percentage sits where every other row shows its status; the bar
      // under the meta line carries the same value visually.
      EcUploadStatus.uploading => Text(
        '${item.progressPercent ?? 0}%',
        style: _t(13, FontWeight.w700, BrandColors.ink),
      ),
      // Dấu tích đã chuyển sang đứng TRƯỚC mã vận đơn, nên ở đây không vẽ gì
      // nữa — hai dấu tích trên cùng một hàng chỉ làm hàng rộng ra vô ích.
      EcUploadStatus.done => const SizedBox.shrink(),
      // The only action the list offers, so it looks like a button instead of
      // a bare glyph a seller has to guess at.
      EcUploadStatus.error => EcTap(
        onTap: onRetry == null ? null : () => onRetry!(item),
        child: Semantics(
          label: l10n.commonRetry,
          button: true,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 13),
            decoration: ecSquircleDecoration(
              radius: 999,
              color: BrandColors.card,
              side: const BorderSide(color: BrandColors.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.refreshCw,
                  size: 14,
                  color: BrandColors.rec,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.commonRetry,
                  style: _t(13, FontWeight.w700, BrandColors.rec),
                ),
              ],
            ),
          ),
        ),
      ),
      // Nhãn duy nhất có hai vế ("Chờ hạn mức · còn trên máy", bản EN còn dài
      // hơn) nên là nhãn duy nhất phải chặn bề ngang: hàng này không co được,
      // để nó lấy bề ngang tự nhiên là tràn Row và người dùng mất luôn phần
      // đuôi. Xuống dòng thành 2 dòng thay vì cắt cụt — vế sau ("còn trên
      // máy") mới là vế đáng đọc.
      //
      // ponytail: chặn cứng 116px vì chỉ một nhãn cần; nhãn thứ hai dài ra thì
      // hãy bọc cả `_UploadStatusTrailing` vào `Flexible` một lần cho xong.
      EcUploadStatus.quotaWait => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 116),
        child: Text(
          l10n.waitingQuota,
          textAlign: TextAlign.end,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _t(12, FontWeight.w600, BrandColors.warning),
        ),
      ),
      EcUploadStatus.waiting => Text(
        l10n.waitingUpload,
        style: _t(12, FontWeight.w600, BrandColors.mut),
      ),
      EcUploadStatus.paused => Text(
        l10n.pausedUpload,
        style: _t(12, FontWeight.w600, BrandColors.mut),
      ),
    };
  }
}

// --- ManualEntry ---------------------------------------------------------

/// Manual mã vận đơn entry sheet, shown over the (black) camera preview
/// when the printed bill can't be scanned.
class EcManualEntryScreen extends StatefulWidget {
  const EcManualEntryScreen({
    this.initialValue = '',
    this.onCancel,
    this.onManualSubmit,
    super.key,
  });

  final String initialValue;
  final VoidCallback? onCancel;
  final ValueChanged<String>? onManualSubmit;

  @override
  State<EcManualEntryScreen> createState() => _EcManualEntryScreenState();
}

class _EcManualEntryScreenState extends State<EcManualEntryScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Opening the sheet is the user asking to type, so raise the keyboard
    // straight away instead of making them tap the field first.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  /// Set once the user submits an empty field; cleared as soon as they type.
  /// Blocking here rather than letting an empty code through keeps the capture
  /// flow from opening a recording that can never be matched to an order.
  bool _emptyError = false;

  void _submit() {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() => _emptyError = true);
      _focus.requestFocus();
      return;
    }
    widget.onManualSubmit?.call(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Tapping anywhere outside the sheet closes it.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onCancel,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              // Dragging the sheet down dismisses it too.
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) > 200) {
                  widget.onCancel?.call();
                }
              },
              // A tap on the sheet's own chrome drops the keyboard without
              // closing the sheet.
              onTap: () => FocusScope.of(context).unfocus(),
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 120),
                padding: EdgeInsets.only(bottom: context.bottomInset),
                child: PenBox(
                  width: double.infinity,
                  fill: PenColors.card,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  axis: PenAxis.column,
                  hugMain: true,
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                  children: [
                    const Center(
                      child: PenBox(
                        width: 46,
                        height: 5,
                        fill: PenColors.line,
                        radius: 3,
                      ),
                    ),
                    const SizedBox(height: 18),
                    PenText(
                      l10n.manualTrackingTitle,
                      size: 24,
                      color: PenColors.ink,
                      weight: FontWeight.w800,
                    ),
                    const SizedBox(height: 14),
                    // The whole 58pt box focuses the field — previously only
                    // the text span itself did, so taps on the right half of
                    // the row did nothing.
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _focus.requestFocus,
                      child: PenBox(
                        width: double.infinity,
                        height: 58,
                        fill: PenColors.card,
                        stroke: _emptyError ? PenColors.danger : PenColors.line,
                        radius: 14,
                        axis: PenAxis.row,
                        cross: CrossAxisAlignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        children: [
                          Expanded(
                            child: CupertinoTextField(
                              controller: _controller,
                              focusNode: _focus,
                              padding: EdgeInsets.zero,
                              decoration: const BoxDecoration(),
                              placeholder: 'SPXVN…',
                              textInputAction: TextInputAction.done,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.characters,
                              onChanged: (_) {
                                if (_emptyError) {
                                  setState(() => _emptyError = false);
                                }
                              },
                              onSubmitted: (_) => _submit(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: PenColors.ink,
                              ),
                              placeholderStyle: const TextStyle(
                                fontSize: 18,
                                color: PenColors.mut,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_emptyError) ...[
                      const SizedBox(height: 8),
                      PenText(
                        l10n.manualEntryEmptyError,
                        size: 13,
                        color: PenColors.danger,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: EcTap(
                            onTap: widget.onCancel,
                            child: PenBox(
                              height: 56,
                              fill: PenColors.card,
                              stroke: PenColors.line,
                              radius: 14,
                              axis: PenAxis.row,
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              children: [
                                // Cùng lý do như `_DialogButtons` ở feature
                                // account: nhãn nút phải CO ĐƯỢC. Nút chia đôi
                                // chiều ngang tấm sheet, nên một bản dịch dài
                                // hơn hay cỡ chữ hệ thống phóng to là tràn.
                                Flexible(
                                  child: PenText(
                                    l10n.commonCancel,
                                    size: 16,
                                    color: PenColors.ink,
                                    weight: FontWeight.w600,
                                    softWrap: false,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: EcTap(
                            onTap: _submit,
                            child: PenBox(
                              height: 56,
                              fill: PenColors.primary,
                              radius: 14,
                              axis: PenAxis.row,
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: PenText(
                                    l10n.startRecording,
                                    size: 16,
                                    color: PenColors.card,
                                    weight: FontWeight.w700,
                                    softWrap: false,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.paddingOf(context).bottom),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- NoMatch ---------------------------------------------------------

/// Dialog shown when a scanned return code doesn't match any order in the
/// shop.
class EcNoMatchScreen extends StatelessWidget {
  const EcNoMatchScreen({
    required this.returnCode,
    required this.shopName,
    this.onEnterManually,
    this.onCreateNew,
    super.key,
  });

  final String returnCode;
  final String shopName;
  final VoidCallback? onEnterManually;
  final VoidCallback? onCreateNew;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // F3-08 dựng đây là bottom sheet chứ không phải hộp thoại giữa màn: người
    // dùng đang cầm máy quay, các nút phải nằm trong tầm ngón cái.
    return PenSheet(
      padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
      dim: const Color(0x99161616),
      children: [
        const _MismatchBadge(),
        PenText(
          l10n.returnCodeMismatch,
          size: 24,
          color: PenColors.danger,
          weight: FontWeight.w800,
          align: TextAlign.center,
        ),
        const SizedBox(height: 14),
        PenText(
          l10n.returnCodeMismatchBody(returnCode, shopName),
          size: 14,
          color: PenColors.danger,
          align: TextAlign.center,
          lineHeight: 1.6,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: PenOutlineButton(
                label: l10n.enterCodeManually,
                height: 58,
                onPressed: onEnterManually,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: PenPrimaryButton(
                label: l10n.createOrderConfirm,
                height: 58,
                labelSize: 16,
                onPressed: onCreateNew,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Huy hiệu cảnh báo của F3-08: vòng tròn hồng nhạt, icon tam giác đỏ, và 5
/// chấm "tia" quanh mép — toạ độ lấy nguyên từ frame `IconWrap` 118x118.
class _MismatchBadge extends StatelessWidget {
  const _MismatchBadge();

  static const _sparks = [
    (6.0, 26.0, 7.0),
    (104.0, 20.0, 6.0),
    (100.0, 72.0, 7.0),
    (18.0, 84.0, 5.0),
    (86.0, 4.0, 4.0),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      height: 118,
      child: Stack(
        children: [
          const Positioned(
            left: 14,
            top: 6,
            child: PenEllipse(width: 96, height: 96, color: Color(0xFFF8E7E7)),
          ),
          const Positioned(
            left: 40,
            top: 32,
            child: Icon(
              LucideIcons.triangleAlert,
              size: 44,
              color: PenColors.danger,
            ),
          ),
          for (final (left, top, size) in _sparks)
            Positioned(
              left: left,
              top: top,
              child: PenEllipse(
                width: size,
                height: size,
                color: PenColors.danger,
              ),
            ),
        ],
      ),
    );
  }
}

// --- TypeSheet ---------------------------------------------------------

/// A selectable video type shown in [EcTypeSheetScreen].
class EcVideoType {
  const EcVideoType({
    required this.label,
    required this.icon,
    this.locked = false,
    this.id,
    this.displayLabel,
  });

  /// Tên GỐC của loại — thứ đi cùng clip lên máy chủ và thứ luồng quay đem so
  /// (`state.typeLabel == 'Trả hàng'`). Không bao giờ dịch: dịch nó là đổi dữ
  /// liệu, không phải đổi giao diện.
  final String label;

  /// Tên để HIỆN LÊN MÀN, đã dịch theo ngôn ngữ đang chọn. `null` thì hiện
  /// [label] — đúng cho loại do shop tự đặt, vì đó là chữ của người dùng.
  final String? displayLabel;

  /// Chữ thật sự vẽ ra.
  String get shownLabel => displayLabel ?? label;

  /// Id trên máy chủ. `null` cho các loại dựng sẵn ở client
  /// ([ecDefaultVideoTypes]), thứ chỉ hiện khi chưa đọc được danh sách thật.
  ///
  /// Đi cùng clip qua hàng đợi: tên loại đổi được trong lúc clip còn chờ, id
  /// thì không.
  final String? id;
  final IconData icon;

  /// Built-in types are locked — they can't be renamed/removed (only
  /// managed from Chi tiết shop).
  final bool locked;
}

/// Built-in video types; production callers append live custom types by shop.
/// Loại video mỗi ca quay bắt đầu lại từ đầu — đóng gói hàng đi là việc chiếm
/// gần hết thời lượng quay, nên nó là mặc định thay vì loại chọn lần trước.
const kEcDefaultVideoType = 'Đóng hàng';

const List<EcVideoType> ecDefaultVideoTypes = [
  EcVideoType(
    label: 'Đóng hàng',
    icon: Icons.inventory_2_outlined,
    locked: true,
  ),
  EcVideoType(
    label: 'Đơn vị vận chuyển',
    icon: Icons.local_shipping_outlined,
    locked: true,
  ),
  EcVideoType(label: 'Trả hàng', icon: Icons.replay, locked: true),
];

/// The "Loại video" bottom sheet used to pick the type for a recording
/// session.
class EcTypeSheetScreen extends StatelessWidget {
  const EcTypeSheetScreen({
    this.types = ecDefaultVideoTypes,
    this.selectedType = 'Đóng hàng',
    this.onSelectType,
    this.onManageTypes,
    this.onBack,
    this.dismissible = true,
    super.key,
  });

  /// `false` khi sheet mở lúc vừa vào màn quay: chọn loại là bắt buộc nên
  /// không vuốt xuống hay chạm nền để bỏ qua được, chỉ chọn hoặc bấm back.
  final bool dismissible;

  final List<EcVideoType> types;
  final String selectedType;

  /// Nhận CẢ loại được chọn, không chỉ nhãn: bên gọi cần `id` để chốt vào clip
  /// ngay lúc quay.
  final ValueChanged<EcVideoType>? onSelectType;
  final VoidCallback? onManageTypes;

  /// Thoát mà không quay. Có mặt vì chọn loại là bắt buộc: không có lối này
  /// thì người mở nhầm tab bị kẹt trong sheet, gạt xuống nó lại hiện ra.
  final VoidCallback? onBack;

  /// Tiêu đề nhóm + các hàng của nhóm. Nhóm rỗng thì biến mất hẳn — một shop
  /// chưa tự thêm loại nào không nên thấy đề mục trống.
  List<Widget> _typeGroup(String title, Iterable<EcVideoType> group) {
    if (group.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Text(title, style: _t(14, FontWeight.w400, BrandColors.mut)),
      ),
      for (final type in group)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _TypeSheetRow(
            type: type,
            selected: type.label == selectedType,
            onTap: () => onSelectType?.call(type),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Dùng chung PenSheet như F3-08: bo góc trên 14, có grabber, và kéo panel
    // xuống (hoặc vẩy nhanh) là đóng. Nền mờ đen thay vì xám mặc định vì sheet
    // này nằm trên preview camera.
    return PenSheet(
      dim: Colors.black54,
      dismissible: dismissible,
      showGrabber: false,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        28 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (onBack != null) ...[
                    EcTap(
                      onTap: onBack,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 4, right: 10),
                        child: Icon(
                          LucideIcons.chevronLeft,
                          size: 26,
                          color: BrandColors.ink,
                        ),
                      ),
                    ),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.videoTypeSheetTitle,
                          style: _t(24, FontWeight.w800, BrandColors.ink),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.videoTypeSelectNote,
                          style: _t(14, FontWeight.w400, BrandColors.mut),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Khung F3-09 chia danh sách làm hai nhóm có tiêu đề. Không phải
            // trang trí: nhóm trên là loại khoá cứng ai cũng có, nhóm dưới là
            // loại shop tự thêm và sửa/xoá được — người dùng cần biết vì sao
            // có cái bấm giữ được, có cái không.
            ..._typeGroup(
              context.l10n.videoTypeGroupDefault,
              types.where((t) => t.locked),
            ),
            ..._typeGroup(
              context.l10n.videoTypeGroupCustom,
              types.where((t) => !t.locked),
            ),
            const SizedBox(height: 4),
            _ManageRow(onTap: onManageTypes),
          ],
        ),
      ],
    );
  }
}

class _TypeSheetRow extends StatelessWidget {
  const _TypeSheetRow({
    required this.type,
    required this.selected,
    this.onTap,
  });
  final EcVideoType type;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Khung F3-09 vẽ mỗi loại là một thẻ bo 14 có viền, không phải hàng ngăn
    // bằng gạch chân — vùng chạm vì thế nhìn thấy được, quan trọng với người
    // đang ôm thùng hàng bấm một tay.
    return EcTap(
      onTap: onTap,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: BrandColors.card,
          shape: SmoothRectangleBorder(
            smoothness: ecCornerSmoothing,
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: BrandColors.line),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          child: Row(
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(type.icon, size: 18, color: BrandColors.ink),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        type.shownLabel,
                        overflow: TextOverflow.ellipsis,
                        style: _t(14, FontWeight.w400, BrandColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    const Icon(
                      LucideIcons.check,
                      size: 16,
                      color: BrandColors.ink,
                    ),
                    const SizedBox(width: 10),
                  ],
                  if (type.locked)
                    const Icon(
                      LucideIcons.lock,
                      size: 14,
                      color: BrandColors.mut,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageRow extends StatelessWidget {
  const _ManageRow({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: DecoratedBox(
        decoration: const BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 4, 4),
          child: Row(
            children: [
              const Icon(
                Icons.settings_outlined,
                size: 16,
                color: BrandColors.ink,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.manageVideoTypesNote,
                  overflow: TextOverflow.ellipsis,
                  style: _t(14, FontWeight.w500, BrandColors.ink),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: BrandColors.mut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- shared buttons (pixel specs from pencil-new.pen — C/BtnOutline /
// C/BtnPrimary) ---

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return EcTap(
      onTap: onPressed,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: ecSquircleDecoration(
          radius: 12,
          color: enabled
              ? BrandColors.dark
              : BrandColors.dark.withValues(alpha: 0.4),
        ),
        child: Text(label, style: _t(16, FontWeight.w600, Colors.white)),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onPressed,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: ecSquircleDecoration(
          radius: 12,
          color: BrandColors.bg,
          side: const BorderSide(color: BrandColors.line),
        ),
        child: Text(label, style: _t(16, FontWeight.w500, BrandColors.ink)),
      ),
    );
  }
}
