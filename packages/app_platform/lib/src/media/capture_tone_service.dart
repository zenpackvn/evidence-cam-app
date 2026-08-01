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
    _player.setPlayerMode(PlayerMode.lowLatency).catchError((_) {});
    _player.setReleaseMode(ReleaseMode.stop).catchError((_) {});
  }

  final AudioPlayer _player;

  /// Where the beep lives in the app bundle, relative to `assets/`.
  static const _beepAsset = 'sounds/beep.wav';

  /// Plays the beep. Best-effort like the spoken announcements: a device with
  /// no audio output, a busy audio focus, or a missing asset silently skips it
  /// rather than failing the recording that just started.
  Future<void> beep() async {
    try {
      await _player.stop();
      await _player.play(AssetSource(_beepAsset));
    } on Object {
      // See above: the tone is a nicety, never a reason to break capture.
    }
  }

  /// Releases the underlying player. The app holds one instance for its
  /// lifetime, so this only matters for tests.
  Future<void> dispose() async {
    try {
      await _player.dispose();
    } on Object {
      // Nothing useful to do if the plugin is already gone.
    }
  }
}
