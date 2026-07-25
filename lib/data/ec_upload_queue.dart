/// Offline-first upload queue for recorded evidence clips.
///
/// Every recording is copied into the app-documents dir and tracked here so it
/// survives app restarts and OS temp cleanup (FR-08/FR-09: "never lose the
/// seller's evidence"). A pluggable [EcEvidenceUploader] does the actual
/// transport; without one (no backend URL configured) clips simply wait.
library;

// The constructor uses public named params bound to private fields, which
// prefer_initializing_formals can't express (named params can't be private).
// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'ec_uploader.dart';

enum EcUploadState { waiting, uploading, done, error }

/// One queued clip and its upload progress.
class UploadTask {
  UploadTask({
    required this.id,
    required this.tracking,
    required this.type,
    required this.filePath,
    required this.createdAt,
    this.state = EcUploadState.waiting,
    this.progress = 0,
    this.retryCount = 0,
    this.remoteUrl,
  });

  factory UploadTask.fromJson(Map<String, dynamic> json) => UploadTask(
    id: json['id'] as String,
    tracking: json['tracking'] as String,
    type: json['type'] as String,
    filePath: json['filePath'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    state: EcUploadState.values[json['state'] as int],
    progress: (json['progress'] as num).toDouble(),
    retryCount: json['retryCount'] as int,
    remoteUrl: json['remoteUrl'] as String?,
  );

  final String id;
  final String tracking;
  final String type;
  final String filePath;
  final DateTime createdAt;
  EcUploadState state;
  double progress;
  int retryCount;
  String? remoteUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'tracking': tracking,
    'type': type,
    'filePath': filePath,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'state': state.index,
    'progress': progress,
    'retryCount': retryCount,
    'remoteUrl': remoteUrl,
  };
}

class EcUploadQueue extends ChangeNotifier {
  // Private fields + public named params, so an initializing formal (which
  // can't be named and private) doesn't apply here.
  EcUploadQueue({
    EcEvidenceUploader? uploader,
    @visibleForTesting Directory? directory,
  }) : _uploader = uploader,
       _dir = directory;

  final EcEvidenceUploader? _uploader;
  final List<UploadTask> _tasks = [];
  bool _processing = false;
  Directory? _dir;

  /// Newest-first view of the queue.
  List<UploadTask> get tasks => List.unmodifiable(_tasks);

  /// Loads any persisted queue from disk and resumes processing. Call once.
  /// Any failure (corrupt file, or path_provider unavailable in tests) leaves
  /// an empty in-memory queue rather than crashing the app.
  Future<void> load() async {
    try {
      final file = await _queueFile();
      if (file.existsSync()) {
        final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
        _tasks
          ..clear()
          ..addAll(
            raw
                .cast<Map<String, dynamic>>()
                .map(UploadTask.fromJson)
                // Drop entries whose clip file is gone.
                .where((t) => File(t.filePath).existsSync()),
          );
      }
      // An upload interrupted by a kill is retried, not left stuck.
      for (final task in _tasks) {
        if (task.state == EcUploadState.uploading) {
          task
            ..state = EcUploadState.waiting
            ..progress = 0;
        }
      }
    } on Object {
      // Corrupt file / no storage plugin — run with an empty queue.
    }
    notifyListeners();
    unawaited(_process());
  }

  /// Copies [filePath] into the app-documents dir and enqueues it.
  Future<void> enqueue({
    required String tracking,
    required String type,
    required String filePath,
  }) async {
    final dir = await _evidenceDir();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    var stored = '${dir.path}/$id${_ext(filePath)}';
    try {
      await File(filePath).copy(stored);
    } on Object {
      stored = filePath; // Fall back to the original path if the copy fails.
    }
    _tasks.insert(
      0,
      UploadTask(
        id: id,
        tracking: tracking,
        type: type,
        filePath: stored,
        createdAt: DateTime.now(),
      ),
    );
    await _save();
    notifyListeners();
    unawaited(_process());
  }

  /// Moves an errored task back to waiting and kicks the processor.
  Future<void> retry(String id) async {
    final task = _byId(id);
    if (task == null || task.state == EcUploadState.uploading) return;
    task
      ..state = EcUploadState.waiting
      ..progress = 0;
    await _save();
    notifyListeners();
    unawaited(_process());
  }

  Future<void> _process() async {
    if (_processing || _uploader == null) return;
    _processing = true;
    try {
      while (true) {
        final task = _firstWaiting();
        if (task == null) break;
        task
          ..state = EcUploadState.uploading
          ..progress = 0;
        notifyListeners();
        try {
          final url = await _uploader.upload(
            File(task.filePath),
            tracking: task.tracking,
            type: task.type,
            onProgress: (p) {
              task.progress = p;
              notifyListeners();
            },
          );
          task
            ..state = EcUploadState.done
            ..progress = 1
            ..remoteUrl = url;
        } on Object {
          task
            ..state = EcUploadState.error
            ..retryCount += 1;
        }
        await _save();
        notifyListeners();
      }
    } finally {
      _processing = false;
    }
  }

  UploadTask? _firstWaiting() {
    for (final task in _tasks) {
      if (task.state == EcUploadState.waiting) return task;
    }
    return null;
  }

  UploadTask? _byId(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  Future<void> _save() async {
    try {
      final file = await _queueFile();
      await file.writeAsString(
        jsonEncode([for (final t in _tasks) t.toJson()]),
      );
    } on Object {
      // Persistence is best-effort; an in-memory queue still works this session.
    }
  }

  Future<File> _queueFile() async => File('${(await _evidenceDir()).path}/queue.json');

  Future<Directory> _evidenceDir() async {
    final dir = _dir;
    if (dir != null) return dir;
    final base = await getApplicationDocumentsDirectory();
    final evidence = Directory('${base.path}/evidence');
    if (!evidence.existsSync()) evidence.createSync(recursive: true);
    return _dir = evidence;
  }

  static String _ext(String path) {
    final dot = path.lastIndexOf('.');
    final slash = path.lastIndexOf('/');
    return dot > slash ? path.substring(dot) : '.mp4';
  }
}
