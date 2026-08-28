// Nhãn "Kho lưu trữ" trên Chi tiết video — nói đúng nơi bằng chứng đang nằm,
// hoặc đang đi tới.
//
// Ba lần liên tiếp người bán báo cùng một câu: "dùng cloud S3 mà video lại bị
// save sang cloud của ZenPack". Cả ba lần chỗ hỏng đều ở nhãn này, và cả ba lần
// nó lọt vì KHÔNG CÓ ca nào canh — không một test nào trong repo từng đọc chuỗi
// mà hàng này in ra.
//
// Ca ở đây đi HẾT ĐƯỜNG: từ JSON máy chủ trả về, qua DTO, qua màn Vận đơn, tới
// đúng dòng chữ trên sheet Chi tiết video. Dựng `OrderDetailDto` bằng
// constructor Dart thì ca xanh mà màn thật vẫn hỏng — lần trước chỗ đứt nằm
// đúng ở bước đọc JSON.
import 'dart:io';

import 'package:ec_data/ec_data.dart';
import 'package:evidence_cam/ec_app.dart';
import 'package:feature_capture/feature_capture.dart' show debugPreviewDir;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'ec_fakes.dart';

/// Một đơn có đúng MỘT clip, dựng từ JSON thật của `GET /orders/:id`.
class _Repo extends FakeEcRepository {
  const _Repo({
    this.shopStorageKind = 's3',
    this.sealStatus = 'sealed',
    this.relayStatus,
    this.storageKind,
    this.r2Key = 'raw/e1.mp4',
    this.uploadStatus = 'done',
  });

  /// `shop_storage_kind` — kho riêng shop ĐANG CHỌN, gửi ở mức đơn.
  final String? shopStorageKind;
  final String? sealStatus;
  final String? relayStatus;

  /// Kho đang GIỮ clip. Chỉ có giá trị sau khi đẩy xong.
  final String? storageKind;

  /// Byte còn ở vùng chờ tạm hay không. Retention ghi `NULL` khi dọn.
  final String? r2Key;
  final String uploadStatus;

  @override
  Future<List<ShopDto>> shops() async => const [
    ShopDto(
      id: 's1',
      name: 'Shop ABC',
      platform: 'shopee',
      resolution: '720p',
      role: 'owner',
    ),
  ];

  @override
  Future<List<VideoTypeDto>> videoTypes(String shopId) async => const [
    VideoTypeDto(id: 'default-pack', name: 'Đóng hàng', isDefault: true),
  ];

  @override
  Future<OrderPageDto> orders(
    String shopId, {
    int page = 1,
    String? uploadState,
    int? fromTs,
    int? toTs,
    String? videoTypeId,
  }) async => OrderPageDto(
    items: const [
      OrderSummaryDto(
        id: 'o1',
        tracking: 'SPXVN024567890',
        createdAt: 3,
        evidenceCount: 1,
      ),
    ],
    total: 1,
    page: page,
    pageSize: EcApi.ordersPageSize,
  );

  @override
  Future<OrderDetailDto> order(String shopId, String orderId) async =>
      OrderDetailDto.fromJson({
        'order': {
          'id': 'o1',
          'tracking_raw': 'SPXVN024567890',
          'created_at': 3,
        },
        'shop_storage_kind': shopStorageKind,
        'evidence': [
          {
            'id': 'e1',
            'kind': 'video',
            'captured_at': DateTime(2026, 8, 25, 9, 15).millisecondsSinceEpoch,
            'upload_status': uploadStatus,
            'video_type_id': 'default-pack',
            'seal_status': sealStatus,
            'relay_status': relayStatus,
            'storage_kind': storageKind,
            'r2_key': r2Key,
            'url': 'https://example.test/e1.mp4',
          },
        ],
      });
}

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async =>
      Directory.systemTemp.createTempSync('nhan_kho_docs').path;
}

void main() {
  // Không có thư mục bản xem tạm thì `ecPreviews()` treo vĩnh viễn giữa
  // `_load()` của màn chi tiết đơn — màn dựng ra 895 widget mà KHÔNG một chữ
  // nào, và không ngoại lệ nào để lần theo. Cùng cái bẫy `ec_app_test.dart` đã
  // trả giá.
  PathProviderPlatform.instance = _FakePathProviderPlatform();
  debugPreviewDir = Directory.systemTemp.createTempSync('nhan_kho_preview');

  /// Mở sheet Chi tiết video của clip duy nhất, rồi trả về MỌI chuỗi trên đó.
  ///
  /// Tách ra khỏi [nhanKho] để ca "dấu muộn" dùng lại đúng đường đi này: cùng
  /// một JSON máy chủ, cùng một màn thật. Dựng riêng một lối tắt cho ca mới là
  /// tự bỏ mất chỗ đã trả giá để biết — bước đọc JSON.
  Future<List<String?>> chuTrenSheet(WidgetTester tester, _Repo repo) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.localeTestValue = const Locale('vi');
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);

    await tester.pumpWidget(EcApp(auth: FakeEcAuth(), repo: repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bắt đầu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng nhập với Google'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shop ABC').first);
    await tester.pumpAndSettle();

    // Thôi `pumpAndSettle` từ đây: màn chi tiết đơn tự hẹn lượt hỏi lại khi
    // clip đang niêm phong, nên nó không bao giờ đứng yên.
    await tester.tap(find.textContaining('SPXVN').first);
    await tester.pump();
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.tap(find.text('Đóng hàng').first);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    return tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .toList();
  }

  /// Chữ ở hàng "Kho lưu trữ".
  Future<String> nhanKho(WidgetTester tester, _Repo repo) async {
    final texts = await chuTrenSheet(tester, repo);
    final i = texts.indexOf('Kho lưu trữ');
    expect(i, isNonNegative, reason: 'sheet Chi tiết video không có hàng Kho lưu trữ');
    return texts[i + 1]!;
  }

  const s3 = 'Kho đám mây riêng (chuẩn S3)';
  const zenpack = 'Cloud ZenPack';
  final khongRoRi = LeakTesting.settings.withIgnoredAll();

  // ĐÂY là lỗi người bán báo ba lần.
  //
  // `relay_status` NULL trên một clip đã niêm phong KHÔNG có nghĩa là clip nằm
  // lại kho hệ thống vĩnh viễn. Đo trên chính máy chủ (`test/relay_s3.test.ts`
  // bên backend): `retryPendingRelays` nhặt hàng NULL TRƯỚC TIÊN, đẩy byte tới
  // bucket và ghi `storage_kind='s3'`. Mà NULL đúng là chỗ clip rơi vào nhiều
  // nhất — lượt đẩy ngay sau niêm phong chết trước cả câu ghi 'pending', và mọi
  // clip đã niêm phong từ TRƯỚC lúc shop bật S3 cũng nằm ở đó.
  testWidgets(
    'clip đã niêm phong, chưa có lượt đẩy nào: vẫn là kho của shop',
    experimentalLeakTesting: khongRoRi,
    (tester) async {
      expect(await nhanKho(tester, const _Repo(relayStatus: null)), s3);
    },
  );

  testWidgets(
    'đang trong hàng đợi đẩy: kho của shop',
    experimentalLeakTesting: khongRoRi,
    (tester) async {
      expect(await nhanKho(tester, const _Repo(relayStatus: 'pending')), s3);
    },
  );

  testWidgets(
    'lượt đẩy hỏng, còn được thử lại: kho của shop',
    experimentalLeakTesting: khongRoRi,
    (tester) async {
      expect(await nhanKho(tester, const _Repo(relayStatus: 'failed')), s3);
    },
  );

  testWidgets(
    'đang nung dấu: đã gọi tên kho đích, không đợi tới lúc đẩy xong',
    experimentalLeakTesting: khongRoRi,
    (tester) async {
      expect(await nhanKho(tester, const _Repo(sealStatus: 'rendering')), s3);
    },
  );

  testWidgets(
    'đã sang kho: gọi tên kho ĐANG GIỮ clip',
    experimentalLeakTesting: khongRoRi,
    (tester) async {
      expect(
        await nhanKho(
          tester,
          const _Repo(
            relayStatus: 'relayed',
            storageKind: 's3',
            r2Key: null,
          ),
        ),
        s3,
      );
    },
  );

  // Chiều ngược lại — cũng phải canh, nếu không bản vá lần này lại thành lời
  // nói dối theo hướng kia.

  // Byte đã bị retention dọn khỏi vùng chờ tạm (`r2_key` về NULL cùng lượt).
  // Không còn gì để chuyển đi đâu nữa, nên gọi tên S3 ở đây là chỉ vào một chỗ
  // clip không bao giờ tới.
  testWidgets(
    'byte đã bị dọn khỏi vùng chờ: thôi hứa hẹn kho riêng',
    experimentalLeakTesting: khongRoRi,
    (tester) async {
      expect(
        await nhanKho(
          tester,
          const _Repo(r2Key: null, uploadStatus: 'expired'),
        ),
        zenpack,
      );
    },
  );

  // Shop dùng kho hệ thống: "Cloud ZenPack" là câu ĐÚNG và cuối cùng.
  testWidgets(
    'shop dùng kho hệ thống: Cloud ZenPack',
    experimentalLeakTesting: khongRoRi,
    (tester) async {
      expect(await nhanKho(tester, const _Repo(shopStorageKind: null)), zenpack);
    },
  );

  // Clip cũ nằm ở Drive trong khi shop nay dùng S3: đổi kho KHÔNG kéo clip cũ
  // đi theo, nên mỗi clip phải nói đúng chỗ của chính nó.
  testWidgets(
    'clip cũ ở Drive không bị gọi thành S3 vì shop vừa đổi kho',
    experimentalLeakTesting: khongRoRi,
    (tester) async {
      expect(
        await nhanKho(
          tester,
          const _Repo(
            relayStatus: 'relayed',
            storageKind: 'gdrive',
            r2Key: null,
          ),
        ),
        'Google Drive',
      );
    },
  );

  // Dấu MUỘN — và điều quan trọng nhất là câu KHÔNG được hiện.
  //
  // `sealMismatch` bảo người bán "hãy quay lại clip này". Với 25 clip trên
  // production mang cờ đó, câu ấy vừa sai vừa không làm được: kiện hàng đã đi
  // từ mấy tuần trước, và tệp không hề hỏng — bản gốc mất vì chính hệ thống ghi
  // đè lên nó trước 24/08 (backend `services/late_seal.ts`).
  //
  // Nên ca này canh cả hai chiều: nhãn mới phải hiện, VÀ lời buộc tội cũ phải
  // biến mất. Chỉ canh chiều đầu thì một ngày nào đó cả hai cùng hiện, và người
  // bán vẫn đọc phải câu bảo họ đi quay lại một kiện hàng đã giao.
  testWidgets(
    'dấu muộn: nói lỗi thuộc về hệ thống, KHÔNG bảo người bán quay lại clip',
    experimentalLeakTesting: khongRoRi,
    (tester) async {
      final texts = await chuTrenSheet(
        tester,
        const _Repo(sealStatus: 'sealed_late'),
      );
      expect(
        texts,
        contains('Dấu muộn — video còn nguyên, lỗi thuộc về hệ thống'),
      );
      expect(
        texts,
        isNot(contains('Vân tay không khớp — hãy quay lại clip này')),
      );
    },
  );

  // Đo được trên chính sheet này ngày 28/08: clip mang cờ `hash_mismatch` hiện
  // ra "Trạng thái upload · Đã tải lên" kèm dấu tích, KHÔNG một chữ nào về việc
  // dấu hỏng. Chuỗi `sealMismatch` có đủ trong mười thứ tiếng và chưa bao giờ
  // được vẽ lên màn — vì hàng niêm phong chỉ hiện khi clip còn ĐANG chạy.
  //
  // Người bán đọc dấu tích ấy thành "mọi thứ đều ổn", rồi cầm clip đi khiếu nại.
  testWidgets(
    'trạng thái cuối không được câm: cờ hỏng phải nói ra',
    experimentalLeakTesting: khongRoRi,
    (tester) async {
      final texts = await chuTrenSheet(
        tester,
        const _Repo(sealStatus: 'hash_mismatch'),
      );
      expect(texts, contains('Vân tay không khớp — hãy quay lại clip này'));
    },
  );
}
