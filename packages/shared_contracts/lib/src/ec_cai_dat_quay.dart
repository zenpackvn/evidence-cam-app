/// Cài đặt quay của một CỬA HÀNG.
///
/// Ở shop chứ không ở máy: bằng chứng đóng gói là dữ liệu của shop, và chủ shop
/// chịu trách nhiệm nếu clip không đủ dùng khi có khiếu nại. Để mỗi nhân viên
/// tự chỉnh trên máy mình là để chất lượng bằng chứng phụ thuộc vào người cầm
/// máy hôm đó.
///
/// Ở `shared_contracts` vì BA tầng cùng cần nó và không tầng nào được phụ thuộc
/// tầng kia: tầng app dựng nó từ JSON, `feature_shift` mang nó theo cửa hàng
/// đang chọn, `feature_capture` đọc nó để quay. Cùng lý do và cùng chỗ với
/// `ClipBudget`.
///
/// Mặc định ở đây phải KHỚP mặc định của máy chủ. Lệch nhau thì bản app cũ —
/// đọc một hồ sơ chưa có các trường này — quay khác hẳn bản mới, mà không có gì
/// báo.
class EcCaiDatQuay {
  const EcCaiDatQuay({
    this.fps,
    this.kieuQuet = 'both',
    this.choTruocKhiKetThucMs = 900,
    this.choTruocKhiQuetMoiMs = 5000,
    this.quayThemGiay = 0,
    this.quayCoAmThanh = false,
    this.amThanhTrangThai = true,
    this.tuCauHinhVideo = false,
    this.tietKiemPin = false,
    this.chiTaiKhiWifi = false,
    this.ketThucBangMaKhac = true,
    this.chiDungBangNut = false,
  });

  factory EcCaiDatQuay.fromJson(Map<String, dynamic> j) {
    // Cờ về từ máy chủ là 0/1 của SQLite. Đọc `as bool?` là luôn `null` rồi rơi
    // về mặc định — cài đặt lưu đúng nhưng không bao giờ có tác dụng.
    bool co(String k, {required bool mac}) {
      final v = j[k];
      if (v is bool) return v;
      if (v is num) return v != 0;
      return mac;
    }

    int so(String k, int mac) => j[k] is num ? (j[k] as num).toInt() : mac;

    return EcCaiDatQuay(
      fps: j['fps'] is num ? (j['fps'] as num).toInt() : null,
      kieuQuet: (j['scan_kind'] as String?) ?? 'both',
      choTruocKhiKetThucMs: so('end_scan_delay_ms', 900),
      choTruocKhiQuetMoiMs: so('rearm_delay_ms', 5000),
      quayThemGiay: so('tail_seconds', 0),
      quayCoAmThanh: co('record_audio', mac: false),
      amThanhTrangThai: co('status_sound', mac: true),
      tuCauHinhVideo: co('auto_video_config', mac: false),
      tietKiemPin: co('battery_saver', mac: false),
      chiTaiKhiWifi: co('wifi_only_upload', mac: false),
      ketThucBangMaKhac: co('end_by_other_qr', mac: true),
      chiDungBangNut: co('manual_stop_only', mac: false),
    );
  }

  /// `null` = để máy tự chọn khung hình/giây. Máy không nhận mức này thì plugin
  /// lùi về mức gần nhất — nên đây là ĐỀ NGHỊ, không phải cam kết.
  final int? fps;

  /// 'qr' | 'barcode' | 'both'.
  final String kieuQuet;

  final int choTruocKhiKetThucMs;
  final int choTruocKhiQuetMoiMs;
  final int quayThemGiay;
  final bool quayCoAmThanh;
  final bool amThanhTrangThai;
  final bool tuCauHinhVideo;
  final bool tietKiemPin;
  final bool chiTaiKhiWifi;
  final bool ketThucBangMaKhac;

  /// Bật cái này thì [ketThucBangMaKhac] mất tác dụng — hai thứ nói ngược nhau,
  /// và máy quay ưu tiên cái này.
  final bool chiDungBangNut;

  EcCaiDatQuay copyWith({
    int? fps,
    bool xoaFps = false,
    String? kieuQuet,
    int? choTruocKhiKetThucMs,
    int? choTruocKhiQuetMoiMs,
    int? quayThemGiay,
    bool? quayCoAmThanh,
    bool? amThanhTrangThai,
    bool? tuCauHinhVideo,
    bool? tietKiemPin,
    bool? chiTaiKhiWifi,
    bool? ketThucBangMaKhac,
    bool? chiDungBangNut,
  }) => EcCaiDatQuay(
    // `fps` là trường DUY NHẤT mà `null` là một giá trị có nghĩa ("để máy tự
    // chọn"), nên nó cần cờ xoá riêng — `fps: null` ở đây nghĩa là "không đụng".
    fps: xoaFps ? null : (fps ?? this.fps),
    kieuQuet: kieuQuet ?? this.kieuQuet,
    choTruocKhiKetThucMs: choTruocKhiKetThucMs ?? this.choTruocKhiKetThucMs,
    choTruocKhiQuetMoiMs: choTruocKhiQuetMoiMs ?? this.choTruocKhiQuetMoiMs,
    quayThemGiay: quayThemGiay ?? this.quayThemGiay,
    quayCoAmThanh: quayCoAmThanh ?? this.quayCoAmThanh,
    amThanhTrangThai: amThanhTrangThai ?? this.amThanhTrangThai,
    tuCauHinhVideo: tuCauHinhVideo ?? this.tuCauHinhVideo,
    tietKiemPin: tietKiemPin ?? this.tietKiemPin,
    chiTaiKhiWifi: chiTaiKhiWifi ?? this.chiTaiKhiWifi,
    ketThucBangMaKhac: ketThucBangMaKhac ?? this.ketThucBangMaKhac,
    chiDungBangNut: chiDungBangNut ?? this.chiDungBangNut,
  );

  Map<String, Object?> toJson() => {
    'fps': fps,
    'scan_kind': kieuQuet,
    'end_scan_delay_ms': choTruocKhiKetThucMs,
    'rearm_delay_ms': choTruocKhiQuetMoiMs,
    'tail_seconds': quayThemGiay,
    'record_audio': quayCoAmThanh,
    'status_sound': amThanhTrangThai,
    'auto_video_config': tuCauHinhVideo,
    'battery_saver': tietKiemPin,
    'wifi_only_upload': chiTaiKhiWifi,
    'end_by_other_qr': ketThucBangMaKhac,
    'manual_stop_only': chiDungBangNut,
  };
}
