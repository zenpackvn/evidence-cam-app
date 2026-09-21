import 'dart:async';

import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';

/// Tên Official Account thật sự đứng tên gửi tin Zalo.
///
/// ĐỂ Ở ĐÂY, một chỗ duy nhất, và truyền vào chuỗi dịch làm tham số — không
/// viết cứng vào 10 tệp .arb. Tên này sẽ đổi (OA hiện tại không mang tên
/// ZenPack), và lúc đó sửa đúng dòng này là xong.
///
/// Vì sao phải nói ra: người dùng đăng nhập ZenPack mà nhận tin từ một OA tên
/// khác thì phần lớn bỏ qua như tin rác — hoặc tưởng bị lừa đảo.
const _zaloOa = 'Uniclove';

/// Giãn cách gửi lại — khớp `GIAN_CACH_MS` của máy chủ.
///
/// Đếm ngược ở đây KHÔNG phải hàng rào (máy chủ mới là hàng rào); nó chỉ để
/// người dùng thấy còn bao lâu, thay vì bấm rồi ăn lỗi không hiểu vì sao.
const _choGuiLaiGiay = 60;

/// Đăng nhập bằng số điện thoại, OTP qua Zalo hoặc SMS.
///
/// Hai bước trong một màn: nhập số → nhập mã. Tách thành hai route thì nút back
/// của máy đưa người dùng về màn nhập số với đồng hồ đếm ngược đã mất, và họ
/// phải xin mã lại — tốn một tin nhắn thật cho một thao tác vô nghĩa.
class EcPhoneLoginScreen extends StatefulWidget {
  const EcPhoneLoginScreen({
    required this.onSendCode,
    required this.onVerify,
    this.onBack,
    super.key,
  });

  /// Xin mã. Ném lỗi mang mã máy chủ; màn này dịch sang câu người đọc được.
  final Future<void> Function(String phone, String channel) onSendCode;

  /// Đổi mã lấy phiên. Ném khi mã sai.
  final Future<void> Function(String phone, String code) onVerify;

  final VoidCallback? onBack;

  @override
  State<EcPhoneLoginScreen> createState() => _EcPhoneLoginScreenState();
}

class _EcPhoneLoginScreenState extends State<EcPhoneLoginScreen> {
  final _sdt = TextEditingController();
  final _ma = TextEditingController();
  final _oMa = FocusNode();
  bool _dangChay = false;
  bool _buocMa = false;
  String _kenhDaGui = 'zalo';
  int _conLai = 0;
  Timer? _dongHo;

  @override
  void dispose() {
    _dongHo?.cancel();
    _sdt.dispose();
    _ma.dispose();
    _oMa.dispose();
    super.dispose();
  }

  void _chayDongHo() {
    _dongHo?.cancel();
    setState(() => _conLai = _choGuiLaiGiay);
    _dongHo = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _conLai--);
      if (_conLai <= 0) t.cancel();
    });
  }

  Future<void> _gui(String kenh) async {
    setState(() => _dangChay = true);
    try {
      await widget.onSendCode(_sdt.text, kenh);
      if (!mounted) return;
      setState(() {
        _kenhDaGui = kenh;
        _buocMa = true;
      });
      _chayDongHo();
      // Con trỏ nhảy sang ô mã: người vừa bấm "gửi" đang chờ gõ mã.
      _oMa.requestFocus();
    } on Object catch (e) {
      if (mounted) _bao(_cau(context.l10n, e));
    } finally {
      if (mounted) setState(() => _dangChay = false);
    }
  }

  Future<void> _xacNhan() async {
    setState(() => _dangChay = true);
    try {
      await widget.onVerify(_sdt.text, _ma.text);
    } on Object catch (e) {
      if (!mounted) return;
      _bao(_cau(context.l10n, e));
      // Mã sai thì xoá ô đi: để nguyên là người dùng phải tự bôi đen xoá trước
      // khi gõ lại, và trên điện thoại đó là thao tác khó chịu nhất màn này.
      _ma.clear();
    } finally {
      if (mounted) setState(() => _dangChay = false);
    }
  }

  void _bao(String cau) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(cau)));

  /// Mã lỗi của máy chủ → câu người đọc được.
  ///
  /// Gộp hết thành một câu "có lỗi" là bắt người dùng đoán: "vừa gửi rồi" và
  /// "Zalo không nhận" đòi hai hành động hoàn toàn khác nhau.
  static String _cau(AppLocalizations l10n, Object e) {
    final ma = _maCua(e);
    return switch (ma) {
      'invalid_phone' || 'sai_so' => l10n.phoneLoginInvalid,
      'too_soon' => l10n.otpTooSoon,
      'rate_limited' => l10n.otpRateLimited,
      'not_configured' => l10n.otpNotConfigured,
      'sai_ma' => l10n.otpWrong,
      'het_han' => l10n.otpExpired,
      'khong_dung_duoc' => l10n.otpUsedUp,
      _ => l10n.otpSendFailed,
    };
  }

  /// Đọc trường `ma` mà không buộc gói này phụ thuộc vào tầng dữ liệu.
  static String _maCua(Object e) {
    try {
      return (e as dynamic).ma as String? ?? '';
    } on Object {
      return '';
    }
  }

  bool get _duSo => _sdt.text.trim().length >= 9;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: PenColors.bg,
      appBar: AppBar(
        backgroundColor: PenColors.bg,
        elevation: 0,
        leading: widget.onBack == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                color: PenColors.ink,
                onPressed: widget.onBack,
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                _buocMa ? l10n.otpTitle : l10n.phoneLoginTitle,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: PenColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _buocMa
                    ? l10n.otpSentTo(_sdt.text.trim())
                    : l10n.phoneLoginSubtitle,
                style: TextStyle(fontSize: 15, color: PenColors.mut),
              ),
              // Chỉ nói khi thật sự gửi qua Zalo: tin SMS mang brandname, không
              // phải tên OA — nói ở đó là chỉ người dùng đi tìm nhầm tin.
              if (_buocMa && _kenhDaGui == 'zalo') ...[
                const SizedBox(height: 6),
                Text(
                  l10n.otpFromOa(_zaloOa),
                  style: TextStyle(fontSize: 13, color: PenColors.mut),
                ),
              ],
              const SizedBox(height: 24),
              if (!_buocMa) ..._buocNhapSo(l10n) else ..._buocNhapMa(l10n),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buocNhapSo(AppLocalizations l10n) => [
    TextField(
      controller: _sdt,
      enabled: !_dangChay,
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      decoration: InputDecoration(
        labelText: l10n.phoneLoginNumberLabel,
        hintText: l10n.phoneLoginNumberHint,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => setState(() {}),
    ),
    const SizedBox(height: 16),
    PenPrimaryButton(
      label: l10n.phoneLoginViaZalo,
      onPressed: _dangChay || !_duSo ? null : () => unawaited(_gui('zalo')),
    ),
    const SizedBox(height: 12),
    PenOutlineButton(
      label: l10n.phoneLoginViaSms,
      onPressed: _dangChay || !_duSo ? null : () => unawaited(_gui('sms')),
    ),
  ];

  List<Widget> _buocNhapMa(AppLocalizations l10n) => [
    TextField(
      controller: _ma,
      focusNode: _oMa,
      enabled: !_dangChay,
      keyboardType: TextInputType.number,
      // `oneTimeCode` là thứ làm iOS/Android tự điền mã từ tin nhắn.
      autofillHints: const [AutofillHints.oneTimeCode],
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 24, letterSpacing: 8),
      // KHÔNG đặt `maxLength`: dán cả dòng "Mã của bạn là 123456" từ tin nhắn
      // là chuyện thường, mà giới hạn ký tự cắt chuỗi TRƯỚC khi bộ lọc chữ số
      // chạy — kết quả ra ô rỗng. Lọc rồi mới cắt, đúng thứ tự đó.
      inputFormatters: [_ChiSauChuSo()],
      decoration: InputDecoration(
        labelText: l10n.otpLabel,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => setState(() {}),
    ),
    const SizedBox(height: 16),
    PenPrimaryButton(
      label: l10n.otpConfirm,
      onPressed: _dangChay || _ma.text.length != 6
          ? null
          : () => unawaited(_xacNhan()),
    ),
    const SizedBox(height: 12),
    TextButton(
      onPressed: _dangChay || _conLai > 0
          ? null
          : () => unawaited(_gui('zalo')),
      child: Text(
        _conLai > 0 ? l10n.otpResendIn(_conLai) : l10n.otpResend,
      ),
    ),
    TextButton(
      onPressed: () {
        _dongHo?.cancel();
        setState(() {
          _buocMa = false;
          _conLai = 0;
        });
        _ma.clear();
      },
      child: Text(l10n.otpChangePhone),
    ),
  ];
}

/// Giữ lại chữ số rồi cắt còn sáu — theo ĐÚNG thứ tự đó.
class _ChiSauChuSo extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final so = newValue.text.replaceAll(RegExp(r'\D'), '');
    final cat = so.length > 6 ? so.substring(0, 6) : so;
    return TextEditingValue(
      text: cat,
      selection: TextSelection.collapsed(offset: cat.length),
    );
  }
}
