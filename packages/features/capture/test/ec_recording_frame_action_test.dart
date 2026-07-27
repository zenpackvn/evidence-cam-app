import 'package:feature_capture/feature_capture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('recordingFrameAction (hands-free A→B / end-QR)', () {
    test('ignores nothing, noise, or the same bill still under the camera', () {
      expect(recordingFrameAction(null, 'A'), RecordingFrameAction.ignore);
      expect(recordingFrameAction('', 'A'), RecordingFrameAction.ignore);
      expect(recordingFrameAction('A', 'A'), RecordingFrameAction.ignore);
    });

    test('cuts over when a different order bill appears', () {
      expect(recordingFrameAction('B', 'A'), RecordingFrameAction.cutover);
    });

    test('ignores the same bill when case or whitespace differs', () {
      expect(
        recordingFrameAction(' spxvn12345 ', 'SPXVN 12345'),
        RecordingFrameAction.ignore,
      );
    });

    test('ends the session on the printed end-QR', () {
      expect(
        recordingFrameAction(kEndSessionQr, 'A'),
        RecordingFrameAction.endSession,
      );
    });

    test('end-QR is treated as end, not as a cut-over to a new order', () {
      // kEndSessionQr differs from the current code but must never start a clip.
      expect(
        recordingFrameAction(kEndSessionQr, 'SPXVN024567890'),
        RecordingFrameAction.endSession,
      );
    });
  });
}
