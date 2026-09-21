import 'dart:io';

import 'package:feature_capture/feature_capture.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';

void main() {
  // `enqueue` chạm vào kênh nền tảng (thư mục tài liệu) nên phải có binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  const maA = 'SPXVN0001';
  const maB = 'SPXVN0002';

  // Luật khung hình là chỗ hai cài đặt của cửa hàng gặp nhau, và chúng nói
  // ngược nhau: "kết thúc bằng QR khác" muốn cắt, "chỉ dừng bằng nút" muốn
  // không cắt gì cả. Thứ tự xét quyết định cái nào thắng — và sai thứ tự thì
  // cài đặt chỉ đúng một nửa: mã đơn khác thì lờ đi, còn mã kết thúc vẫn dừng.
  group('luật khung hình đọc cài đặt của cửa hàng', () {
    test('mặc định: mã khác cắt sang clip mới, mã kết thúc thì dừng', () {
      expect(recordingFrameAction(maB, maA), RecordingFrameAction.cutover);
      expect(
        recordingFrameAction(kEndSessionQr, maA),
        RecordingFrameAction.endSession,
      );
    });

    test('tắt "kết thúc bằng QR khác": mã đơn khác bị LỜ ĐI', () {
      // Bàn đóng để nhiều bill cạnh nhau thì cắt tự động là cắt nhầm giữa chừng.
      const tat = EcCaiDatQuay(ketThucBangMaKhac: false);
      expect(
        recordingFrameAction(maB, maA, caiDat: tat),
        RecordingFrameAction.ignore,
      );
      // ...nhưng mã KẾT THÚC vẫn dừng được: đó là hai chuyện khác nhau.
      expect(
        recordingFrameAction(kEndSessionQr, maA, caiDat: tat),
        RecordingFrameAction.endSession,
      );
    });

    test(
      'bật "chỉ dừng bằng nút": KHÔNG mã nào dừng được, kể cả mã kết thúc',
      () {
        const nut = EcCaiDatQuay(chiDungBangNut: true);
        expect(
          recordingFrameAction(maB, maA, caiDat: nut),
          RecordingFrameAction.ignore,
        );
        expect(
          recordingFrameAction(kEndSessionQr, maA, caiDat: nut),
          RecordingFrameAction.ignore,
        );
      },
    );

    test('"chỉ dừng bằng nút" thắng "kết thúc bằng QR khác"', () {
      // Hai cài đặt nói ngược nhau và cả hai đều bật. Không chốt thứ tự thì
      // hành vi phụ thuộc thứ tự viết `if`, và đổi một dòng vô hại làm đổi
      // luồng quay của mọi cửa hàng bật cả hai.
      const caHai = EcCaiDatQuay(chiDungBangNut: true, ketThucBangMaKhac: true);
      expect(
        recordingFrameAction(maB, maA, caiDat: caHai),
        RecordingFrameAction.ignore,
      );
    });

    test('mã trùng mã đang quay thì vẫn lờ đi, ở mọi cài đặt', () {
      for (final c in [
        const EcCaiDatQuay(),
        const EcCaiDatQuay(ketThucBangMaKhac: false),
        const EcCaiDatQuay(chiDungBangNut: true),
      ]) {
        expect(
          recordingFrameAction(maA, maA, caiDat: c),
          RecordingFrameAction.ignore,
        );
      }
    });
  });

  group('đọc cài đặt từ máy chủ', () {
    test('cờ 0/1 của SQLite đọc ra đúng, không rơi về mặc định', () {
      // `as bool?` trên một số nguyên luôn ra `null` rồi rơi về mặc định — cài
      // đặt lưu đúng trên máy chủ nhưng không bao giờ có tác dụng, và không có
      // gì báo.
      final c = EcCaiDatQuay.fromJson({
        'record_audio': 1,
        'status_sound': 0,
        'end_by_other_qr': 0,
        'manual_stop_only': 1,
      });
      expect(c.quayCoAmThanh, isTrue);
      expect(c.amThanhTrangThai, isFalse);
      expect(c.ketThucBangMaKhac, isFalse);
      expect(c.chiDungBangNut, isTrue);
    });

    test('thiếu trường thì dùng mặc định — bản app cũ đọc hồ sơ mới', () {
      final c = EcCaiDatQuay.fromJson(const {});
      expect(c.amThanhTrangThai, isTrue);
      expect(c.ketThucBangMaKhac, isTrue);
      expect(c.quayCoAmThanh, isFalse);
      expect(c.choTruocKhiKetThucMs, 900);
      expect(c.choTruocKhiQuetMoiMs, 5000);
      expect(c.fps, isNull);
    });

    test('đi vòng JSON không mất trường nào', () {
      // Gửi lên rồi đọc về phải ra đúng thứ đã gửi. Sót một khoá trong `toJson`
      // là cài đặt đó không bao giờ lưu được, và màn hình vẫn hiện đúng giá trị
      // người dùng vừa gạt cho tới khi họ tải lại.
      const goc = EcCaiDatQuay(
        fps: 24,
        kieuQuet: 'qr',
        choTruocKhiKetThucMs: 6000,
        choTruocKhiQuetMoiMs: 8000,
        quayThemGiay: 3,
        quayCoAmThanh: true,
        amThanhTrangThai: false,
        tuCauHinhVideo: true,
        tietKiemPin: true,
        chiTaiKhiWifi: true,
        ketThucBangMaKhac: false,
        chiDungBangNut: true,
      );
      // So với DANH SÁCH KHOÁ viết ra ở đây, không so `toJson()` với
      // `toJson()`. Bản đầu của bài này so hai lời gọi cùng một hàm, nên bỏ hẳn
      // một khoá khỏi `toJson` thì nó thiếu ở CẢ HAI vế và hai vế vẫn bằng
      // nhau — đột biến "xoá `tail_seconds`" đã sống sót đúng vì thế.
      //
      // Danh sách này là hợp đồng với máy chủ: tên cột trong D1. Đổi một tên ở
      // một phía mà quên phía kia thì cài đặt lưu vào hư không.
      expect(goc.toJson().keys.toSet(), {
        'fps',
        'scan_kind',
        'end_scan_delay_ms',
        'rearm_delay_ms',
        'tail_seconds',
        'record_audio',
        'status_sound',
        'auto_video_config',
        'battery_saver',
        'wifi_only_upload',
        'end_by_other_qr',
        'manual_stop_only',
      });

      final vong = EcCaiDatQuay.fromJson(goc.toJson());
      expect(vong.quayThemGiay, 3);
      expect(vong.fps, 24);
      expect(vong.kieuQuet, 'qr');
      expect(vong.chiTaiKhiWifi, isTrue);
      expect(vong.tuCauHinhVideo, isTrue);
      expect(vong.toJson(), goc.toJson());
    });
  });

  group('hàng đợi tải lên nghe cài đặt "Tải lên bằng Wi-Fi"', () {
    /// Bộ tải giả ĐẾM số lượt gọi.
    ///
    /// Bản đầu của nhóm này không có nó: nó chỉ khẳng định việc còn nằm trong
    /// hàng đợi. Mà không có bộ tải nào thì `_process` thoát ngay từ dòng đầu,
    /// nên cổng chặn chưa bao giờ được chạm tới — bỏ hẳn cổng đi mà bài vẫn
    /// xanh. Đếm lượt gọi mới là thứ phân biệt được "bị chặn" với "không có gì
    /// để chạy".
    Future<EcUploadQueue> queueVoi({
      required List<String> daTai,
      Future<bool> Function()? choPhepTai,
    }) async {
      final q = EcUploadQueue(
        uploader: _UploaderDem(daTai),
        choPhepTai: choPhepTai,
        directory: Directory.systemTemp.createTempSync('ec_q'),
        temporaryDirectory: Directory.systemTemp.createTempSync('ec_q_t'),
      );
      return q;
    }

    Future<void> them(EcUploadQueue q, String ma) async {
      final f = File(
        '${Directory.systemTemp.createTempSync('ec_f').path}/$ma.mp4',
      )..writeAsBytesSync(const [1, 2, 3]);
      await q.enqueue(
        tracking: ma,
        type: 'Đóng hàng',
        filePath: f.path,
        shopId: 's1',
        capturedAt: DateTime(2026),
        durationSeconds: 3,
      );
    }

    test('cổng nói KHÔNG thì bộ tải KHÔNG được gọi lần nào', () async {
      final daTai = <String>[];
      final q = await queueVoi(daTai: daTai, choPhepTai: () async => false);
      await them(q, 'SPX1');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(daTai, isEmpty);
      // ...và việc còn NGUYÊN: hết Wi-Fi là hoãn, không phải mất.
      expect(q.tasks.length, 1);
      q.dispose();
    });

    test('cổng nói CÓ thì tệp đi bình thường', () async {
      final daTai = <String>[];
      final q = await queueVoi(daTai: daTai, choPhepTai: () async => true);
      await them(q, 'SPX2');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(daTai, contains('SPX2'));
      q.dispose();
    });

    test('không truyền cổng thì cư xử y như trước khi có cài đặt', () async {
      // Thêm cổng mà mặc định là "chặn" thì mọi cửa hàng chưa đụng tới cài đặt
      // này ngừng tải, và không có gì báo.
      final daTai = <String>[];
      final q = await queueVoi(daTai: daTai);
      await them(q, 'SPX3');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(daTai, contains('SPX3'));
      q.dispose();
    });
  });
}

class _UploaderDem implements EcEvidenceUploader {
  _UploaderDem(this.daTai);

  final List<String> daTai;

  @override
  Future<String> upload(
    File file, {
    required String tracking,
    required String type,
    String? shopId,
    String? videoTypeId,
    int? capturedAt,
    int? durationSeconds,
    String? samplesJson,
    void Function(double progress)? onProgress,
  }) async {
    daTai.add(tracking);
    return 'ev-${daTai.length}';
  }
}
