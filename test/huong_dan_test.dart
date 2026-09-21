import 'package:ec_ui/ec_ui.dart' show PenColors;
import 'package:evidence_cam/core/huong_dan/kho_shared_prefs.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
import 'package:storage/storage.dart';

Widget _boc(Widget con) => MaterialApp(
  locale: const Locale('vi'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: con),
);

void main() {
  late EcHuongDanKho kho;

  Future<void> mo(WidgetTester t, {Key? key}) async {
    await t.pumpWidget(
      _boc(
        EcHuongDan(
          key: key,
          kho: kho,
          man: EcMan.record,
          tieuDe: 'Màn ghi hình',
          cacY: const ['Ý một', 'Ý hai'],
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  group('thẻ hướng dẫn', () {
    setUp(() => kho = EcHuongDanKhoTam());

    testWidgets('lần đầu vào màn thì hiện', (t) async {
      await mo(t);
      expect(find.text('Màn ghi hình'), findsOneWidget);
      expect(find.text('Ý một'), findsOneWidget);
    });

    testWidgets('bấm Đã hiểu thì biến mất và không hiện lại', (t) async {
      await mo(t);
      await t.tap(find.text('Đã hiểu'));
      await t.pumpAndSettle();
      expect(find.text('Màn ghi hình'), findsNothing);
      expect(kho.daXem(EcMan.record), isTrue);

      // Mở lại từ đầu — đúng thứ người dùng gặp khi mở lại app.
      await mo(t, key: const ValueKey('lan-hai'));
      expect(find.text('Màn ghi hình'), findsNothing);
    });

    testWidgets('mỗi màn nhớ riêng', (t) async {
      await mo(t);
      await t.tap(find.text('Đã hiểu'));
      await t.pumpAndSettle();
      expect(kho.daXem(EcMan.record), isTrue);
      expect(kho.daXem(EcMan.queue), isFalse);
    });
  });

  testWidgets('thẻ dùng nền XÁM, không nhuốm màu thương hiệu', (t) async {
    // Luật của app (design-dna-app.md §1): "a faint fill is grey, never a
    // washed brand hue". Bản đầu của thẻ này vi phạm đúng luật đó.
    await t.pumpWidget(
      _boc(
        EcHuongDan(
          kho: EcHuongDanKhoTam(),
          man: EcMan.record,
          tieuDe: 'Màn ghi hình',
          cacY: const ['Ý một'],
        ),
      ),
    );
    await t.pumpAndSettle();

    final hop = t.widget<Container>(
      find
          .descendant(
            of: find.byType(EcHuongDan),
            matching: find.byType(Container),
          )
          .first,
    );
    final trangTri = hop.decoration! as BoxDecoration;
    expect(
      trangTri.color,
      PenColors.soft,
      reason: 'nền phải là xám --secondary',
    );
    expect(
      trangTri.color,
      isNot(PenColors.primary),
      reason: 'không được tô màu thương hiệu',
    );
  });

  group('thẻ nằm TRONG màn, không phải hộp bật lên', () {
    /// Dựng màn thật rồi truyền thẻ vào đúng ô của nó — đây mới là đường mà
    /// người dùng đi. Test riêng widget thẻ không chứng minh được ô chèn của
    /// màn có nối đúng hay không.
    Future<void> moMan(WidgetTester t, EcHuongDanKho k) async {
      await t.pumpWidget(
        _boc(
          EcUploadQueueScreen(
            huongDan: EcHuongDan(
              kho: k,
              man: EcMan.queue,
              tieuDe: 'Hàng chờ tải',
              cacY: const ['Ý một'],
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
    }

    testWidgets('chưa xem thì thẻ hiện ngay trong màn', (t) async {
      await moMan(t, EcHuongDanKhoTam());
      expect(find.text('Hàng chờ tải'), findsOneWidget);
      expect(find.text('Ý một'), findsOneWidget);
      // KHÔNG phải hộp bật lên: không có lớp phủ nào chắn màn.
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('đã xem thì màn dựng bình thường, không chừa chỗ trống', (
      t,
    ) async {
      final k = EcHuongDanKhoTam();
      await k.danhDau(EcMan.queue);
      await moMan(t, k);
      expect(find.text('Hàng chờ tải'), findsNothing);
      expect(find.text('Ý một'), findsNothing);
    });

    testWidgets('bấm Đã hiểu thì thẻ biến khỏi màn', (t) async {
      final k = EcHuongDanKhoTam();
      await moMan(t, k);
      await t.tap(find.text('Đã hiểu'));
      await t.pumpAndSettle();
      expect(find.text('Hàng chờ tải'), findsNothing);
      expect(k.daXem(EcMan.queue), isTrue);
    });
  });

  testWidgets('tour dò được nút THEO NHÃN CHỮ, không cần gắn khoá', (t) async {
    // Đây là thứ cho phép trải tour ra mười màn mà không phải sửa vào trong
    // màn nào: tour tự tìm nút theo đúng chữ người dùng đọc thấy.
    await t.pumpWidget(
      _boc(
        EcChiDan(
          kho: EcHuongDanKhoTam(),
          man: EcMan.home,
          buoc: () => const [
            EcChiDanBuoc(
              chu: 'Quét mã',
              tieuDe: 'Nút quét',
              than: 'Bấm đây để quét mã vận đơn.',
            ),
          ],
          child: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Quét mã'),
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('Nút quét'), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);
  });

  testWidgets('nhãn không có trên màn thì chặng bị bỏ qua', (t) async {
    await t.pumpWidget(
      _boc(
        EcChiDan(
          kho: EcHuongDanKhoTam(),
          man: EcMan.home,
          buoc: () => const [
            EcChiDanBuoc(
              chu: 'Nút không tồn tại',
              tieuDe: 'Không nên thấy',
              than: '.',
            ),
          ],
          child: const Center(child: Text('màn trống')),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('Không nên thấy'), findsNothing);
    expect(find.text('màn trống'), findsOneWidget);
  });

  testWidgets('tour BỎ QUA chặng có đích chưa dựng ra', (t) async {
    // Nút ẩn theo quyền, hoặc danh sách rỗng nên nút không có — chặng đó phải
    // biến mất, không được khoét một lỗ ở chỗ chẳng còn gì.
    final coThat = GlobalKey();
    final khongCo = GlobalKey();
    await t.pumpWidget(
      _boc(
        EcChiDan(
          kho: EcHuongDanKhoTam(),
          man: EcMan.noShop,
          buoc: () => [
            EcChiDanBuoc(
              neo: coThat,
              tieuDe: 'Nút có thật',
              than: 'Giải thích',
            ),
            EcChiDanBuoc(
              neo: khongCo,
              tieuDe: 'Nút không dựng',
              than: 'Không nên thấy câu này',
            ),
          ],
          child: Center(
            child: SizedBox(key: coThat, width: 80, height: 40),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();

    expect(find.text('Nút có thật'), findsOneWidget);
    expect(find.text('Nút không dựng'), findsNothing);
    // Chỉ còn MỘT chặng, nên bộ đếm phải nói 1/1 chứ không phải 1/2.
    expect(find.text('1/1'), findsOneWidget);
  });

  group('kho nhớ theo từng người', () {
    late SharedPreferences prefs;
    var uid = 'nguoi-mot';

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      uid = 'nguoi-mot';
    });

    test('người khác đăng nhập trên CÙNG máy vẫn được xem hướng dẫn', () async {
      // Điện thoại đóng gói dùng chung theo ca. Nhớ theo máy thì chỉ người đầu
      // tiên thấy hướng dẫn, mọi người vào sau không bao giờ thấy.
      final k = EcHuongDanKhoPrefs(prefs, () => uid);
      await k.danhDau(EcMan.record);
      expect(k.daXem(EcMan.record), isTrue);

      uid = 'nguoi-hai';
      expect(k.daXem(EcMan.record), isFalse);

      uid = 'nguoi-mot';
      expect(k.daXem(EcMan.record), isTrue);
    });

    test('quên hết thì mọi màn hiện lại', () async {
      final k = EcHuongDanKhoPrefs(prefs, () => uid);
      await k.danhDau(EcMan.record);
      await k.danhDau(EcMan.queue);
      await k.quenHet();
      expect(k.daXem(EcMan.record), isFalse);
      expect(k.daXem(EcMan.queue), isFalse);
    });

    test('chưa đăng nhập thì vẫn ghi được, không nổ', () async {
      final k = EcHuongDanKhoPrefs(prefs, () => '');
      await k.danhDau(EcMan.home);
      expect(k.daXem(EcMan.home), isTrue);
    });
  });
}
