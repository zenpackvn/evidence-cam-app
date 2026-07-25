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

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

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
    this.zoomLabel = '1x',
    this.resolutionLabel = '720p',
    this.preview,
    this.onBack,
    this.onPickType,
    this.onSettings,
    this.onZoomIn,
    this.onZoomOut,
    this.onFlipCamera,
    this.onManualEntry,
    this.onNavOrders,
    this.onNavAccount,
    super.key,
  });

  final String shopName;
  final int queueCount;
  final String typeLabel;
  final String zoomLabel;
  final String resolutionLabel;

  /// Live camera preview rendered full-bleed behind the overlay; a black
  /// placeholder is shown when `null` (design mock / no camera).
  final Widget? preview;
  final VoidCallback? onBack;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onNavOrders;
  final VoidCallback? onNavAccount;

  @override
  Widget build(BuildContext context) {
    return _CamScaffold(
      shopName: shopName,
      queueCount: queueCount,
      typeLabel: typeLabel,
      zoomLabel: zoomLabel,
      resolutionLabel: resolutionLabel,
      preview: preview,
      onBack: onBack,
      onPickType: onPickType,
      onSettings: onSettings,
      onZoomIn: onZoomIn,
      onZoomOut: onZoomOut,
      onFlipCamera: onFlipCamera,
      onManualEntry: onManualEntry,
      onNavOrders: onNavOrders,
      onNavAccount: onNavAccount,
      centerArea: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 28, color: BrandColors.mut),
            const SizedBox(height: 10),
            Text(
              'Đưa bill vào khung để bắt đầu',
              style: _t(14, FontWeight.w500, BrandColors.ink),
            ),
            const SizedBox(height: 10),
            Text(
              'Camera nhìn xuống bàn',
              style: _t(12, FontWeight.w400, BrandColors.mut),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Recording2 ---------------------------------------------------------

/// Active recording screen — mã vận đơn badge, elapsed duration and REC dot.
class EcRecording2Screen extends StatelessWidget {
  const EcRecording2Screen({
    this.shopName = 'Shop ABC',
    this.queueCount = 3,
    this.code = 'SPXVN024567890',
    this.duration = '02:45',
    this.typeLabel = 'Đóng hàng',
    this.zoomLabel = '1x',
    this.resolutionLabel = '720p',
    this.preview,
    this.onBack,
    this.onPickType,
    this.onSettings,
    this.onZoomIn,
    this.onZoomOut,
    this.onFlipCamera,
    this.onManualEntry,
    this.onNavOrders,
    this.onNavAccount,
    this.onStop,
    super.key,
  });

  final String shopName;
  final int queueCount;
  final String code;
  final String duration;
  final String typeLabel;
  final String zoomLabel;
  final String resolutionLabel;

  /// Live camera preview rendered full-bleed behind the overlay; a black
  /// placeholder is shown when `null` (design mock / no camera).
  final Widget? preview;
  final VoidCallback? onBack;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onNavOrders;
  final VoidCallback? onNavAccount;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return _CamScaffold(
      shopName: shopName,
      queueCount: queueCount,
      typeLabel: typeLabel,
      zoomLabel: zoomLabel,
      resolutionLabel: resolutionLabel,
      preview: preview,
      onBack: onBack,
      onPickType: onPickType,
      onSettings: onSettings,
      onZoomIn: onZoomIn,
      onZoomOut: onZoomOut,
      onFlipCamera: onFlipCamera,
      onManualEntry: onManualEntry,
      onNavOrders: onNavOrders,
      onNavAccount: onNavAccount,
      showStopButton: true,
      onStop: onStop,
      centerArea: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CamCodeBadge(code: code),
            const SizedBox(height: 10),
            Text(duration, style: _t(28, FontWeight.w700, BrandColors.ink)),
            const SizedBox(height: 10),
            const _RecRow(),
          ],
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
    this.closedSummary = 'Đã chốt đơn A (02:45)',
    this.signalText = 'Âm báo + rung khi chuyển đơn',
    this.newCode = 'SPXVN098765432',
    this.newDuration = '00:01',
    this.typeLabel = 'Đóng hàng',
    this.zoomLabel = '1x',
    this.resolutionLabel = '720p',
    this.onBack,
    this.onPickType,
    this.onSettings,
    this.onZoomIn,
    this.onZoomOut,
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
  final String zoomLabel;
  final String resolutionLabel;
  final VoidCallback? onBack;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return _CamScaffold(
      shopName: shopName,
      queueCount: queueCount,
      typeLabel: typeLabel,
      zoomLabel: zoomLabel,
      resolutionLabel: resolutionLabel,
      onBack: onBack,
      onPickType: onPickType,
      onSettings: onSettings,
      onZoomIn: onZoomIn,
      onZoomOut: onZoomOut,
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
                const Icon(Icons.check, size: 16, color: BrandColors.ink),
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
            Text(signalText, style: _t(11, FontWeight.w400, BrandColors.mut)),
            const SizedBox(height: 10),
            _CamCodeBadge(code: newCode),
            const SizedBox(height: 10),
            Text(
              newDuration,
              style: _t(28, FontWeight.w700, BrandColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NearLimit ---------------------------------------------------------

/// Recording screen showing the 15-minute cap warning banner.
class EcNearLimitScreen extends StatelessWidget {
  const EcNearLimitScreen({
    this.shopName = 'Shop ABC',
    this.queueCount = 3,
    this.warningText = 'Sắp chạm trần 15 phút — video sẽ tự chốt',
    this.code = 'SPXVN024567890',
    this.duration = '14:12',
    this.typeLabel = 'Đóng hàng',
    this.zoomLabel = '1x',
    this.resolutionLabel = '720p',
    this.onBack,
    this.onPickType,
    this.onSettings,
    this.onZoomIn,
    this.onZoomOut,
    this.onFlipCamera,
    this.onManualEntry,
    this.onStop,
    super.key,
  });

  final String shopName;
  final int queueCount;
  final String warningText;
  final String code;
  final String duration;
  final String typeLabel;
  final String zoomLabel;
  final String resolutionLabel;
  final VoidCallback? onBack;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return _CamScaffold(
      shopName: shopName,
      queueCount: queueCount,
      typeLabel: typeLabel,
      zoomLabel: zoomLabel,
      resolutionLabel: resolutionLabel,
      onBack: onBack,
      onPickType: onPickType,
      onSettings: onSettings,
      onZoomIn: onZoomIn,
      onZoomOut: onZoomOut,
      onFlipCamera: onFlipCamera,
      onManualEntry: onManualEntry,
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
                      style: _t(28, FontWeight.w700, BrandColors.ink),
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
    this.linkNote = 'Tự liên kết về hồ sơ đơn gốc',
    this.typeLabel = 'Trả hàng',
    this.zoomLabel = '1x',
    this.resolutionLabel = '720p',
    this.onBack,
    this.onPickType,
    this.onSettings,
    this.onZoomIn,
    this.onZoomOut,
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
  final String zoomLabel;
  final String resolutionLabel;
  final VoidCallback? onBack;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return _CamScaffold(
      shopName: shopName,
      queueCount: queueCount,
      typeLabel: typeLabel,
      zoomLabel: zoomLabel,
      resolutionLabel: resolutionLabel,
      onBack: onBack,
      onPickType: onPickType,
      onSettings: onSettings,
      onZoomIn: onZoomIn,
      onZoomOut: onZoomOut,
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
            Text(duration, style: _t(28, FontWeight.w700, BrandColors.ink)),
            const SizedBox(height: 10),
            Text(linkNote, style: _t(11, FontWeight.w400, BrandColors.mut)),
          ],
        ),
      ),
    );
  }
}

// --- shared camera-screen chrome ---------------------------------------

/// Full-bleed black preview + floating chrome shared by every Flow 3
/// recording screen (header, right-hand rail, type chip, bottom nav and the
/// optional stop button).
class _CamScaffold extends StatelessWidget {
  const _CamScaffold({
    required this.shopName,
    required this.queueCount,
    required this.typeLabel,
    required this.zoomLabel,
    required this.resolutionLabel,
    required this.centerArea,
    this.preview,
    this.onBack,
    this.onPickType,
    this.onSettings,
    this.onZoomIn,
    this.onZoomOut,
    this.onFlipCamera,
    this.onManualEntry,
    this.onNavOrders,
    this.onNavAccount,
    this.showStopButton = false,
    this.onStop,
  });

  final String shopName;
  final int queueCount;
  final String typeLabel;
  final String zoomLabel;
  final String resolutionLabel;
  final Widget centerArea;
  final Widget? preview;
  final VoidCallback? onBack;
  final VoidCallback? onPickType;
  final VoidCallback? onSettings;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;
  final VoidCallback? onNavOrders;
  final VoidCallback? onNavAccount;
  final bool showStopButton;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: preview ?? const ColoredBox(color: Colors.black),
          ),
          Positioned.fill(child: centerArea),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _CamHeader(
                shopName: shopName,
                queueCount: queueCount,
                onBack: onBack,
              ),
            ),
          ),
          // Right rail — anchored to the right edge, lower-middle (responsive
          // instead of a hardcoded top offset calibrated to an 844pt canvas).
          Positioned.fill(
            child: Align(
              alignment: const Alignment(1, 0.25),
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _CamRail(
                  zoomLabel: zoomLabel,
                  resolutionLabel: resolutionLabel,
                  onZoomIn: onZoomIn,
                  onZoomOut: onZoomOut,
                  onFlipCamera: onFlipCamera,
                  onManualEntry: onManualEntry,
                ),
              ),
            ),
          ),
          // Stop button — a fixed gap above the chip/nav cluster (responsive).
          if (showStopButton)
            Positioned(
              left: 0,
              right: 0,
              bottom: 120,
              child: Center(child: _StopButton(onTap: onStop)),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _TypeChipRow(
                        typeLabel: typeLabel,
                        onPickType: onPickType,
                        onSettings: onSettings,
                      ),
                    ),
                  ),
                  _BottomNav(
                    onOrders: onNavOrders,
                    onAccount: onNavAccount,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CamHeader extends StatelessWidget {
  const _CamHeader({
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          _Tap(
            onTap: onBack,
            tooltip: 'Quay lại',
            child: const Icon(
              Icons.chevron_left,
              size: 20,
              color: BrandColors.ink,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              shopName,
              overflow: TextOverflow.ellipsis,
              style: _t(15, FontWeight.w600, BrandColors.ink),
            ),
          ),
          const SizedBox(width: 8),
          _QueueChip(count: queueCount),
        ],
      ),
    );
  }
}

class _QueueChip extends StatelessWidget {
  const _QueueChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: BrandColors.soft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_outlined, size: 14, color: BrandColors.ink),
          const SizedBox(width: 4),
          Text('$count', style: _t(12, FontWeight.w600, BrandColors.ink)),
        ],
      ),
    );
  }
}

class _CamCodeBadge extends StatelessWidget {
  const _CamCodeBadge({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: BrandColors.dark,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(code, style: _t(14, FontWeight.w600, Colors.white)),
    );
  }
}

class _RecRow extends StatelessWidget {
  const _RecRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: BrandColors.rec,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text('REC', style: _t(11, FontWeight.w600, BrandColors.mut)),
      ],
    );
  }
}

class _CamRail extends StatelessWidget {
  const _CamRail({
    required this.zoomLabel,
    required this.resolutionLabel,
    this.onZoomIn,
    this.onZoomOut,
    this.onFlipCamera,
    this.onManualEntry,
  });

  final String zoomLabel;
  final String resolutionLabel;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onManualEntry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ZoomControl(
          label: zoomLabel,
          onZoomIn: onZoomIn,
          onZoomOut: onZoomOut,
        ),
        const SizedBox(height: 10),
        _RailPill(label: resolutionLabel),
        const SizedBox(height: 10),
        _RailIconButton(
          icon: Icons.flip_camera_ios_outlined,
          tooltip: 'Đổi camera',
          onTap: onFlipCamera,
        ),
        const SizedBox(height: 10),
        _RailIconButton(
          icon: Icons.keyboard_outlined,
          tooltip: 'Nhập mã vận đơn',
          onTap: onManualEntry,
        ),
      ],
    );
  }
}

class _ZoomControl extends StatelessWidget {
  const _ZoomControl({required this.label, this.onZoomIn, this.onZoomOut});
  final String label;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: BrandColors.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Tap(
            onTap: onZoomIn,
            tooltip: 'Phóng to',
            child: const Icon(Icons.add, size: 14, color: BrandColors.ink),
          ),
          const SizedBox(height: 12),
          Text(label, style: _t(11, FontWeight.w600, BrandColors.ink)),
          const SizedBox(height: 12),
          _Tap(
            onTap: onZoomOut,
            tooltip: 'Thu nhỏ',
            child: const Icon(Icons.remove, size: 14, color: BrandColors.ink),
          ),
        ],
      ),
    );
  }
}

class _RailPill extends StatelessWidget {
  const _RailPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 9),
      decoration: BoxDecoration(
        color: BrandColors.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: _t(11, FontWeight.w600, BrandColors.ink)),
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
    return Tooltip(
      message: tooltip,
      child: Material(
        color: BrandColors.bg,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 16, color: BrandColors.ink),
          ),
        ),
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Dừng quay',
      child: Material(
        color: BrandColors.bg,
        shape: const CircleBorder(side: BorderSide(color: BrandColors.line)),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 64,
            height: 64,
            child: Center(
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: BrandColors.rec,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
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
    return Row(
      children: [
        Flexible(
          child: Material(
            color: BrandColors.dark,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: onPickType,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 10,
                ),
                child: Text(
                  typeLabel,
                  overflow: TextOverflow.ellipsis,
                  style: _t(12, FontWeight.w500, Colors.white),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Cài đặt loại video',
          child: Material(
            color: BrandColors.bg,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: BrandColors.line),
              borderRadius: BorderRadius.circular(999),
            ),
            child: InkWell(
              onTap: onSettings,
              borderRadius: BorderRadius.circular(999),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Icon(
                  Icons.settings_outlined,
                  size: 14,
                  color: BrandColors.ink,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({this.onOrders, this.onAccount});

  final VoidCallback? onOrders;
  final VoidCallback? onAccount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: BrandColors.bg,
        border: Border(top: BorderSide(color: BrandColors.line)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              // Opaque so the whole cell is tappable, with no layout shift from
              // the pixel-perfect design (unlike a padded tap wrapper).
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onOrders,
                child: const _NavItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Đơn hàng',
                ),
              ),
            ),
            const Expanded(
              child: _NavItem(
                icon: Icons.camera_alt_outlined,
                label: 'Ghi hình',
                active: true,
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onAccount,
                child: const _NavItem(
                  icon: Icons.person_outline,
                  label: 'Tài khoản',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });
  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? BrandColors.ink : BrandColors.mut;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 5),
        Text(
          label,
          style: _t(12, active ? FontWeight.w600 : FontWeight.w400, color),
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
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(padding: const EdgeInsets.all(4), child: child),
      ),
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
  });

  /// Stable id used to route retry actions back to the queue; `null` for the
  /// static sample data.
  final String? id;

  final String code;
  final String typeLabel;
  final String timeRange;
  final EcUploadStatus status;
  final int? progressPercent;
  final int? retryCount;
}

/// Sample queue matching the design mock 1:1.
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
    this.items = ecDefaultUploadItems,
    this.selectedTabIndex = 0,
    this.onBack,
    this.onUpgrade,
    this.onTabSelected,
    this.onRetry,
    super.key,
  });

  final List<EcUploadItem> items;
  final int selectedTabIndex;
  final VoidCallback? onBack;
  final VoidCallback? onUpgrade;
  final ValueChanged<int>? onTabSelected;

  /// Called with an errored item when its "Thử lại" affordance is tapped.
  final ValueChanged<EcUploadItem>? onRetry;

  /// Items shown under the selected tab (0 = all, 1 = uploading, 2 = error).
  List<EcUploadItem> get _visibleItems => switch (selectedTabIndex) {
    1 => [for (final i in items) if (i.status == EcUploadStatus.uploading) i],
    2 => [for (final i in items) if (i.status == EcUploadStatus.error) i],
    _ => items,
  };

  List<String> get _tabs {
    final uploading = items
        .where((i) => i.status == EcUploadStatus.uploading)
        .length;
    final errored = items.where((i) => i.status == EcUploadStatus.error).length;
    return [
      'Tất cả · ${items.length}',
      'Đang tải · $uploading',
      'Lỗi · $errored',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;
    final visible = _visibleItems;
    return Scaffold(
      backgroundColor: BrandColors.bg,
      body: SafeArea(
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
                    'Hàng đợi upload',
                    style: _t(17, FontWeight.w600, BrandColors.ink),
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
                              'Hết quota tháng này — video sẽ chờ quota',
                              style: _t(12, FontWeight.w400, BrandColors.ink),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onUpgrade,
                            child: Text(
                              'Nâng gói',
                              style: _t(12, FontWeight.w600, BrandColors.ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
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
                                'Chưa có video trong hàng đợi',
                                style: _t(13, FontWeight.w400, BrandColors.mut),
                              ),
                            )
                          : ListView.separated(
                              itemCount: visible.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) => _UploadRow(
                                item: visible[index],
                                onRetry: onRetry,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Upload khi có mạng sẽ được tự động thực hiện',
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
    return Material(
      color: selected ? BrandColors.dark : BrandColors.bg,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? BrandColors.dark : BrandColors.line,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
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
  const _UploadRow({required this.item, this.onRetry});
  final EcUploadItem item;
  final ValueChanged<EcUploadItem>? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(12),
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
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: item.status == EcUploadStatus.error && onRetry != null
                ? () => onRetry!(item)
                : null,
            child: _UploadStatusView(item: item),
          ),
        ],
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
            'Đang tải ${item.progressPercent}%',
            style: _t(11, FontWeight.w500, BrandColors.ink),
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
        'Chờ upload',
        style: _t(11, FontWeight.w400, BrandColors.mut),
      ),
      EcUploadStatus.done => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 12, color: BrandColors.ink),
          const SizedBox(width: 4),
          Text('Đã upload', style: _t(11, FontWeight.w400, BrandColors.ink)),
        ],
      ),
      EcUploadStatus.error => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.replay, size: 12, color: BrandColors.ink),
          const SizedBox(width: 4),
          Text(
            'Lỗi · Thử lại (${item.retryCount})',
            style: _t(11, FontWeight.w500, BrandColors.ink),
          ),
        ],
      ),
      EcUploadStatus.quotaWait => Text(
        'Chờ quota',
        style: _t(11, FontWeight.w400, BrandColors.mut),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onCancel,
              child: const ColoredBox(color: Colors.black54),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Material(
                color: BrandColors.bg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SheetHandle(),
                      const SizedBox(height: 12),
                      Text(
                        'Nhập tay mã vận đơn',
                        style: _t(16, FontWeight.w600, BrandColors.ink),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Dùng khi bill mờ — không quá 10 giây',
                        style: _t(12, FontWeight.w400, BrandColors.mut),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _controller,
                        style: _t(15, FontWeight.w400, BrandColors.ink),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'SPXVN…',
                          hintStyle: _t(15, FontWeight.w400, BrandColors.mut),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: BrandColors.line,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: BrandColors.dark,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _OutlineButton(
                              label: 'Hủy',
                              onPressed: widget.onCancel,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PrimaryButton(
                              label: 'Bắt đầu quay',
                              onPressed: () =>
                                  widget.onManualSubmit?.call(_controller.text),
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
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
              child: Material(
                color: BrandColors.bg,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Mã hoàn không khớp',
                        style: _t(16, FontWeight.w700, BrandColors.ink),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$returnCode không khớp đơn nào trong $shopName. '
                        'Kiểm tra lại mã, nhập tay hoặc xác nhận tạo đơn mới.',
                        style: _t(13, FontWeight.w400, BrandColors.mut),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _OutlineButton(
                              label: 'Nhập tay mã',
                              onPressed: onEnterManually,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PrimaryButton(
                              label: 'Tạo đơn mới',
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

/// The 5 default video types shown in the design mock (3 locked defaults +
/// 2 shop-manageable ones).
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
  EcVideoType(label: 'Cân hàng', icon: Icons.monitor_weight_outlined),
  EcVideoType(
    label: 'Kiểm đếm sản phẩm',
    icon: Icons.fact_check_outlined,
  ),
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
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
              child: Material(
                color: BrandColors.bg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
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
                              'Loại video',
                              style: _t(16, FontWeight.w600, BrandColors.ink),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Chọn loại cho phiên quay — thêm/sửa/xóa trong '
                              'Chi tiết shop',
                              style: _t(11, FontWeight.w400, BrandColors.mut),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: BrandColors.line)),
          ),
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
                    const Icon(Icons.check, size: 16, color: BrandColors.ink),
                    const SizedBox(width: 10),
                  ],
                  if (type.locked)
                    const Icon(
                      Icons.lock_outline,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                  'Quản lý loại video — mở Chi tiết shop',
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
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: BrandColors.dark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _t(16, FontWeight.w600, Colors.white),
        ),
        child: Text(label),
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
    return Material(
      color: BrandColors.bg,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: BrandColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 52,
          child: Center(
            child: Text(label, style: _t(16, FontWeight.w500, BrandColors.ink)),
          ),
        ),
      ),
    );
  }
}
