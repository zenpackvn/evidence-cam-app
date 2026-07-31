import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ffmpeg_kit_extended_flutter/ffmpeg_kit_extended_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

/// Burns a status-bar-style overlay (recording time, tracking code, battery,
/// connectivity) onto a just-finished evidence clip, so that information
/// travels with the video file itself — wherever it's later viewed or
/// downloaded — rather than only inside the app's own recording screen.
class EcVideoStampService {
  EcVideoStampService({Battery? battery, Connectivity? connectivity})
    : _battery = battery ?? Battery(),
      _connectivity = connectivity ?? Connectivity();

  final Battery _battery;
  final Connectivity _connectivity;

  // The asset this package bundles (see pubspec.yaml) — extracted to a real
  // file the first time it's needed, since ffmpeg's `fontfile` option needs
  // an on-disk path, not an asset-bundle entry. `/system/fonts/*` looked
  // like a shortcut but modern Android sandboxing can make it unreadable
  // from the app's own process, silently defeating drawtext.
  static const _fontAsset =
      'packages/feature_capture/assets/fonts/Roboto-Regular.ttf';

  static Future<void>? _ready;
  static Future<String>? _fontFile;

  Future<void> _ensureReady() => _ready ??= FFmpegKitExtended.initialize();

  Future<String> _ensureFontFile() => _fontFile ??= _extractFontFile();

  Future<String> _extractFontFile() async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/ec_stamp_roboto_regular.ttf');
    if (!file.existsSync()) {
      final bytes = await rootBundle.load(_fontAsset);
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    }
    return file.path;
  }

  /// Overlays [label] (tracking code + type) and [recordedAt] onto
  /// [inputPath]. Returns the stamped file's path, or [inputPath] unchanged
  /// if stamping fails for any reason — a clip without the burned-in
  /// overlay is still better than losing it outright.
  Future<String> stamp(
    String inputPath, {
    required String label,
    required DateTime recordedAt,
  }) async {
    if (!File(inputPath).existsSync()) return inputPath;
    try {
      await _ensureReady();
      final fontPath = await _ensureFontFile();
      final overlay = await _overlayText(label, recordedAt);
      final outputPath = await _outputPathFor(inputPath);
      final drawText =
          'drawtext=fontfile=$fontPath:'
          "text='${_escape(overlay)}':"
          'fontcolor=white:fontsize=26:box=1:boxcolor=black@0.55:'
          'boxborderw=10:x=20:y=20';
      final command =
          '-y -i "$inputPath" -vf "$drawText" -c:a copy "$outputPath"';
      final ok = await _run(command);
      return ok && File(outputPath).existsSync() ? outputPath : inputPath;
    } on Object {
      return inputPath;
    }
  }

  Future<String> _outputPathFor(String inputPath) async {
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return '${dir.path}/evidence_stamped_$stamp.mp4';
  }

  Future<String> _overlayText(String label, DateTime recordedAt) async {
    final date =
        '${_two(recordedAt.day)}/${_two(recordedAt.month)}/${recordedAt.year}';
    final time =
        '${_two(recordedAt.hour)}:${_two(recordedAt.minute)}:${_two(recordedAt.second)}';
    final battery = await _batteryLabel();
    final connectivity = await _connectivityLabel();
    final parts = [
      '$date · $time',
      label,
      ?battery,
      ?connectivity,
    ];
    return parts.join(' · ');
  }

  Future<String?> _batteryLabel() async {
    try {
      final level = await _battery.batteryLevel;
      return '$level% pin';
    } on Object {
      return null;
    }
  }

  Future<String?> _connectivityLabel() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.wifi)) return 'WiFi';
      if (results.contains(ConnectivityResult.mobile)) return 'Di động';
      return 'Không mạng';
    } on Object {
      return null;
    }
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  // ffmpeg's drawtext treats `:` as an option separator, `\`/`'` as
  // escape/quote characters within the filter-graph string, and `%` as the
  // start of a `%{...}` expansion (e.g. `%{pts}`) — a literal `%` (from a
  // battery percentage) needs doubling or it's a syntax error.
  static String _escape(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll(':', r'\:')
      .replaceAll("'", r"\'")
      .replaceAll('%', '%%');

  Future<bool> _run(String command) {
    final completer = Completer<bool>();
    FFmpegKit.executeAsync(
      command,
      onComplete: (session) {
        var success = false;
        try {
          success = ReturnCode.isSuccess(session.getReturnCode());
        } on Object {
          // Treated as failure below — the caller falls back to inputPath.
        }
        if (!completer.isCompleted) completer.complete(success);
      },
    );
    return completer.future;
  }
}
