/// Moves a just-recorded clip's `moov` atom to the front of the file so it can
/// start playing before it has fully downloaded.
///
/// Android's `MediaRecorder` and iOS's `AVAssetWriter` both write `moov` (the
/// index a player needs to decode anything at all) at the *end* of the file.
/// Served over plain HTTP that means a player must fetch the whole clip before
/// the first frame appears, and seeking is guesswork — the exact symptom
/// evidence review hits on a slow connection.
///
/// This is a **remux, not a transcode**: `-c copy` rewrites the container
/// around the existing streams, so every video and audio sample comes out
/// bit-identical and the display-matrix (rotation) metadata is preserved. That
/// keeps FR-07's chain-of-custody rule intact — the evidence is untouched, only
/// the box around it is reordered. It costs a few hundred milliseconds instead
/// of the tens of seconds a re-encode took.
library;

// The constructor binds public named params to private fields, which
// prefer_initializing_formals can't express (named params can't be private).
// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_extended_flutter/ffmpeg_kit_extended_flutter.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path_provider/path_provider.dart';

/// Runs one ffmpeg command, reporting whether it succeeded.
///
/// A seam so the fallback path below can be tested without a platform channel
/// — matching how `CameraService` and `ApiEvidenceUploader` take their own
/// native dependencies.
typedef FfmpegRunner = Future<bool> Function(String command);

class EcVideoFaststartService {
  EcVideoFaststartService({
    @visibleForTesting FfmpegRunner? runner,
    @visibleForTesting Directory? outputDirectory,
  }) : _runner = runner,
       _outputDirectory = outputDirectory;

  final FfmpegRunner? _runner;
  final Directory? _outputDirectory;

  static Future<void>? _ready;

  /// No-op when a test runner was injected — no native library to load.
  Future<void> _ensureReady() => _runner != null
      ? Future<void>.value()
      : (_ready ??= FFmpegKitExtended.initialize());

  /// Returns the path of a streamable copy of [inputPath], or [inputPath]
  /// unchanged if the remux fails for any reason — a clip that merely buffers
  /// badly is still better than no evidence at all.
  ///
  /// On success the source file is deleted: the remuxed copy replaces it and
  /// keeping both doubles temp usage on a phone that may already be low on
  /// storage.
  Future<String> prepare(String inputPath) async {
    if (!File(inputPath).existsSync()) return inputPath;
    try {
      await _ensureReady();
      final outputPath = await _outputPathFor();
      final ok = await _run(
        '-y -i "$inputPath" -c copy -movflags +faststart "$outputPath"',
      );
      if (!ok || !File(outputPath).existsSync()) return inputPath;
      await _deleteQuietly(inputPath);
      return outputPath;
    } on Object {
      return inputPath;
    }
  }

  Future<String> _outputPathFor() async {
    final dir = _outputDirectory ?? await getTemporaryDirectory();
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return '${dir.path}/evidence_faststart_$stamp.mp4';
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      await File(path).delete();
    } on Object {
      // Already gone, or not ours to delete — nothing to clean up.
    }
  }

  Future<bool> _run(String command) {
    final injected = _runner;
    if (injected != null) return injected(command);
    final completer = Completer<bool>();
    FFmpegKit.executeAsync(
      command,
      onComplete: (session) {
        var success = false;
        try {
          success = ReturnCode.isSuccess(session.getReturnCode());
        } on Object {
          success = false;
        }
        if (!completer.isCompleted) completer.complete(success);
      },
    );
    return completer.future;
  }
}
