import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:localization/localization.dart';
import 'package:shared_contracts/shared_contracts.dart';

/// Cài đặt quay của CỬA HÀNG — bản app của thẻ cùng tên trên web.
///
/// Một màn riêng chứ không phải thêm mười bốn hàng vào Chi tiết cửa hàng: màn
/// đó đã dài, và mười bốn hàng nhãn-kèm-công-tắc chen vào giữa loại video với
/// thành viên thì cả ba mục đều khó tìm.
///
/// Không có nút Lưu: mỗi ô ghi ngay khi đổi. Mười bốn ô mà một nút Lưu chung
/// thì người dùng gạt bốn ô rồi quên bấm, và không có gì trên màn nói rằng ba ô
/// kia chưa có hiệu lực.
class EcCaiDatQuayScreen extends StatefulWidget {
  const EcCaiDatQuayScreen({
    required this.caiDat,
    required this.onDoi,
    this.onBack,
    this.readOnly = false,
    super.key,
  });

  final EcCaiDatQuay caiDat;

  /// Gọi với CẢ bộ cài đặt sau khi đổi. Bên gọi tự lo gửi lên máy chủ và tự lo
  /// nuốt lỗi mạng — màn này không biết gì về mạng.
  final ValueChanged<EcCaiDatQuay> onDoi;

  final VoidCallback? onBack;

  /// Nhân viên xem được nhưng không đổi được: máy của họ chạy theo các cài đặt
  /// này, nên giấu hẳn màn đi là họ không có cách nào biết vì sao máy mình quay
  /// khác máy người bên cạnh.
  final bool readOnly;

  @override
  State<EcCaiDatQuayScreen> createState() => _EcCaiDatQuayScreenState();
}

class _EcCaiDatQuayScreenState extends State<EcCaiDatQuayScreen> {
  late EcCaiDatQuay _c = widget.caiDat;

  @override
  void didUpdateWidget(EcCaiDatQuayScreen old) {
    super.didUpdateWidget(old);
    // Bên gọi tải lại từ máy chủ thì lấy bản mới. Không có dòng này thì màn giữ
    // mãi bản chụp lúc mở, và một lượt ghi hỏng vẫn hiện như đã thành công.
    if (old.caiDat != widget.caiDat) _c = widget.caiDat;
  }

  void _dat(EcCaiDatQuay moi) {
    // Lớp phòng thân, KHÔNG phải thứ bài test đo được: mọi ô ở chế độ chỉ-đọc
    // đã có `onChanged: null` / `onTap: null` nên chúng không gọi tới đây. Bỏ
    // dòng này đi thì mọi ca vẫn xanh (đã thử bằng đột biến). Giữ lại vì hàng
    // rào thật nằm rải ở mười bốn ô, và quên `readOnly` ở một ô mới thêm là
    // nhân viên đổi được cài đặt của cả cửa hàng.
    if (widget.readOnly) return;
    setState(() => _c = moi);
    widget.onDoi(moi);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenScreen(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                PenBackButton(onTap: widget.onBack),
                const SizedBox(width: 12),
                Expanded(
                  child: PenText(
                    l10n.capTitle,
                    size: 24,
                    color: PenColors.ink,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            PenText(
              widget.readOnly ? l10n.capOwnerOnly : l10n.capHint,
              size: 13,
              color: PenColors.mut,
            ),
            const SizedBox(height: 12),

            _HangMuc(
              icon: LucideIcons.gauge,
              nhan: l10n.capFps,
              goiY: l10n.capFpsHint,
              donVi: 'FPS',
              giaTri: _c.fps,
              choPhepTrong: true,
              // Bốn mức phủ gần hết nhu cầu thật: 24 là mức phim, 30 là mặc định
              // của phần lớn máy, 60 cho chuyển động nhanh, 15 khi cần tệp nhẹ.
              muc: [
                (null, l10n.capAuto),
                (15, '15 FPS'),
                (24, '24 FPS'),
                (30, '30 FPS'),
                (60, '60 FPS'),
              ],
              readOnly: widget.readOnly,
              // `null` ở đây là một giá trị CÓ NGHĨA ("để máy tự chọn"), nên phải
              // đi qua cờ xoá riêng — `fps: null` trong `copyWith` nghĩa là "không
              // đụng tới".
              onDoi: (v) => _dat(
                v == null ? _c.copyWith(xoaFps: true) : _c.copyWith(fps: v),
              ),
            ),
            _HangChon(
              icon: LucideIcons.scanLine,
              nhan: l10n.capScanKind,
              goiY: l10n.capScanHint,
              giaTri: _c.kieuQuet,
              readOnly: widget.readOnly,
              chon: [
                ('both', l10n.capScanBoth),
                ('qr', l10n.capScanQr),
                ('barcode', l10n.capScanBar),
              ],
              onDoi: (v) => _dat(_c.copyWith(kieuQuet: v)),
            ),
            _HangMuc(
              icon: LucideIcons.alarmClock,
              nhan: l10n.capEndDelay,
              goiY: l10n.capEndDelayHint,
              // Mức ghi bằng GIÂY cho người đọc, nhưng lưu bằng mili giây: mặc định
              // 900ms không viết được bằng số giây tròn, và làm tròn lên 1 giây là
              // âm thầm đổi hành vi của mọi cửa hàng chưa đụng tới ô này.
              donVi: l10n.capMs,
              giaTri: _c.choTruocKhiKetThucMs,
              muc: [
                (900, '0,9 ${l10n.capSecond} ${l10n.capDefaultSuffix}'),
                (2000, '2 ${l10n.capSecond}'),
                (4000, '4 ${l10n.capSecond}'),
                (6000, '6 ${l10n.capSecond}'),
              ],
              readOnly: widget.readOnly,
              onDoi: (v) => _dat(_c.copyWith(choTruocKhiKetThucMs: v ?? 0)),
            ),
            _HangMuc(
              icon: LucideIcons.timer,
              nhan: l10n.capRearm,
              goiY: l10n.capRearmHint,
              donVi: l10n.capMs,
              giaTri: _c.choTruocKhiQuetMoiMs,
              muc: [
                (0, l10n.capOff),
                (2000, '2 ${l10n.capSecond}'),
                (5000, '5 ${l10n.capSecond} ${l10n.capDefaultSuffix}'),
                (8000, '8 ${l10n.capSecond}'),
                (15000, '15 ${l10n.capSecond}'),
              ],
              readOnly: widget.readOnly,
              onDoi: (v) => _dat(_c.copyWith(choTruocKhiQuetMoiMs: v ?? 0)),
            ),
            _HangMuc(
              icon: LucideIcons.circlePlus,
              nhan: l10n.capTail,
              goiY: l10n.capTailHint,
              donVi: l10n.capSecond,
              giaTri: _c.quayThemGiay,
              muc: [
                (0, '${l10n.capOff} ${l10n.capDefaultSuffix}'),
                (2, '2 ${l10n.capSecond}'),
                (3, '3 ${l10n.capSecond}'),
                (5, '5 ${l10n.capSecond}'),
                (10, '10 ${l10n.capSecond}'),
              ],
              readOnly: widget.readOnly,
              onDoi: (v) => _dat(_c.copyWith(quayThemGiay: v ?? 0)),
            ),

            _HangGat(
              icon: LucideIcons.mic,
              nhan: l10n.capAudio,
              goiY: l10n.capAudioHint,
              bat: _c.quayCoAmThanh,
              readOnly: widget.readOnly,
              onDoi: (v) => _dat(_c.copyWith(quayCoAmThanh: v)),
            ),
            _HangGat(
              icon: LucideIcons.audioLines,
              nhan: l10n.capStatusSound,
              goiY: l10n.capStatusSoundHint,
              bat: _c.amThanhTrangThai,
              readOnly: widget.readOnly,
              onDoi: (v) => _dat(_c.copyWith(amThanhTrangThai: v)),
            ),
            _HangGat(
              icon: LucideIcons.videotape,
              nhan: l10n.capAutoConfig,
              goiY: l10n.capAutoConfigHint,
              bat: _c.tuCauHinhVideo,
              readOnly: widget.readOnly,
              onDoi: (v) => _dat(_c.copyWith(tuCauHinhVideo: v)),
            ),
            _HangGat(
              icon: LucideIcons.batteryLow,
              nhan: l10n.capBattery,
              goiY: l10n.capBatteryHint,
              bat: _c.tietKiemPin,
              readOnly: widget.readOnly,
              onDoi: (v) => _dat(_c.copyWith(tietKiemPin: v)),
            ),
            _HangGat(
              icon: LucideIcons.wifi,
              nhan: l10n.capWifi,
              goiY: l10n.capWifiHint,
              bat: _c.chiTaiKhiWifi,
              readOnly: widget.readOnly,
              onDoi: (v) => _dat(_c.copyWith(chiTaiKhiWifi: v)),
            ),
            _HangGat(
              icon: LucideIcons.scanQrCode,
              nhan: l10n.capEndOther,
              goiY: l10n.capEndOtherHint,
              bat: _c.ketThucBangMaKhac,
              readOnly: widget.readOnly,
              onDoi: (v) => _dat(_c.copyWith(ketThucBangMaKhac: v)),
            ),
            _HangGat(
              icon: LucideIcons.eyeOff,
              nhan: l10n.capManualStop,
              goiY: l10n.capManualStopHint,
              bat: _c.chiDungBangNut,
              readOnly: widget.readOnly,
              onDoi: (v) => _dat(_c.copyWith(chiDungBangNut: v)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Khung extends StatelessWidget {
  const _Khung({
    required this.icon,
    required this.nhan,
    required this.goiY,
    required this.dieuKhien,
  });

  final IconData icon;
  final String nhan;
  final String goiY;
  final Widget dieuKhien;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: PenColors.line)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: PenColors.ink),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                PenText(nhan, size: 16, color: PenColors.ink),
                if (goiY.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  PenText(goiY, size: 13, color: PenColors.mut),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          dieuKhien,
        ],
      ),
    );
  }
}

class _HangGat extends StatelessWidget {
  const _HangGat({
    required this.icon,
    required this.nhan,
    required this.goiY,
    required this.bat,
    required this.onDoi,
    required this.readOnly,
  });

  final IconData icon;
  final String nhan;
  final String goiY;
  final bool bat;
  final ValueChanged<bool> onDoi;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return _Khung(
      icon: icon,
      nhan: nhan,
      goiY: goiY,
      dieuKhien: Semantics(
        label: nhan,
        toggled: bat,
        child: CupertinoSwitch(
          value: bat,
          onChanged: readOnly ? null : onDoi,
          activeTrackColor: PenColors.primary,
        ),
      ),
    );
  }
}

/// Một mức gợi ý: giá trị lưu, và chữ người dùng đọc.
///
/// `null` là một mức HỢP LỆ ở FPS ("tự động"), nên kiểu phải nhận null chứ
/// không lấy `-1` làm dấu hiệu.
typedef _Muc = (int?, String);

/// Hàng số: chọn một mức gợi ý, hoặc tự điền.
///
/// Một ô số trần bắt người dùng tự đoán mức nào là hợp lý — 21 hay 24 hay 60
/// FPS, 900 hay 6000 mili giây. Mức gợi ý trả lời sẵn câu đó cho phần lớn
/// người; ô tự điền vẫn còn cho người biết mình cần gì.
class _HangMuc extends StatelessWidget {
  const _HangMuc({
    required this.icon,
    required this.nhan,
    required this.goiY,
    required this.donVi,
    required this.giaTri,
    required this.muc,
    required this.onDoi,
    required this.readOnly,
    this.choPhepTrong = false,
  });

  final IconData icon;
  final String nhan;
  final String goiY;

  /// Đơn vị hiện trong ô tự điền. Mức gợi ý tự mang chữ của nó.
  final String donVi;

  final int? giaTri;
  final List<_Muc> muc;
  final ValueChanged<int?> onDoi;
  final bool readOnly;

  /// Trường này có nhận `null` không (FPS = để máy tự chọn).
  final bool choPhepTrong;

  String _nhanHienTai(BuildContext context) {
    for (final (v, chu) in muc) {
      if (v == giaTri) return chu;
    }
    // Giá trị không nằm trong danh sách = người dùng đã tự điền. Hiện kèm đơn
    // vị, nếu không thì một con số trần trên màn không nói lên nó là gì.
    return giaTri == null ? context.l10n.capAuto : '$giaTri $donVi';
  }

  @override
  Widget build(BuildContext context) {
    return _Khung(
      icon: icon,
      nhan: nhan,
      goiY: goiY,
      dieuKhien: Semantics(
        label: nhan,
        button: true,
        value: _nhanHienTai(context),
        child: EcTap(
          onTap: readOnly ? null : () => _moBangChon(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PenText(_nhanHienTai(context), size: 15, color: PenColors.mut),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 20, color: PenColors.mut),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _moBangChon(BuildContext context) async {
    final l10n = context.l10n;
    // `-1` KHÔNG dùng làm giá trị thật ở đâu (mọi trường đều >= 0), nên nó an
    // toàn làm dấu hiệu "người dùng chọn Số khác".
    const tuDien = -1;
    final chon = await showCupertinoModalPopup<int?>(
      context: context,
      builder: (c) => CupertinoActionSheet(
        title: Text(nhan),
        message: goiY.isEmpty ? null : Text(goiY),
        actions: [
          for (final (v, chu) in muc)
            CupertinoActionSheetAction(
              onPressed: () =>
                  Navigator.of(c).pop(v ?? (choPhepTrong ? null : 0)),
              child: Text(chu),
            ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(c).pop(tuDien),
            child: Text(l10n.capCustom),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(c).pop(tuDien - 1),
          child: Text(l10n.commonCancel),
        ),
      ),
    );
    if (chon == tuDien - 1) return;
    if (!context.mounted) return;
    if (chon != tuDien) {
      onDoi(chon);
      return;
    }
    final go = await _hoiSo(context);
    if (go != null) onDoi(go);
  }

  Future<int?> _hoiSo(BuildContext context) async {
    final l10n = context.l10n;
    final o = TextEditingController(text: giaTri?.toString() ?? '');
    try {
      return await showCupertinoDialog<int>(
        context: context,
        builder: (c) => CupertinoAlertDialog(
          title: Text(l10n.capCustomTitle),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                CupertinoTextField(
                  controller: o,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  suffix: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PenText(donVi, size: 13, color: PenColors.mut),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(c).pop(),
              child: Text(l10n.commonCancel),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              // Chữ không phải số thì ĐÓNG mà không đổi gì, chứ không ghi 0:
              // ghi 0 là đổi một cài đặt người dùng chỉ gõ nhầm.
              onPressed: () => Navigator.of(c).pop(int.tryParse(o.text.trim())),
              child: Text(l10n.commonConfirm),
            ),
          ],
        ),
      );
    } finally {
      o.dispose();
    }
  }
}

class _HangChon extends StatelessWidget {
  const _HangChon({
    required this.icon,
    required this.nhan,
    required this.goiY,
    required this.giaTri,
    required this.chon,
    required this.onDoi,
    required this.readOnly,
  });

  final IconData icon;
  final String nhan;
  final String goiY;
  final String giaTri;
  final List<(String, String)> chon;
  final ValueChanged<String> onDoi;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final nhanHienTai =
        chon.where((e) => e.$1 == giaTri).firstOrNull?.$2 ?? giaTri;
    return _Khung(
      icon: icon,
      nhan: nhan,
      goiY: goiY,
      dieuKhien: EcTap(
        onTap: readOnly
            ? null
            : () async {
                final v = await showCupertinoModalPopup<String>(
                  context: context,
                  builder: (c) => CupertinoActionSheet(
                    title: Text(nhan),
                    actions: [
                      for (final (ma, nhanChon) in chon)
                        CupertinoActionSheetAction(
                          onPressed: () => Navigator.of(c).pop(ma),
                          child: Text(nhanChon),
                        ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      onPressed: () => Navigator.of(c).pop(),
                      child: Text(c.l10n.commonCancel),
                    ),
                  ),
                );
                if (v != null) onDoi(v);
              },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PenText(nhanHienTai, size: 15, color: PenColors.mut),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: PenColors.mut),
          ],
        ),
      ),
    );
  }
}
