import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';

/// Speaks short status announcements (recording started/stopped, wrong code)
/// out loud, so a seller packing with both hands free hears the app's state
/// instead of having to look at the screen. Wraps `flutter_tts` so features
/// depend on this port, not the plugin.
@lazySingleton
class VoiceAnnouncerService {
  VoiceAnnouncerService({FlutterTts? tts}) : _tts = tts ?? FlutterTts() {
    _tts.setLanguage('vi-VN').catchError((_) => false);
    _tts.setSpeechRate(0.5).catchError((_) => false);
    // Makes `speak` complete when the utterance actually finishes, not when it
    // is merely queued. The capture flow needs that: it waits for the
    // start-of-recording announcement to end before rolling the camera, so the
    // phone's own speaker doesn't get recorded into the evidence clip.
    _tts.awaitSpeakCompletion(true).catchError((_) => false);
    // Khai báo phiên âm thanh riêng cho TTS.
    //
    // Không khai thì câu nói im bặt mỗi khi thứ khác giành phiên: ffmpeg chạy
    // nung tem sau mỗi clip là một, cuộc gọi đến là hai. `mixWithOthers` cho
    // nó chen vào cùng, `duckOthers` hạ tiếng nền xuống trong lúc đọc.
    _tts
        .setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.duckOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        )
        .catchError((_) {});
  }

  final FlutterTts _tts;

  /// Khai báo lại phiên âm thanh sau khi bị hệ điều hành thu hồi.
  ///
  /// Cuộc gọi đến làm iOS TẮT phiên âm thanh của app. Nó không tự bật lại khi
  /// app quay về, nên mọi tiếng sau đó im bặt — khai lại một lần lúc trở lại là
  /// đủ. Best-effort như mọi thứ khác trong lớp này.
  Future<void> reactivate() async {
    try {
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.duckOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    } on Object {
      // Không khai lại được thì cùng lắm mất tiếng, không được làm hỏng gì.
    }
  }

  /// Speaks [text] aloud. `flutter_tts.speak` already interrupts whatever is
  /// currently playing before starting the new utterance — an extra `stop()`
  /// round-trip first only added latency between the action (start/stop
  /// recording) and hearing its announcement. A missing or misbehaving TTS
  /// engine (or no platform implementation, as in tests) silently skips the
  /// announcement rather than surfacing an error — recording must keep
  /// working either way.
  Future<void> speak(String text) async {
    try {
      await _tts.speak(text);
    } on Object {
      // See above: announcements are best-effort.
    }
  }
}
