import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:localization/localization.dart';
import 'package:shared_contracts/shared_contracts.dart';

Widget _man(EcCaiDatQuayScreen man) => CupertinoApp(
  locale: const Locale('vi'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: man,
);

/// Công tắc của một hàng.
///
/// `bySemanticsLabel` một mình khớp HAI thứ: dòng chữ nhãn và `Semantics` bọc
/// công tắc — cả hai đều mang đúng nhãn đó. Lọc thêm theo kiểu widget mới ra
/// đúng cái bấm được.
Finder _congTac(WidgetTester t, String nhan) => find.descendant(
  of: find.bySemanticsLabel(nhan),
  matching: find.byType(CupertinoSwitch),
);

/// Khung CAO để cả mười bốn hàng nằm trong tầm chạm.
///
/// Mặc định 800px chỉ chứa được vài hàng đầu, và `tap` vào một hàng dưới mép
/// màn thì trượt hit-test — bài đỏ vì bố cục, không phải vì hành vi.
void _khungCao(WidgetTester t) {
  t.view.physicalSize = const Size(430, 2400);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
}

/// Chữ trên nút huỷ, chép từ `commonCancel` trong bộ dịch.
///
/// 'Huỷ' và 'Hủy' khác nhau ở vị trí dấu, và bản đầu của bài này gõ nhầm bản
/// kia — đỏ vì chính tả chứ không vì hành vi.
const l10nHuy = 'Hủy';

void main() {
  // Màn cài đặt quay của CỬA HÀNG — bản app của thẻ cùng tên trên web. Hai bên
  // phải cư xử giống nhau, vì cùng một chủ shop có thể đổi ở web rồi mở app ra
  // kiểm lại.
  testWidgets(
    'gạt một công tắc gửi CẢ BỘ cài đặt, đổi đúng một trường',
    experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
    (t) async {
      _khungCao(t);
      EcCaiDatQuay? gui;
      // Khởi từ bộ ĐÃ SỬA, không phải bộ mặc định. Bản đầu của bài này dùng
      // `const EcCaiDatQuay()`, nên "gửi bộ mặc định thay vì bộ hiện tại" —
      // đúng cái lỗi ghi đè cài đặt người dùng không chạm vào — không phân biệt
      // được với hành vi đúng.
      const dangCo = EcCaiDatQuay(
        quayThemGiay: 7,
        quayCoAmThanh: true,
        ketThucBangMaKhac: false,
        kieuQuet: 'qr',
      );
      await t.pumpWidget(
        _man(
          EcCaiDatQuayScreen(caiDat: dangCo, onDoi: (v) => gui = v),
        ),
      );

      await t.tap(_congTac(t, 'Tiết kiệm pin'));
      await t.pump();

      expect(gui, isNotNull);
      expect(gui!.tietKiemPin, isTrue);
      // Mọi trường khác giữ NGUYÊN giá trị đang có: gạt một ô mà gửi kèm giá
      // trị mặc định của ô khác là ghi đè một cài đặt người dùng không hề chạm
      // vào — và họ chỉ phát hiện ra ở lần quay sau.
      expect(gui!.quayThemGiay, 7);
      expect(gui!.quayCoAmThanh, isTrue);
      expect(gui!.ketThucBangMaKhac, isFalse);
      expect(gui!.kieuQuet, 'qr');
    },
  );

  testWidgets(
    'công tắc đọc đúng trạng thái đang lưu, kể cả khi đang TẮT',
    experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
    (t) async {
      _khungCao(t);
      await t.pumpWidget(
        _man(
          EcCaiDatQuayScreen(
            caiDat: const EcCaiDatQuay(
              amThanhTrangThai: false,
              quayCoAmThanh: true,
            ),
            onDoi: (_) {},
          ),
        ),
      );

      final tat = t.widget<CupertinoSwitch>(
        _congTac(t, 'Âm thanh trạng thái'),
      );
      final bat = t.widget<CupertinoSwitch>(
        _congTac(t, 'Quay video có âm thanh'),
      );
      expect(tat.value, isFalse);
      expect(bat.value, isTrue);
    },
  );

  testWidgets(
    'nhân viên xem được nhưng KHÔNG gạt được',
    experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
    (t) async {
      // Giấu hẳn màn đi là nhân viên không có cách nào biết vì sao máy mình
      // quay khác máy người bên cạnh. Cho xem, không cho sửa.
      _khungCao(t);
      var goi = 0;
      await t.pumpWidget(
        _man(
          EcCaiDatQuayScreen(
            caiDat: const EcCaiDatQuay(),
            readOnly: true,
            onDoi: (_) => goi++,
          ),
        ),
      );

      // `warnIfMissed: false`: công tắc ở chế độ chỉ-đọc có `onChanged: null`
      // nên nó không nhận chạm — đó CHÍNH LÀ hàng rào, và cảnh báo hit-test ở
      // đây là tiếng ồn chứ không phải lỗi.
      await t.tap(_congTac(t, 'Tiết kiệm pin'), warnIfMissed: false);
      await t.pump();

      expect(goi, 0);
      expect(
        find.text('Chỉ chủ cửa hàng đổi được các mục này.'),
        findsOneWidget,
      );
    },
  );

  // Ô số trần bắt người dùng tự đoán mức nào hợp lý — 21 hay 24 hay 60 FPS.
  // Mức gợi ý trả lời sẵn; ô tự điền vẫn còn cho người biết mình cần gì.
  group('hàng số: mức gợi ý và tự điền', () {
    testWidgets(
      'hiện nhãn của mức đang dùng, không phải con số trần',
      experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
      (t) async {
        _khungCao(t);
        await t.pumpWidget(
          _man(
            EcCaiDatQuayScreen(
              caiDat: const EcCaiDatQuay(fps: 30, quayThemGiay: 0),
              onDoi: (_) {},
            ),
          ),
        );
        expect(find.text('30 FPS'), findsOneWidget);
        // 0 giây phải đọc ra "Tắt", không phải "0 giây" — một con số 0 trên màn
        // cài đặt đọc như một giá trị chưa đặt.
        expect(find.textContaining('Tắt'), findsWidgets);
      },
    );

    testWidgets(
      'FPS chưa đặt đọc ra "Tự động", không phải ô trống',
      experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
      (t) async {
        _khungCao(t);
        await t.pumpWidget(
          _man(
            EcCaiDatQuayScreen(caiDat: const EcCaiDatQuay(), onDoi: (_) {}),
          ),
        );
        expect(find.text('Tự động'), findsOneWidget);
      },
    );

    testWidgets(
      'giá trị NGOÀI danh sách vẫn hiện đúng, kèm đơn vị',
      experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
      (t) async {
        // Người dùng tự điền 21 FPS (đúng con số trong ảnh chụp màn tham
        // chiếu). Rơi về "Tự động" ở đây là màn hình nói dối về thứ đang chạy.
        _khungCao(t);
        await t.pumpWidget(
          _man(
            EcCaiDatQuayScreen(
              caiDat: const EcCaiDatQuay(fps: 21),
              onDoi: (_) {},
            ),
          ),
        );
        expect(find.text('21 FPS'), findsOneWidget);
      },
    );

    testWidgets(
      'chọn một mức gửi đúng giá trị của mức đó',
      experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
      (t) async {
        _khungCao(t);
        EcCaiDatQuay? gui;
        await t.pumpWidget(
          _man(
            EcCaiDatQuayScreen(
              caiDat: const EcCaiDatQuay(),
              onDoi: (v) => gui = v,
            ),
          ),
        );

        // Bấm vào NHÃN GIÁ TRỊ, không phải nhãn hàng: `bySemanticsLabel` khớp
        // vào dòng chữ tên hàng, mà dòng đó không bấm được — chạm vào đó thì
        // không có gì mở ra và bài đỏ với "Bad state: No element" ở bước sau.
        await t.tap(find.text('Tự động'));
        await t.pumpAndSettle();
        await t.tap(find.text('24 FPS').last);
        await t.pumpAndSettle();

        expect(gui?.fps, 24);
      },
    );

    testWidgets(
      'bấm Huỷ trong bảng chọn KHÔNG đổi gì',
      experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
      (t) async {
        // Huỷ mà vẫn ghi là đổi một cài đặt người dùng vừa quyết định không
        // đổi — và họ chỉ biết ở lần quay sau.
        _khungCao(t);
        var goi = 0;
        await t.pumpWidget(
          _man(
            EcCaiDatQuayScreen(
              caiDat: const EcCaiDatQuay(),
              onDoi: (_) => goi++,
            ),
          ),
        );

        await t.tap(find.text('Tự động'));
        await t.pumpAndSettle();
        await t.tap(find.text(l10nHuy).last);
        await t.pumpAndSettle();

        expect(goi, 0);
      },
    );
  });
}
