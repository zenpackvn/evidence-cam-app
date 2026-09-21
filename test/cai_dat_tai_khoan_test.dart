import 'dart:io';

import 'package:app_ui/app_ui.dart' show BrandColors;
import 'package:ec_ui/ec_ui.dart' show PenColors;
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Bảng màu là một cờ TĨNH, không đọc từ context — đánh đổi có chủ ý để 790
  // chỗ gọi `BrandColors.ink` khỏi phải sửa. Bài này canh đúng cái đánh đổi đó
  // còn đứng: getter phải THẬT SỰ đổi theo cờ, và `datBanToi` phải báo đúng khi
  // có đổi, vì bên gọi dựa vào đó để dựng lại cây widget.
  group('bảng màu tối', () {
    tearDown(() => BrandColors.datBanToi(toi: false));

    test('mọi màu nền và chữ đổi khi bật bảng tối', () {
      final sangBg = BrandColors.bg;
      final sangInk = BrandColors.ink;
      BrandColors.datBanToi(toi: true);
      expect(BrandColors.bg, isNot(sangBg));
      expect(BrandColors.ink, isNot(sangInk));
    });

    test('nền tối phải TỐI hơn chữ, không phải ngược lại', () {
      // Đổi màu mà quên đảo vai là chữ đen trên nền đen: không có gì trên màn
      // hình, và bài test nào chỉ so "đã đổi chưa" vẫn xanh.
      BrandColors.datBanToi(toi: true);
      double sang(int v) =>
          0.299 * ((v >> 16) & 255) +
          0.587 * ((v >> 8) & 255) +
          0.114 * (v & 255);
      expect(
        sang(BrandColors.bg.toARGB32()),
        lessThan(sang(BrandColors.ink.toARGB32())),
      );
      expect(
        sang(BrandColors.card.toARGB32()),
        lessThan(sang(BrandColors.ink.toARGB32())),
      );
    });

    test('báo có đổi đúng một lần, để bên gọi không dựng lại cây vô cớ', () {
      expect(BrandColors.datBanToi(toi: true), isTrue);
      expect(BrandColors.datBanToi(toi: true), isFalse);
      expect(BrandColors.datBanToi(toi: false), isTrue);
    });

    test(
      'màu của sàn KHÔNG đổi theo bảng màu — đó là màu của công ty khác',
      () {
        const sangShopee = BrandColors.shopee;
        BrandColors.datBanToi(toi: true);
        expect(BrandColors.shopee, sangShopee);
      },
    );
  });

  // HAI bảng màu, hai gói không phụ thuộc nhau, hai cờ riêng. Đổi một bên mà
  // quên bên kia là một nửa app sáng một nửa tối — và bản đầu của tính năng này
  // đúng là chỉ đổi `BrandColors`, nên chế độ tối hỏng trên 638 chỗ dùng
  // `PenColors`.
  group('hai bảng màu phải đổi CÙNG nhau', () {
    tearDown(() {
      BrandColors.datBanToi(toi: false);
      PenColors.datBanToi(toi: false);
    });

    test('PenColors cũng có bảng tối, không đứng yên ở bảng sáng', () {
      final sangBg = PenColors.bg;
      final sangInk = PenColors.ink;
      PenColors.datBanToi(toi: true);
      expect(PenColors.bg, isNot(sangBg));
      expect(PenColors.ink, isNot(sangInk));
    });

    test('nền tối của PenColors phải TỐI hơn chữ', () {
      PenColors.datBanToi(toi: true);
      double sang(int v) =>
          0.299 * ((v >> 16) & 255) +
          0.587 * ((v >> 8) & 255) +
          0.114 * (v & 255);
      expect(
        sang(PenColors.bg.toARGB32()),
        lessThan(sang(PenColors.ink.toARGB32())),
      );
    });

    test('hai bảng cùng một dải: nền tối của chúng gần nhau', () {
      BrandColors.datBanToi(toi: true);
      PenColors.datBanToi(toi: true);
      // Cùng dẫn từ một bảng tối của console, nên hai nền phải trùng khớp. Lệch
      // nhau là thẻ vẽ bằng gói này nằm trên nền vẽ bằng gói kia và lộ đường
      // viền không ai vẽ.
      expect(PenColors.bg, BrandColors.bg);
      expect(PenColors.card, BrandColors.card);
      expect(PenColors.ink, BrandColors.ink);
    });
  });

  // Hai lời gọi ở HAI dòng cạnh nhau, và không có gì buộc chúng đi cùng nhau.
  // Bỏ một dòng thì analyzer im, mọi bài kiểm màu vẫn xanh (chúng gọi thẳng
  // `datBanToi`), và triệu chứng duy nhất là một nửa app sáng trên máy thật.
  //
  // Đọc THẲNG mã nguồn vì đó là thứ duy nhất nói được "cả hai đều được gọi từ
  // cùng một chỗ" — dựng cả `EcApp` lên chỉ để đo một dòng thì đắt hơn nhiều mà
  // vẫn không chắc hơn.
  test('nơi đổi giao diện gọi CẢ HAI bảng màu', () {
    final ma = File('lib/ec_app.dart').readAsStringSync();
    expect(
      ma.contains('BrandColors.datBanToi('),
      isTrue,
      reason: 'thiếu lượt đổi bảng màu của app_ui',
    );
    expect(
      ma.contains('PenColors.datBanToi('),
      isTrue,
      reason: 'thiếu lượt đổi bảng màu của ec_ui — 638 chỗ sẽ kẹt ở bảng sáng',
    );
  });
}
