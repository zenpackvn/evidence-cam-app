// Architecture guardrail: the "wrapper rule". Feature packages must consume
// third-party dependencies only through the app-owned infra package that wraps
// them (network, storage, database, config, analytics, app_platform,
// sync_connectivity_plus, ...) — never by importing the third-party package
// directly. CLAUDE.md states this invariant in prose ("infra packages own
// their third-party dependencies behind a package entry point; the app depends
// on network, not on dio"); this test makes it executable.
//
// Note the infra barrels intentionally *re-export* some plugins (e.g.
// `app_platform.dart` re-exports `permission_handler`, `storage.dart`
// re-exports `flutter_secure_storage`). That is allowed: a feature importing
// `package:app_platform/app_platform.dart` and using a re-exported type still
// crosses the wrapper boundary. What this test forbids is a *direct*
// `import 'package:<thirdparty>/...'` in feature code, which bypasses the seam
// and couples the feature to the plugin.
//
// Scoped to `packages/features/**/lib` — mirroring authenticated_dio_test's
// scope. The app shell (`lib/`) is the composition root and may legitimately
// touch platform-init packages (e.g. firebase_core) directly, so it is not
// covered here.
//
// Pure file-scan, no third-party dependency, runs in the normal
// `fvm flutter test` / CI flow.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Third-party import prefix -> the infra package that wraps it. Feature code
/// must depend on the wrapper package, not the raw plugin. When you add a new
/// wrapped dependency, list it here so features can't start importing it
/// directly.
const _wrapped = <String, String>{
  'dio': 'network',
  'flutter_secure_storage': 'storage',
  'shared_preferences': 'storage',
  'objectbox': 'database',
  'objectbox_flutter_libs': 'database',
  'connectivity_plus': 'sync_connectivity_plus',
  'permission_handler': 'app_platform',
  'camera': 'app_platform',
  'image_picker': 'app_platform',
  'video_player': 'app_platform',
  'share_plus': 'app_platform',
  'flutter_local_notifications': 'app_platform',
  'firebase_crashlytics': 'app_platform',
  'firebase_messaging': 'app_platform',
  'firebase_performance': 'network',
  'firebase_analytics': 'analytics',
  'firebase_remote_config': 'config',
};

void main() {
  test('feature packages do not import wrapped third-party plugins directly', () {
    final featuresDir = Directory('packages/features');
    expect(
      featuresDir.existsSync(),
      isTrue,
      reason:
          'Expected packages/features relative to the current directory. '
          'Run this test from the repository root.',
    );

    // `import 'package:<pkg>/...'` and `export`-through re-imports.
    final importLine = RegExp(
      r'''^\s*(?:import|export)\s+['"]package:([a-zA-Z0-9_]+)/''',
      multiLine: true,
    );

    final violations = <String>[];

    for (final entity in featuresDir.listSync()) {
      if (entity is! Directory) continue;
      final lib = Directory('${entity.path}/lib');
      if (!lib.existsSync()) continue;

      for (final file in lib.listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        // Skip generated output — it may reference plugins directly.
        if (file.path.endsWith('.g.dart') ||
            file.path.endsWith('.freezed.dart') ||
            file.path.endsWith('.config.dart') ||
            file.path.endsWith('.module.dart')) {
          continue;
        }

        final source = file.readAsStringSync();
        for (final match in importLine.allMatches(source)) {
          final pkg = match.group(1)!;
          final owner = _wrapped[pkg];
          if (owner != null) {
            violations.add(
              '${file.path}  ->  package:$pkg  (use package:$owner instead)',
            );
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Feature code must consume these plugins through their wrapper infra '
          'package, not import them directly (the wrapper rule). Offenders:\n'
          '${violations.map((v) => '  $v').join('\n')}',
    );
  });
}
