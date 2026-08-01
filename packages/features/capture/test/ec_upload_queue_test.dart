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

void main() {
  late Directory dir;
  late File clip;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('ec_queue_test');
    clip = File('${dir.path}/clip.mp4')..writeAsStringSync('video-bytes');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('enqueue uploads the clip and marks it done', () async {
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

    expect(queue.tasks, hasLength(1));
    final task = queue.tasks.single;
    expect(task.tracking, 'SPX1');
    expect(task.state, EcUploadState.done);
    expect(task.remoteUrl, 'https://cdn/x.mp4');
    // The clip was copied into the queue's own directory (not the temp source).
    expect(task.filePath, isNot(clip.path));
    expect(File(task.filePath).existsSync(), isTrue);
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

    expect(queue.tasks.single.state, EcUploadState.done);
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

    expect(queue.tasks.single.state, EcUploadState.done);
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
      expect(File(queue.tasks.single.filePath).existsSync(), isTrue);
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
      final orphanStored = File('${dir.path}/stale.mp4')
        ..writeAsStringSync('orphan');
      final orphanRemux = File('${temp.path}/${evidenceFaststartPrefix}9.mp4')
        ..writeAsStringSync('orphan');
      final unrelated = File('${temp.path}/somebody-elses.mp4')
        ..writeAsStringSync('keep');

      await EcUploadQueue(directory: dir, temporaryDirectory: temp).load();

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
