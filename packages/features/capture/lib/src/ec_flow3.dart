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
    this.shopName = 'Shop ABC',
    this.queueCount = 3,
    this.typeLabel = 'Đóng hàng',
    this.resolutionLabel = '720p',
    this.preview,
    this.onBack,
    this.onPickType,
    this.onSettings,
    this.onFlipCamera,
    this.onManualEntry,
    this.onResolution,
    this.onNavOrders,
    this.onNavAccount,
    super.key,
  });

  final String shopName;
  final int queueCount;
  final String typeLabel;
  final String resolutionLabel;

  /// Live camera preview rendered full-bleed behind the overlay; a black
  /// placeholder is shown when `null` (design mock / no camera).
  final Widget? preview;
  final VoidCallback? onBack;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onResolution;
  final VoidCallback? onNavOrders;
  final VoidCallback? onNavAccount;

  @override
  Widget build(BuildContext context) {
    return _CamScaffold(
      shopName: shopName,
      queueCount: queueCount,
      typeLabel: typeLabel,
      resolutionLabel: resolutionLabel,
      preview: preview,
      onBack: onBack,
      onPickType: onPickType,
      onSettings: onSettings,
      onFlipCamera: onFlipCamera,
      onManualEntry: onManualEntry,
      onResolution: onResolution,
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
    this.shopName = 'Shop ABC',
    this.queueCount = 3,
    this.code = 'SPXVN024567890',
    this.elapsed = '00:00',
    this.typeLabel = 'Đóng hàng',
    this.resolutionLabel = '720p',
    this.preview,
    this.onBack,
    this.onPickType,
    this.onSettings,
    this.onFlipCamera,
    this.onManualEntry,
    this.onResolution,
    this.onNavOrders,
    this.onNavAccount,
    this.onStop,
    super.key,
  });

  final String shopName;
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
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onResolution;
  final VoidCallback? onNavOrders;
  final VoidCallback? onNavAccount;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return _CamScaffold(
      headerTitle: context.l10n.navRecord,
      shopName: shopName,
      queueCount: queueCount,
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
      // The design stacks the code and REC pills just under the header,
      // not in the middle of the viewfinder.
      centerArea: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 76),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CamCodeBadge(code: code),
              const SizedBox(height: 10),
              _RecRow(elapsed: elapsed),
            ],
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
    this.shopName = 'Shop ABC',
    this.queueCount = 3,
    this.closedSummary = 'Đã chốt mã vận đơn A (02:45)',
    this.signalText = 'Âm báo + rung khi chuyển đơn',
    this.newCode = 'SPXVN098765432',
    this.newDuration = '00:01',
    this.typeLabel = 'Đóng hàng',
    this.resolutionLabel = '720p',
    this.preview,
    this.onBack,
    this.onPickType,
    this.onSettings,
    this.onFlipCamera,
    this.onManualEntry,
    this.onStop,
    super.key,
  });

  final String shopName;
  final int queueCount;
  final String closedSummary;
  final String signalText;
  final String newCode;
  final String newDuration;
  final String typeLabel;
  final String resolutionLabel;

  /// The live camera texture — recording keeps running underneath this
  /// confirmation moment, so it must stay visible, not go black.
  final Widget? preview;
  final VoidCallback? onBack;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return _CamScaffold(
      headerTitle: context.l10n.navRecord,
      shopName: shopName,
      queueCount: queueCount,
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
      centerArea: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.check, size: 16, color: BrandColors.ink),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    closedSummary,
                    overflow: TextOverflow.ellipsis,
                    style: _t(14, FontWeight.w500, BrandColors.ink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(signalText, style: _t(12, FontWeight.w400, BrandColors.mut)),
            const SizedBox(height: 10),
            _CamCodeBadge(code: newCode),
            const SizedBox(height: 10),
            Text(
              newDuration,
              style: _t(30, FontWeight.w600, BrandColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NearLimit ---------------------------------------------------------

/// Recording screen showing the near-cap warning banner. The cap itself is
/// the shop's setting (FR-18), so the caller passes the text.
class EcNearLimitScreen extends StatelessWidget {
  const EcNearLimitScreen({
    this.shopName = 'Shop ABC',
    this.queueCount = 3,
    this.warningText = 'Sắp chạm trần 2 phút — video sẽ tự chốt',
    this.code = 'SPXVN024567890',
    this.duration = '14:12',
    this.typeLabel = 'Đóng hàng',
    this.resolutionLabel = '720p',
    this.preview,
    this.onBack,
    this.onPickType,
    this.onSettings,
    this.onFlipCamera,
    this.onManualEntry,
    this.onResolution,
    this.onNavOrders,
    this.onNavAccount,
    this.onStop,
    super.key,
  });

  final String shopName;
  final int queueCount;
  final String warningText;
  final String code;
  final String duration;
  final String typeLabel;
  final String resolutionLabel;
  final Widget? preview;
  final VoidCallback? onBack;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onResolution;
  final VoidCallback? onNavOrders;
  final VoidCallback? onNavAccount;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return _CamScaffold(
      headerTitle: context.l10n.navRecord,
      shopName: shopName,
      queueCount: queueCount,
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
    this.shopName = 'Shop ABC',
    this.queueCount = 3,
    this.code = 'SPXVN088877766 (hoàn)',
    this.duration = '00:32',
    this.linkNote = 'Tự liên kết về hồ sơ mã vận đơn gốc',
    this.typeLabel = 'Trả hàng',
    this.resolutionLabel = '720p',
    this.preview,
    this.onBack,
    this.onPickType,
    this.onSettings,
    this.onFlipCamera,
    this.onManualEntry,
    this.onStop,
    super.key,
  });

  final String shopName;
  final int queueCount;
  final String code;
  final String duration;
  final String linkNote;
  final String typeLabel;
  final String resolutionLabel;
  final Widget? preview;
  final VoidCallback? onBack;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return _CamScaffold(
      headerTitle: context.l10n.navRecord,
      shopName: shopName,
      queueCount: queueCount,
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
      centerArea: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CamCodeBadge(code: code),
            const SizedBox(height: 10),
            Text(duration, style: _t(30, FontWeight.w600, BrandColors.ink)),
            const SizedBox(height: 10),
            Text(linkNote, style: _t(12, FontWeight.w400, BrandColors.mut)),
          ],
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
    required this.shopName,
    required this.queueCount,
    required this.typeLabel,
    required this.resolutionLabel,
    required this.centerArea,
    this.headerTitle,
    this.preview,
    this.onBack,
    this.onPickType,
    this.onSettings,
    this.onFlipCamera,
    this.onManualEntry,
    this.onResolution,
    this.showStopButton = false,
    this.onStop,
  });

  final String shopName;
  final int queueCount;
  final String typeLabel;
  final String resolutionLabel;
  final Widget centerArea;

  /// Overrides the header text; the recording states use it to read "Ghi hình".
  final String? headerTitle;
  final Widget? preview;
  final VoidCallback? onBack;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onResolution;
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
          const Positioned.fill(child: _FramingCorners()),
          Positioned.fill(child: centerArea),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _CamHeader(
                title: headerTitle ?? shopName,
                queueCount: queueCount,
                onBack: onBack,
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

/// The four white framing brackets the design draws around the bill area.
class _FramingCorners extends StatelessWidget {
  const _FramingCorners();

  static const _topLeft = 'M2 34l0-26q0-6 6-6l26 0';
  static const _topRight = 'M0 2l26 0q6 0 6 6l0 26';
  static const _bottomLeft = 'M2 0l0 26q0 6 6 6l26 0';
  static const _bottomRight = 'M0 32l26 0q6 0 6-6l0-26';

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
    required this.title,
    required this.queueCount,
    this.onBack,
  });

  /// The shop name while idle; the design switches it to "Ghi hình" once a
  /// clip is rolling, so the screen states read apart at a glance.
  final String title;
  final int queueCount;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Row(
        children: [
          _Tap(
            onTap: onBack,
            tooltip: context.l10n.tooltipBack,
            child: PenBox(
              width: 42,
              height: 42,
              fill: const Color(0xBF161616),
              stroke: PenColors.mut,
              radius: 999,
              axis: PenAxis.row,
              main: MainAxisAlignment.center,
              cross: CrossAxisAlignment.center,
              children: const [
                Icon(
                  LucideIcons.chevronLeft,
                  size: 22,
                  color: PenColors.card,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PenText(
              title,
              size: 24,
              color: PenColors.card,
              weight: FontWeight.w800,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          _QueueChip(count: queueCount),
        ],
      ),
    );
  }
}

/// Live date/time readout under the header — lets the seller confirm the
/// clip's timestamp without leaving the camera screen.
class _LiveClock extends StatefulWidget {
  const _LiveClock();

  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = '${_two(now.day)}/${_two(now.month)}/${now.year}';
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(date, style: _t(12, FontWeight.w500, BrandColors.mut)),
      ),
    );
  }
}

class _QueueChip extends StatelessWidget {
  const _QueueChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      fill: const Color(0xBF161616),
      stroke: PenColors.mut,
      radius: 999,
      axis: PenAxis.row,
      gap: 8,
      cross: CrossAxisAlignment.center,
      hugMain: true,
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 15),
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
        PenText(
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
      child: PenBox(
        width: 86,
        height: 86,
        stroke: PenColors.card,
        strokeWidth: 5,
        radius: 999,
        axis: PenAxis.row,
        main: MainAxisAlignment.center,
        cross: CrossAxisAlignment.center,
        children: const [
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
      child: Padding(padding: const EdgeInsets.all(4), child: child),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}

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
    required this.timeRange,
    required this.status,
    this.id,
    this.progressPercent,
    this.retryCount,
    this.errorMessage,
  });

  /// Stable id used to route retry actions back to the queue.
  final String? id;

  final String code;
  final String typeLabel;
  final String timeRange;
  final EcUploadStatus status;
  final int? progressPercent;
  final int? retryCount;

  /// Human-readable reason the last attempt failed, only set for
  /// [EcUploadStatus.error] — shown under the retry count so a seller isn't
  /// left staring at an unexplained "Lỗi".
  final String? errorMessage;
}

/// Sample queue for previews/tests; production callers pass live queue data.
const List<EcUploadItem> ecDefaultUploadItems = [
  EcUploadItem(
    code: 'SPXVN024567890',
    typeLabel: 'Đóng hàng đi',
    timeRange: '02:45 - 10:23',
    status: EcUploadStatus.uploading,
    progressPercent: 72,
  ),
  EcUploadItem(
    code: 'SPXVN098765432',
    typeLabel: 'Đóng hàng đi',
    timeRange: '03:12 - 10:28',
    status: EcUploadStatus.waiting,
  ),
  EcUploadItem(
    code: 'SPXVN011122233',
    typeLabel: 'Đơn vị vận chuyển',
    timeRange: '01:05 - 10:40',
    status: EcUploadStatus.done,
  ),
  EcUploadItem(
    code: 'SPXVN044556677',
    typeLabel: 'Trả hàng',
    timeRange: '04:20 - 10:55',
    status: EcUploadStatus.error,
    retryCount: 2,
  ),
  EcUploadItem(
    code: 'SPXVN055667788',
    typeLabel: 'Đóng hàng đi',
    timeRange: '02:10 - 11:02',
    status: EcUploadStatus.quotaWait,
  ),
];

/// The upload queue list — quota banner, status tabs and per-video status.
class EcUploadQueueScreen extends StatelessWidget {
  const EcUploadQueueScreen({
    this.items = const [],
    this.selectedTabIndex = 0,
    this.onBack,
    this.onUpgrade,
    this.onTabSelected,
    this.onRetry,
    this.onPause,
    this.onResume,
    this.onDelete,
    super.key,
  });

  final List<EcUploadItem> items;
  final int selectedTabIndex;
  final VoidCallback? onBack;
  final VoidCallback? onUpgrade;
  final ValueChanged<int>? onTabSelected;

  /// Called with an errored item when its "Thử lại" affordance is tapped.
  final ValueChanged<EcUploadItem>? onRetry;

  /// Called with an item when its "Tạm dừng" affordance is tapped.
  final ValueChanged<EcUploadItem>? onPause;

  /// Called with a paused item when its "Tiếp tục" affordance is tapped.
  final ValueChanged<EcUploadItem>? onResume;

  /// Called with an item when its remove affordance is tapped.
  final ValueChanged<EcUploadItem>? onDelete;

  /// Items shown under the selected tab (0 = all, 1 = uploading, 2 = error).
  List<EcUploadItem> get _visibleItems => switch (selectedTabIndex) {
    1 => [
      for (final i in items)
        if (i.status == EcUploadStatus.uploading) i,
    ],
    2 => [
      for (final i in items)
        if (i.status == EcUploadStatus.error) i,
    ],
    _ => items,
  };

  List<String> _tabs(BuildContext context) {
    final uploading = items
        .where((i) => i.status == EcUploadStatus.uploading)
        .length;
    final errored = items.where((i) => i.status == EcUploadStatus.error).length;
    return [
      context.l10n.queueFilterAll(items.length),
      context.l10n.queueFilterUploading(uploading),
      context.l10n.queueFilterErrored(errored),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs(context);
    final visible = _visibleItems;
    final hasQuotaWait = items.any((i) => i.status == EcUploadStatus.quotaWait);
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Tap(
                    onTap: onBack,
                    child: const Icon(
                      Icons.chevron_left,
                      size: 20,
                      color: BrandColors.ink,
                    ),
                  ),
                  Text(
                    context.l10n.uploadQueueTitle,
                    style: _t(16, FontWeight.w600, BrandColors.ink),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Only real when something is actually waiting on quota —
                    // this used to render unconditionally, showing "out of
                    // quota" even when nothing was quota-blocked.
                    if (hasQuotaWait)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: BrandColors.soft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.l10n.quotaExhaustedNote,
                                style: _t(12, FontWeight.w400, BrandColors.ink),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: onUpgrade,
                              child: Text(
                                context.l10n.upgradePlanShort,
                                style: _t(12, FontWeight.w600, BrandColors.ink),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (hasQuotaWait) const SizedBox(height: 12),
                    SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: tabs.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return _UploadTab(
                            label: tabs[index],
                            selected: index == selectedTabIndex,
                            onTap: () => onTabSelected?.call(index),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: visible.isEmpty
                          ? Center(
                              child: Text(
                                context.l10n.queueEmpty,
                                style: _t(14, FontWeight.w400, BrandColors.mut),
                              ),
                            )
                          : ListView.separated(
                              itemCount: visible.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) => _UploadRow(
                                item: visible[index],
                                onRetry: onRetry,
                                onPause: onPause,
                                onResume: onResume,
                                onDelete: onDelete,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        context.l10n.queueAutoUploadNote,
                        style: _t(12, FontWeight.w400, BrandColors.mut),
                      ),
                    ),
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

class _UploadTab extends StatelessWidget {
  const _UploadTab({
    required this.label,
    required this.selected,
    this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: Container(
        decoration: ecSquircleDecoration(
          radius: 999,
          color: selected ? BrandColors.dark : BrandColors.bg,
          side: BorderSide(
            color: selected ? BrandColors.dark : BrandColors.line,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Text(
            label,
            style: _t(
              12,
              FontWeight.w500,
              selected ? Colors.white : BrandColors.mut,
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadRow extends StatelessWidget {
  const _UploadRow({
    required this.item,
    this.onRetry,
    this.onPause,
    this.onResume,
    this.onDelete,
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

  @override
  Widget build(BuildContext context) {
    final canPause =
        onPause != null &&
        (item.status == EcUploadStatus.waiting ||
            item.status == EcUploadStatus.error ||
            item.status == EcUploadStatus.quotaWait);
    final canResume = onResume != null && item.status == EcUploadStatus.paused;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ecSquircleDecoration(
        radius: 12,
        side: const BorderSide(color: BrandColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: BrandColors.soft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.videocam_outlined,
              size: 18,
              color: BrandColors.mut,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.code,
                  style: _t(14, FontWeight.w600, BrandColors.ink),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.typeLabel} · ${item.timeRange}',
                  overflow: TextOverflow.ellipsis,
                  style: _t(12, FontWeight.w400, BrandColors.mut),
                ),
                if (item.status == EcUploadStatus.error &&
                    item.errorMessage != null) ...[
                  const SizedBox(height: 3),
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
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: item.status == EcUploadStatus.error && onRetry != null
                ? () => onRetry!(item)
                : null,
            child: _UploadStatusView(item: item),
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
          if (onDelete != null)
            _RowIconButton(
              icon: Icons.delete_outline,
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

class _UploadStatusView extends StatelessWidget {
  const _UploadStatusView({required this.item});
  final EcUploadItem item;

  @override
  Widget build(BuildContext context) {
    return switch (item.status) {
      EcUploadStatus.uploading => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            context.l10n.uploadingProgress(item.progressPercent ?? 0),
            style: _t(12, FontWeight.w500, BrandColors.ink),
          ),
          const SizedBox(height: 4),
          Container(
            width: 70,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E2E2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (item.progressPercent ?? 0) / 100,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: BrandColors.dark,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
      EcUploadStatus.waiting => Text(
        context.l10n.waitingUpload,
        style: _t(12, FontWeight.w400, BrandColors.mut),
      ),
      EcUploadStatus.done => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.check, size: 12, color: BrandColors.ink),
          const SizedBox(width: 4),
          Text(
            context.l10n.uploaded,
            style: _t(12, FontWeight.w400, BrandColors.ink),
          ),
        ],
      ),
      EcUploadStatus.error => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.replay, size: 12, color: BrandColors.ink),
          const SizedBox(width: 4),
          Text(
            context.l10n.errorRetryCount(item.retryCount ?? 0),
            style: _t(12, FontWeight.w500, BrandColors.ink),
          ),
        ],
      ),
      EcUploadStatus.quotaWait => Text(
        context.l10n.waitingQuota,
        style: _t(12, FontWeight.w400, BrandColors.mut),
      ),
      EcUploadStatus.paused => Text(
        context.l10n.pausedUpload,
        style: _t(12, FontWeight.w400, BrandColors.mut),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _type(String digit) =>
      setState(() => _controller.text = _controller.text + digit);

  void _backspace() {
    final text = _controller.text;
    if (text.isEmpty) return;
    setState(() => _controller.text = text.substring(0, text.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: Stack(
        children: [
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
            // The design's `KeypadSheet`: 490pt tall, 14pt top corners,
            // padding [12, 22, 0, 22]. Its own keypad replaces the system
            // keyboard, so nothing has to shift for an inset.
            child: PenBox(
              width: double.infinity,
              fill: PenColors.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              axis: PenAxis.column,
              hugMain: true,
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
              children: [
                const Center(
                  child: PenBox(
                    width: 46,
                    height: 5,
                    fill: PenColors.line,
                    radius: 3,
                  ),
                ),
                const SizedBox(height: 14),
                PenText(
                  context.l10n.manualTrackingTitle,
                  size: 24,
                  color: PenColors.ink,
                  weight: FontWeight.w800,
                ),
                const SizedBox(height: 5),
                PenText(
                  context.l10n.manualTrackingNote,
                  size: 14,
                  color: PenColors.mut,
                ),
                const SizedBox(height: 14),
                PenBox(
                  width: double.infinity,
                  height: 58,
                  fill: PenColors.card,
                  stroke: PenColors.line,
                  radius: 14,
                  axis: PenAxis.row,
                  gap: 10,
                  cross: CrossAxisAlignment.center,
                  padding: const EdgeInsets.fromLTRB(18, 0, 8, 0),
                  children: [
                    Expanded(
                      child: PenText(
                        _controller.text.isEmpty ? 'SPXVN…' : _controller.text,
                        size: 18,
                        color: _controller.text.isEmpty
                            ? PenColors.mut
                            : PenColors.ink,
                        weight: FontWeight.w500,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    EcTap(
                      onTap: widget.onCancel,
                      child: const PenBox(
                        width: 44,
                        height: 44,
                        fill: PenColors.bg,
                        radius: 10,
                        axis: PenAxis.row,
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.scan,
                            size: 22,
                            color: PenColors.ink,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _Keypad(onDigit: _type, onBackspace: _backspace),
                const SizedBox(height: 14),
                EcTap(
                  onTap: () => widget.onManualSubmit?.call(_controller.text),
                  child: PenBox(
                    width: double.infinity,
                    height: 56,
                    fill: PenColors.primary,
                    radius: 14,
                    axis: PenAxis.row,
                    main: MainAxisAlignment.center,
                    cross: CrossAxisAlignment.center,
                    children: [
                      PenText(
                        context.l10n.commonDone,
                        size: 18,
                        color: PenColors.card,
                        weight: FontWeight.w700,
                        softWrap: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.paddingOf(context).bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The design's 3x4 phone keypad: digits with their letter groups, an empty
/// slot and a filled backspace key.
class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  static const _rows = <List<(String, String)>>[
    [('1', ''), ('2', 'ABC'), ('3', 'DEF')],
    [('4', 'GHI'), ('5', 'JKL'), ('6', 'MNO')],
    [('7', 'PQRS'), ('8', 'TUV'), ('9', 'WXYZ')],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _rows) ...[
          Row(
            children: [
              for (final (digit, letters) in row) ...[
                if (digit != row.first.$1) const SizedBox(width: 8),
                Expanded(
                  child: _Key(
                    digit: digit,
                    letters: letters,
                    onTap: () => onDigit(digit),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            const Expanded(child: SizedBox(height: 52)),
            const SizedBox(width: 8),
            Expanded(
              child: _Key(digit: '0', onTap: () => onDigit('0')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: EcTap(
                onTap: onBackspace,
                child: const PenBox(
                  height: 52,
                  fill: PenColors.line,
                  radius: 10,
                  axis: PenAxis.row,
                  main: MainAxisAlignment.center,
                  cross: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.delete,
                      size: 24,
                      color: PenColors.card,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.digit, required this.onTap, this.letters = ''});

  final String digit;
  final String letters;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: PenBox(
        height: 52,
        fill: PenColors.card,
        stroke: PenColors.line,
        radius: 10,
        axis: PenAxis.column,
        main: MainAxisAlignment.center,
        cross: CrossAxisAlignment.center,
        children: [
          PenText(
            digit,
            size: 20,
            color: PenColors.ink,
            weight: FontWeight.w600,
            softWrap: false,
          ),
          if (letters.isNotEmpty)
            PenText(letters, size: 12, color: PenColors.mut, softWrap: false),
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
    this.returnCode = 'SPXVN099988877',
    this.shopName = 'Shop ABC',
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
    return ColoredBox(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: const ColoredBox(color: Colors.black54),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: DecoratedBox(
                decoration: ecSquircleDecoration(
                  radius: 16,
                  color: BrandColors.bg,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.l10n.returnCodeMismatch,
                        style: _t(16, FontWeight.w600, BrandColors.ink),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.returnCodeMismatchBody(
                          returnCode,
                          shopName,
                        ),
                        style: _t(14, FontWeight.w400, BrandColors.mut),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _OutlineButton(
                              label: context.l10n.enterCodeManually,
                              onPressed: onEnterManually,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PrimaryButton(
                              label: context.l10n.createOrderConfirm,
                              onPressed: onCreateNew,
                            ),
                          ),
                        ],
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

// --- TypeSheet ---------------------------------------------------------

/// A selectable video type shown in [EcTypeSheetScreen].
class EcVideoType {
  const EcVideoType({
    required this.label,
    required this.icon,
    this.locked = false,
  });

  final String label;
  final IconData icon;

  /// Built-in types are locked — they can't be renamed/removed (only
  /// managed from Chi tiết shop).
  final bool locked;
}

/// Built-in video types; production callers append live custom types by shop.
const List<EcVideoType> ecDefaultVideoTypes = [
  EcVideoType(
    label: 'Đóng hàng',
    icon: Icons.inventory_2_outlined,
    locked: true,
  ),
  EcVideoType(
    label: 'ĐV vận chuyển',
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
    super.key,
  });

  final List<EcVideoType> types;
  final String selectedType;
  final ValueChanged<String>? onSelectType;
  final VoidCallback? onManageTypes;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: const ColoredBox(color: Colors.black54),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: BrandColors.bg,
                  shape: SmoothRectangleBorder(
                    smoothness: ecCornerSmoothing,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SheetHandle(),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 6, 4, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.videoTypeLabel,
                              style: _t(16, FontWeight.w600, BrandColors.ink),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.l10n.videoTypeSelectNote,
                              style: _t(12, FontWeight.w400, BrandColors.mut),
                            ),
                          ],
                        ),
                      ),
                      for (final type in types)
                        _TypeSheetRow(
                          type: type,
                          selected: type.label == selectedType,
                          onTap: () => onSelectType?.call(type.label),
                        ),
                      const SizedBox(height: 4),
                      _ManageRow(onTap: onManageTypes),
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

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: BrandColors.line,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
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
    return EcTap(
      onTap: onTap,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: BrandColors.line)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
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
                        type.label,
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
