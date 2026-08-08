import 'dart:io';

import 'package:feature_capture/feature_capture.dart';
import 'package:flutter_test/flutter_test.dart';

/// Uploader whose outcome is scripted per call, so we can drive the queue's
/// state machine deterministically without a network.
class _FakeUploader implements EcEvidenceUploader {
  _FakeUploader(this._results);
  final List<Object> _results; // String url = success, Exception = failure.
  int _calls = 0;

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
    onProgress?.call(1);
    final index = _calls < _results.length ? _calls : _results.length - 1;
    _calls++;
    final result = _results[index];
    if (result is String) return result;
    if (result is Exception) throw result;
    if (result is Error) throw result;
    throw StateError('Unexpected upload result: $result');
  }
}

/// Kho sống qua nhiều lần dựng hàng đợi — thứ mô phỏng ObjectBox thật, và là
/// điều kiện cần để test được kịch bản khôi phục máy.
class _MemoryStore implements EvidenceClipStore {
  final _rows = <String, UploadTask>{};

  @override
  Future<List<UploadTask>> loadAll() async => _rows.values.toList();

  @override
  Future<void> save(UploadTask task) async => _rows[task.id] = task;

  @override
  Future<void> remove(String id) async => _rows.remove(id);
}

void main() {
  late Directory dir;
  late File clip;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('ec_queue_test');
    clip = File('${dir.path}/clip.mp4')..writeAsStringSync('video-bytes');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  // Hợp đồng của hàng đợi ĐÃ ĐỔI: upload xong thì task RỜI hàng đợi, không nằm
  // lại dưới dạng `done`. Lý do ghi ngay trong `_process`: clip lúc đó đã nằm
  // trên dòng thời gian bằng chứng của vận đơn, để lại một mục "xong" vĩnh viễn
  // ở đây là kể cùng một việc hai lần.
  //
  // Ba test dưới đây từng khẳng định điều ngược lại và đỏ vì vậy — không phải
  // vì hàng đợi "không chạy trong test" như chẩn đoán ban đầu. Nó chạy, chạy
  // xong, rồi dọn chỗ.
  test('upload xong thì clip RỜI hàng đợi', () async {
    final queue = EcUploadQueue(
      uploader: _FakeUploader(['https://cdn/x.mp4']),
      directory: dir,
    );

    await queue.enqueue(
      tracking: 'SPX1',
      type: 'Đóng hàng',
      filePath: clip.path,
    );
    // Let the async processor run to completion.
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(queue.tasks, isEmpty);
  });

  // Cách chép tệp phải kiểm trên một task CÒN Ở LẠI, nên dùng uploader hỏng.
  // Kiểm nó ở đường thành công là không thể: task và bản sao đều bị dọn.
  test('enqueue chép clip vào thư mục riêng, lưu TÊN TỆP TRẦN', () async {
    final queue = EcUploadQueue(
      uploader: _FakeUploader([Exception('offline')]),
      directory: dir,
    );

    await queue.enqueue(
      tracking: 'SPX1',
      type: 'Đóng hàng',
      filePath: clip.path,
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final task = queue.tasks.single;
    expect(task.tracking, 'SPX1');
    // The clip was copied into the queue's own directory (not the temp source).
    expect(task.filePath, isNot(clip.path));
    // `filePath` lưu tên tệp TRẦN, không phải đường dẫn tuyệt đối — xem
    // [EcUploadQueue.absolutePathOf] và lý do (iOS đổi UUID container).
    expect(task.filePath, isNot(contains('/')));
    expect(File(queue.absolutePathOf(task.filePath)).existsSync(), isTrue);
  });

  test('a failed upload goes to error and retry re-uploads to done', () async {
    final queue = EcUploadQueue(
      uploader: _FakeUploader([Exception('offline'), 'https://cdn/x.mp4']),
      directory: dir,
    );

    await queue.enqueue(
      tracking: 'SPX2',
      type: 'Trả hàng',
      filePath: clip.path,
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(queue.tasks.single.state, EcUploadState.error);
    expect(queue.tasks.single.retryCount, 1);

    await queue.retry(queue.tasks.single.id);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(queue.tasks, isEmpty);
  });

  test('quota failures wait for quota and retry can resume upload', () async {
    final queue = EcUploadQueue(
      uploader: _FakeUploader([
        StateError('quota_exceeded'),
        'https://cdn/x.mp4',
      ]),
      directory: dir,
    );

    await queue.enqueue(
      tracking: 'SPXQ',
      type: 'Đóng hàng',
      filePath: clip.path,
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(queue.tasks.single.state, EcUploadState.quotaWait);
    expect(queue.tasks.single.retryCount, 0);

    await queue.retry(queue.tasks.single.id);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(queue.tasks, isEmpty);
  });

  test('without an uploader clips persist and wait', () async {
    final store = InMemoryEvidenceClipStore();
    final queue = EcUploadQueue(directory: dir, store: store);

    await queue.enqueue(
      tracking: 'SPX3',
      type: 'Đóng hàng',
      filePath: clip.path,
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(queue.tasks.single.state, EcUploadState.waiting);
    // A fresh queue over the same store reloads the persisted task (the store
    // stands in for the shared ObjectBox DB used in the app).
    final reloaded = EcUploadQueue(directory: dir, store: store);
    await reloaded.load();
    expect(reloaded.tasks, hasLength(1));
    expect(reloaded.tasks.single.tracking, 'SPX3');
  });

  test('entity ↔ task mapping round-trips state, shop and remote url', () {
    final task = UploadTask(
      id: 't1',
      tracking: 'SPX9',
      type: 'Trả hàng',
      filePath: '/tmp/x.mp4',
      createdAt: DateTime.fromMillisecondsSinceEpoch(1720000000000),
      shopId: 'shop-7',
      state: EcUploadState.error,
      progress: 0.5,
      retryCount: 2,
      remoteUrl: 'https://cdn/x.mp4',
    );

    final back = taskFromEntity(entityFromTask(task));

    expect(back.id, 't1');
    expect(back.tracking, 'SPX9');
    expect(back.type, 'Trả hàng');
    expect(back.shopId, 'shop-7');
    expect(back.state, EcUploadState.error);
    expect(back.retryCount, 2);
    expect(back.remoteUrl, 'https://cdn/x.mp4');
    expect(back.createdAt, DateTime.fromMillisecondsSinceEpoch(1720000000000));
  });

  group('local file reclamation', () {
    late Directory temp;

    setUp(() => temp = Directory.systemTemp.createTempSync('ec_queue_temp'));
    tearDown(() => temp.deleteSync(recursive: true));

    test('deletes a temp source once its durable copy exists', () async {
      final source = File('${temp.path}/${evidenceFaststartPrefix}1.mp4')
        ..writeAsStringSync('video-bytes');
      final queue = EcUploadQueue(directory: dir, temporaryDirectory: temp);

      await queue.enqueue(
        tracking: 'SPX1',
        type: 'Đóng hàng',
        filePath: source.path,
      );

      expect(source.existsSync(), isFalse);
      expect(
        File(queue.absolutePathOf(queue.tasks.single.filePath)).existsSync(),
        isTrue,
      );
    });

    // LỖI MẤT BẰNG CHỨNG (sửa 2026-08-07). Trước đây `filePath` lưu đường dẫn
    // TUYỆT ĐỐI. Trên iOS, mã UUID của container đổi mỗi lần khôi phục từ sao
    // lưu hoặc chuyển sang máy mới — mọi đường dẫn chết cùng lúc, `load()` rụng
    // sạch hàng đợi, rồi `_sweepOrphans()` thấy 0 tham chiếu và XOÁ LUÔN những
    // tệp vừa được khôi phục. Bản duy nhất sống sót qua việc mất máy bị chính
    // app xoá, im lặng, ngay lần mở đầu tiên.
    test(
      'clip sống sót khi thư mục app đổi đường dẫn (khôi phục iOS)',
      () async {
        final store = _MemoryStore();
        final before = EcUploadQueue(directory: dir, store: store);
        await before.enqueue(
          tracking: 'SPX-restore',
          type: 'Đóng hàng',
          filePath: clip.path,
        );
        final stored = before.tasks.single.filePath;

        // Giả lập khôi phục: cùng nội dung, thư mục mới (UUID container mới).
        final restored = Directory.systemTemp.createTempSync(
          'ec_queue_restored',
        );
        File('${dir.path}/$stored').copySync('${restored.path}/$stored');

        final after = EcUploadQueue(directory: restored, store: store);
        await after.load();

        expect(after.tasks, hasLength(1), reason: 'hàng đợi phải sống sót');
        expect(
          File(after.absolutePathOf(after.tasks.single.filePath)).existsSync(),
          isTrue,
          reason: 'tệp phải còn nguyên, không bị sweep xoá',
        );
        restored.deleteSync(recursive: true);
      },
    );

    // Sàn an toàn: một lượt "dọn rác" sắp xoá 100% thư mục là tín hiệu có bug,
    // không phải một lượt dọn dẹp. Chịu tốn vài MB rác còn hơn xoá nhầm bản
    // duy nhất của một clip bằng chứng.
    test('không xoá sạch thư mục khi hàng đợi rỗng', () async {
      final orphan = File('${dir.path}/1754000000000.mp4')
        ..writeAsStringSync('có thể là bằng chứng vừa khôi phục');

      await EcUploadQueue(directory: dir, temporaryDirectory: temp).load();

      expect(orphan.existsSync(), isTrue);
    });

    test('never deletes a source outside the temp dir', () async {
      // A path the user owns must survive: only throwaway copies are reclaimed.
      final queue = EcUploadQueue(directory: dir, temporaryDirectory: temp);

      await queue.enqueue(
        tracking: 'SPX2',
        type: 'Ảnh đính kèm',
        filePath: clip.path,
      );

      expect(clip.existsSync(), isTrue);
    });

    test('load reclaims unreferenced clips in both directories', () async {
      // Có ÍT NHẤT một clip còn được tham chiếu — nếu không, sàn an toàn của
      // [_sweepOrphans] sẽ chặn cả lượt dọn (xem test ngay dưới). Ở đây ta
      // đang kiểm tra việc dọn rác bình thường, không phải cái sàn đó.
      final live = EcUploadQueue(directory: dir, temporaryDirectory: temp);
      await live.enqueue(
        tracking: 'SPX-live',
        type: 'Đóng hàng',
        filePath: clip.path,
      );

      final orphanStored = File('${dir.path}/stale.mp4')
        ..writeAsStringSync('orphan');
      final orphanRemux = File('${temp.path}/${evidenceFaststartPrefix}9.mp4')
        ..writeAsStringSync('orphan');
      final unrelated = File('${temp.path}/somebody-elses.mp4')
        ..writeAsStringSync('keep');

      await live.load();

      expect(orphanStored.existsSync(), isFalse);
      expect(orphanRemux.existsSync(), isFalse);
      expect(unrelated.existsSync(), isTrue);
    });

    test('load keeps a clip its task still references', () async {
      final store = InMemoryEvidenceClipStore();
      final kept = File('${dir.path}/kept.mp4')..writeAsStringSync('video');
      await store.save(
        UploadTask(
          id: 'k1',
          tracking: 'SPX3',
          type: 'Đóng hàng',
          filePath: kept.path,
          createdAt: DateTime.now(),
        ),
      );

      await EcUploadQueue(
        store: store,
        directory: dir,
        temporaryDirectory: temp,
      ).load();

      expect(kept.existsSync(), isTrue);
    });
  });
}
