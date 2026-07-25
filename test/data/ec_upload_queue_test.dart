import 'dart:io';

import 'package:flutter_starter_template/data/ec_upload_queue.dart';
import 'package:flutter_starter_template/data/ec_uploader.dart';
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
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(1);
    final index = _calls < _results.length ? _calls : _results.length - 1;
    _calls++;
    final result = _results[index];
    if (result is String) return result;
    throw result as Exception;
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

    await queue.enqueue(tracking: 'SPX1', type: 'Đóng hàng', filePath: clip.path);
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

    await queue.enqueue(tracking: 'SPX2', type: 'Trả hàng', filePath: clip.path);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(queue.tasks.single.state, EcUploadState.error);
    expect(queue.tasks.single.retryCount, 1);

    await queue.retry(queue.tasks.single.id);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(queue.tasks.single.state, EcUploadState.done);
  });

  test('without an uploader clips persist and wait', () async {
    final queue = EcUploadQueue(directory: dir);

    await queue.enqueue(tracking: 'SPX3', type: 'Đóng hàng', filePath: clip.path);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(queue.tasks.single.state, EcUploadState.waiting);
    // A fresh queue over the same directory reloads the persisted task.
    final reloaded = EcUploadQueue(directory: dir);
    await reloaded.load();
    expect(reloaded.tasks, hasLength(1));
    expect(reloaded.tasks.single.tracking, 'SPX3');
  });
}
