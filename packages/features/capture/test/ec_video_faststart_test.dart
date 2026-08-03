import 'dart:io';

import 'package:feature_capture/feature_capture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temp;

  setUp(() => temp = Directory.systemTemp.createTempSync('faststart_test'));
  tearDown(() => temp.deleteSync(recursive: true));

  File writeClip() =>
      File('${temp.path}/clip.mp4')..writeAsStringSync('original bytes');

  group('EcVideoFaststartService.prepare', () {
    test(
      'returns the remuxed copy and removes the source on success',
      () async {
        // Arrange
        final clip = writeClip();
        late String issued;
        final service = EcVideoFaststartService(
          outputDirectory: temp,
          runner: (command) async {
            issued = command;
            final output = RegExp(r'"([^"]+)"$').firstMatch(command)!.group(1)!;
            File(output).writeAsStringSync('remuxed bytes');
            return true;
          },
        );

        // Act
        final result = await service.prepare(clip.path);

        // Assert
        expect(result, isNot(clip.path));
        expect(File(result).existsSync(), isTrue);
        expect(clip.existsSync(), isFalse);
        // Hình vẫn được copy nguyên (không giải mã lại); chỉ tiếng bị mã hoá lại
        // để làm câm đoạn đầu chứa tút + "đã bắt đầu quay".
        // Thuần remux: clip không có luồng tiếng nên không cần lọc gì.
        expect(issued, contains('-c copy'));
        expect(issued, contains('-movflags +faststart'));
      },
    );

    test('keeps the original clip when ffmpeg fails', () async {
      // Arrange — the branch that must never lose evidence.
      final clip = writeClip();
      final service = EcVideoFaststartService(
        outputDirectory: temp,
        runner: (_) async => false,
      );

      // Act
      final result = await service.prepare(clip.path);

      // Assert
      expect(result, clip.path);
      expect(clip.readAsStringSync(), 'original bytes');
    });

    test('keeps the original clip when ffmpeg throws', () async {
      // Arrange
      final clip = writeClip();
      final service = EcVideoFaststartService(
        outputDirectory: temp,
        runner: (_) async => throw StateError('native boom'),
      );

      // Act
      final result = await service.prepare(clip.path);

      // Assert
      expect(result, clip.path);
      expect(clip.existsSync(), isTrue);
    });

    test(
      'keeps the original path when ffmpeg reports success but wrote nothing',
      () async {
        // Arrange
        final clip = writeClip();
        final service = EcVideoFaststartService(
          outputDirectory: temp,
          runner: (_) async => true,
        );

        // Act
        final result = await service.prepare(clip.path);

        // Assert
        expect(result, clip.path);
        expect(clip.existsSync(), isTrue);
      },
    );

    test('passes a missing input straight through', () async {
      // Arrange
      final service = EcVideoFaststartService(
        outputDirectory: temp,
        runner: (_) async => fail('must not run ffmpeg on a missing file'),
      );

      // Act
      final result = await service.prepare('${temp.path}/gone.mp4');

      // Assert
      expect(result, '${temp.path}/gone.mp4');
    });
  });
}
