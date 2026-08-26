import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';

/// Speaks short status announcements (recording started/stopped, wrong code)
/// out loud, so a seller packing with both hands free hears the app's state
/// instead of having to look at the screen. Wraps `flutter_tts` so features
/// depend on this port, not the plugin.
@lazySingleton
class VoiceAnnouncerService {
  VoiceAnnouncerService({FlutterTts? tts}) : _tts = tts ?? FlutterTts() {
    _tts.setLanguage(_tag).catchError((_) => false);
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

  /// Speaks `text` aloud. `flutter_tts.speak` already interrupts whatever is
  /// currently playing before starting the new utterance — an extra `stop()`
  /// round-trip first only added latency between the action (start/stop
  /// recording) and hearing its announcement. A missing or misbehaving TTS
  /// engine (or no platform implementation, as in tests) silently skips the
  /// announcement rather than surfacing an error — recording must keep
  /// working either way.
  /// Mã BCP-47 của giọng đang dùng. Đổi ngôn ngữ giao diện là đổi luôn giọng
  /// đọc: người bán Thái không cần một câu tiếng Việt phát ra giữa kho hàng.
  String _tag = 'vi-VN';

  /// Mã engine đã chốt được cho [_tag], rỗng nghĩa là chưa chốt.
  String _resolved = '';

  /// Đổi giọng đọc sang [tag] (ví dụ `th-TH`).
  ///
  /// Chỉ đặt cờ rồi để [_ensureLanguage] làm việc thật ở lần đọc kế tiếp —
  /// người dùng đổi ngôn ngữ trong Cài đặt chứ không phải giữa lúc đóng hàng,
  /// nên không có gì gấp ở đây.
  Future<void> useLanguage(String tag) async {
    if (tag == _tag) return;
    _tag = tag;
    _resolved = '';
    await _ensureLanguage();
  }

  /// Chốt mã ngôn ngữ engine TTS thật sự hiểu, ngay trước khi đọc.
  ///
  /// `setLanguage` trong constructor bắn đi mà không chờ, trong khi engine TTS
  /// của Android còn chưa bind xong — lệnh rơi vào hư không, rồi máy đọc bằng
  /// ngôn ngữ hệ thống. Hỏi engine xem nó có mã nào cho thứ tiếng này rồi đặt
  /// đúng mã đó, vì mỗi engine trả về một dạng khác nhau: `th-TH`, `th_TH`,
  /// hoặc chỉ `th`.
  ///
  /// Máy KHÔNG có giọng cho thứ tiếng đó (Android hay thiếu Thái, Mã Lai,
  /// Filipino) thì rơi về tiếng Anh: người quay vẫn nghe được máy đã nhận hay
  /// chưa, và đó là việc câu nói sinh ra để làm. Im lặng mới là mất chức năng.
  Future<void> _ensureLanguage() async {
    if (_resolved == _tag) return;
    final wanted = _tag;
    final prefix = wanted.split('-').first.toLowerCase();
    try {
      for (final code in [wanted, wanted.replaceAll('-', '_'), prefix]) {
        if (await _tts.isLanguageAvailable(code) == true) {
          await _tts.setLanguage(code);
          _resolved = wanted;
          debugPrint('[zenpack.tts] dung giong $code');
          return;
        }
      }
      // Không mã nào khớp thì soi danh sách engine tự khai.
      final languages = (await _tts.getLanguages as List<dynamic>)
          .map((e) => e.toString())
          .toList();
      final match = languages.firstWhere(
        (code) => code.toLowerCase().replaceAll('_', '-').startsWith(prefix),
        orElse: () => '',
      );
      if (match.isNotEmpty) {
        await _tts.setLanguage(match);
        _resolved = wanted;
        debugPrint('[zenpack.tts] dung giong $match');
        return;
      }
      debugPrint('[zenpack.tts] MAY KHONG CO GIONG $wanted, doc tieng Anh');
      final english = languages.firstWhere(
        (code) => code.toLowerCase().startsWith('en'),
        orElse: () => 'en-US',
      );
      await _tts.setLanguage(english);
      _resolved = wanted;
    } on Object catch (error) {
      debugPrint('[zenpack.tts] loi: $error');
    }
  }

  /// Làm nóng engine TTS trước khi có câu nào cần đọc thật.
  ///
  /// Câu đầu tiên của mỗi lượt chạy phải trả giá cho [_ensureLanguage]: tới ba
  /// lượt hỏi `isLanguageAvailable` rồi một lượt `setLanguage`, tất cả đều là
  /// round-trip sang engine TTS của hệ điều hành. Người quay nghe ra đúng cái
  /// khoảng lặng giữa tiếng tút và câu "Đã bắt đầu quay" — mà lúc ấy thì không
  /// còn gì che được nữa.
  ///
  /// Gọi lúc dựng camera: màn quay vừa mở, chưa ai bấm gì, engine có cả quãng
  /// đó để bind xong. Best-effort như mọi thứ khác trong lớp này.
  Future<void> prepare() => _ensureLanguage();

  Future<void> speak(String text) async {
    try {
      await _ensureLanguage();
      await _tts.speak(text);
    } on Object {
      // See above: announcements are best-effort.
    }
  }
}
