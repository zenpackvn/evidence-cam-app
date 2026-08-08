import 'package:audioplayers/audioplayers.dart';
import 'package:injectable/injectable.dart';

/// Plays the short confirmation beep that fires the moment a bill is scanned
/// and recording starts.
///
/// The seller is packing with both hands and isn't looking at the screen, so
/// the beep is what tells them the scan registered — the spoken "Đã bắt đầu
/// quay" that follows takes the TTS engine a beat to start, which is too slow
/// to feel like a response to the scan. Wraps `audioplayers` so features depend
/// on this port, not the plugin.
@lazySingleton
class CaptureToneService {
  CaptureToneService({AudioPlayer? player})
    : _player = player ?? AudioPlayer(playerId: 'capture_tone') {
    // Low latency drops the per-play setup the default mode does, so the beep
    // lands with the scan instead of trailing it.
    _player!.setPlayerMode(PlayerMode.lowLatency).catchError((_) {});
    _player.setReleaseMode(ReleaseMode.stop).catchError((_) {});
  }

  /// Bản CÂM: không dựng `AudioPlayer` nào, [beep] và [dispose] không làm gì.
  ///
  /// Dành cho test. Bản thường dựng `AudioPlayer(playerId: 'capture_tone')` —
  /// một id CỐ ĐỊNH, đúng vì cả app chỉ có một instance (`@lazySingleton`).
  /// Nhưng một file test dựng hàng chục bloc, mỗi bloc một dịch vụ, tất cả cùng
  /// id và không có plugin nào trả lời: từ bloc thứ hai trở đi `beep()` và
  /// `dispose()` treo cho tới khi hết 30 giây của trình chạy test.
  ///
  /// Đây là lý do nên tiêm nó, chứ không phải nới assertion cho khớp.
  CaptureToneService.silent() : _player = null;

  final AudioPlayer? _player;

  /// Where the beep lives in the app bundle, relative to `assets/`.
  static const _beepAsset = 'sounds/beep.wav';

  /// Plays the beep. Best-effort like the spoken announcements: a device with
  /// no audio output, a busy audio focus, or a missing asset silently skips it
  /// rather than failing the recording that just started.
  Future<void> beep() async {
    final player = _player;
    if (player == null) return;
    try {
      await player.stop();
      await player.play(AssetSource(_beepAsset));
    } on Object {
      // See above: the tone is a nicety, never a reason to break capture.
    }
  }

  /// Releases the underlying player. The app holds one instance for its
  /// lifetime, so this only matters for tests.
  Future<void> dispose() async {
    final player = _player;
    if (player == null) return;
    try {
      await player.dispose();
    } on Object {
      // Nothing useful to do if the plugin is already gone.
    }
  }
}
