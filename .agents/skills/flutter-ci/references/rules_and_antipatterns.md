# CI — Rules & Anti-Patterns

## Rules

- CI must pass before any merge to `main`.
- Coverage threshold is enforced — never skip it. Adjust `COVERAGE_THRESHOLD` in `ci.yml` if the team agrees on a different bar.
- Build verification runs on every PR to catch compile errors early.
- Use exact Flutter SDK version in CI — match the team's pinned version. Update `FLUTTER_VERSION` in both workflow files when upgrading.
- Cache pub dependencies to speed up builds.
- Run `dart run build_runner build --delete-conflicting-outputs` in CI when codegen is in use. The workflows detect this automatically by checking `pubspec.yaml`.
- Never store signing keys or secrets in the repo — use GitHub Secrets and reference them via `${{ secrets.YOUR_SECRET }}`.
- The `build.yml` workflow uses `--no-codesign` for iOS. For real distribution, set up code signing via Fastlane or Xcode Cloud and inject certificates from GitHub Secrets.
- Keep workflow files in sync — when you change `FLUTTER_VERSION` or add a build step, update both `ci.yml` and `build.yml`.

---

## Anti-Patterns

### 1. Running `flutter test` without the coverage flag in CI

**DON'T** — run tests without generating coverage data:

```yaml
# ci.yml
- name: Run tests
  run: flutter test
# No coverage output — the threshold check step has nothing to parse
# and silently passes or is skipped entirely.
```

**DO** — always pass `--coverage` so the gate can enforce the threshold:

```yaml
# ci.yml
- name: Run tests with coverage
  run: flutter test --coverage

- name: Enforce coverage threshold
  run: |
    chmod +x scripts/check_coverage.sh
    ./scripts/check_coverage.sh ${{ env.COVERAGE_THRESHOLD }}
```

---

### 2. Not caching pub dependencies between CI runs

**DON'T** — download every dependency from scratch on each run:

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: subosito/flutter-action@v2
    with:
      flutter-version: "3.24.0"
  - run: flutter pub get   # 30-60s cold download every single time
  - run: flutter test --coverage
```

**DO** — cache `PUB_CACHE` and `.dart_tool/` keyed on `pubspec.lock`:

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: subosito/flutter-action@v2
    with:
      flutter-version: "3.24.0"
      cache: true

  - name: Cache pub dependencies
    uses: actions/cache@v4
    with:
      path: |
        ${{ env.PUB_CACHE }}
        .dart_tool/
      key: pub-${{ runner.os }}-${{ hashFiles('pubspec.lock') }}
      restore-keys: pub-${{ runner.os }}-

  - run: flutter pub get   # Near-instant on cache hit
  - run: flutter test --coverage
```

---

### 3. Skipping `flutter analyze` in the CI pipeline

**DON'T** — rely on developers running analysis locally:

```yaml
jobs:
  test:
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      # No analyze step — lint violations and type errors slip into main.
```

**DO** — run analysis with `--fatal-infos` as a required gate before tests:

```yaml
jobs:
  analyze:
    name: Analyze & Format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: dart format --set-exit-if-changed .
      - run: flutter analyze --fatal-infos

  test:
    name: Test & Coverage
    needs: analyze   # Tests only run after analysis passes.
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
```
