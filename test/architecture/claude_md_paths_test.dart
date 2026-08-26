// Every repo path named in CLAUDE.md's "Code organization" section must exist.
//
// That section is the map a newcomer — or an automated agent — reads before
// touching anything. When it drifts, the reader doesn't get "no information",
// they get *wrong* information: they go looking for files that aren't there and
// then follow rules for packages that don't exist. It had drifted badly by
// 2026-08 (it described `lib/app/router.dart`, `lib/app/app.dart`,
// `lib/app/features.dart`, a `packages/theme/`, a `packages/sync`, and four
// feature packages named home/profile/splash/auth — none of which exist).
//
// So this is locked with a scan rather than a promise to re-read it carefully.
//
// Scope is deliberately just that one section: the rest of the file is the
// vendored Flutter rules doc, whose example paths (`assets/images/`, `user.g.dart`)
// describe a hypothetical project, not this one.
//
// Pure file-scan, no third-party dependency, runs in the normal
// `fvm flutter test` / CI flow.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Paths CLAUDE.md names in order to say they are **gone**.
///
/// The "Leftovers from the starter template" list points at the template
/// scaffolding that was removed, so that nobody rebuilds on top of it. These
/// must NOT exist — the test asserts that too, so the warning can't outlive the
/// thing it warns about.
const _documentedAsAbsent = {'packages/features/auth/', 'packages/theme/'};

void main() {
  final file = File('CLAUDE.md');

  test('CLAUDE.md exists (run from the package root)', () {
    expect(
      file.existsSync(),
      isTrue,
      reason:
          'Expected to find CLAUDE.md relative to the current directory. '
          'Run this test from the repository root.',
    );
  });

  test('every repo path in the Code organization section exists', () {
    final section = _codeOrganizationSection(file.readAsStringSync());
    final missing = <String>[];

    for (final path in _repoPaths(section)) {
      if (_documentedAsAbsent.contains(path)) continue;
      final trimmed = path.endsWith('/')
          ? path.substring(0, path.length - 1)
          : path;
      if (!File(trimmed).existsSync() && !Directory(trimmed).existsSync()) {
        missing.add(path);
      }
    }

    expect(
      missing,
      isEmpty,
      reason:
          'CLAUDE.md points at paths that do not exist. Wrong documentation is '
          'worse than missing documentation — a reader will go hunting for '
          'these, then follow rules for code that is not here. Fix the doc to '
          'match the tree (or the tree to match the doc):\n\n'
          '${missing.map((m) => '  $m').join('\n')}',
    );
  });

  test('paths documented as removed are really gone', () {
    final present = _documentedAsAbsent
        .map((p) => p.endsWith('/') ? p.substring(0, p.length - 1) : p)
        .where((p) => File(p).existsSync() || Directory(p).existsSync())
        .toList();

    expect(
      present,
      isEmpty,
      reason:
          'CLAUDE.md tells readers these are gone, but they are back. Either '
          'the doc is now wrong, or something was restored without updating '
          'it:\n\n${present.map((p) => '  $p').join('\n')}',
    );
  });
}

/// The section between the "Code organization" heading and the `---` that ends
/// the repo-specific half of the file.
String _codeOrganizationSection(String body) {
  const heading = '## Code organization';
  final start = body.indexOf(heading);
  expect(
    start,
    isNonNegative,
    reason:
        'CLAUDE.md no longer has a "## Code organization" section. If it was '
        'renamed, update the heading this test looks for.',
  );
  final end = body.indexOf('\n---\n', start);
  return end < 0 ? body.substring(start) : body.substring(start, end);
}

/// Backticked tokens that name something in THIS repository.
///
/// Anchored on the top-level directories on purpose: a bare `ec_env.dart` in
/// prose is a filename, not a path, and guessing where it should live would
/// make this test fail on correct docs.
Iterable<String> _repoPaths(String section) {
  final pattern = RegExp(
    '`((?:lib|packages|published|test|tool)/[A-Za-z0-9_./]*)`',
  );
  return pattern
      .allMatches(section)
      .map((m) => m.group(1)!)
      .where((p) => p.length > 4)
      .toSet();
}
