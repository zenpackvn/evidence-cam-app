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
  }

  final FlutterTts _tts;

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
