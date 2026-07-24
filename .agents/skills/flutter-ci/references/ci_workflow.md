# CI — `.github/workflows/ci.yml`

Runs on every push to `main` and on every pull request. Three jobs: static analysis, tests with coverage gate, and a compile-check build.

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

env:
  FLUTTER_VERSION: "3.24.0"   # Pin to the team's exact version
  COVERAGE_THRESHOLD: 80

jobs:
  # ──────────────────────────────────────────────
  # 1. Static analysis + formatting
  # ──────────────────────────────────────────────
  analyze:
    name: Analyze & Format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Cache pub dependencies
        uses: actions/cache@v4
        with:
          path: |
            ${{ env.PUB_CACHE }}
            .dart_tool/
          key: pub-${{ runner.os }}-${{ hashFiles('pubspec.lock') }}
          restore-keys: pub-${{ runner.os }}-

      - name: Install dependencies
        run: flutter pub get

      - name: Run build_runner (if codegen is in use)
        run: |
          if grep -q "build_runner" pubspec.yaml; then
            dart run build_runner build --delete-conflicting-outputs
          fi

      - name: Check formatting
        run: dart format --set-exit-if-changed .

      - name: Analyze
        run: flutter analyze --fatal-infos

  # ──────────────────────────────────────────────
  # 2. Tests + coverage gate
  # ──────────────────────────────────────────────
  test:
    name: Test & Coverage
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Cache pub dependencies
        uses: actions/cache@v4
        with:
          path: |
            ${{ env.PUB_CACHE }}
            .dart_tool/
          key: pub-${{ runner.os }}-${{ hashFiles('pubspec.lock') }}
          restore-keys: pub-${{ runner.os }}-

      - name: Install dependencies
        run: flutter pub get

      - name: Run build_runner (if codegen is in use)
        run: |
          if grep -q "build_runner" pubspec.yaml; then
            dart run build_runner build --delete-conflicting-outputs
          fi

      - name: Run tests with coverage
        run: flutter test --coverage

      - name: Enforce coverage threshold
        run: |
          chmod +x scripts/check_coverage.sh
          ./scripts/check_coverage.sh ${{ env.COVERAGE_THRESHOLD }}

      - name: Upload coverage report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/lcov.info
          retention-days: 14

  # ──────────────────────────────────────────────
  # 3. Build check (compile verification only)
  # ──────────────────────────────────────────────
  build-check:
    name: Build Check
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Cache pub dependencies
        uses: actions/cache@v4
        with:
          path: |
            ${{ env.PUB_CACHE }}
            .dart_tool/
          key: pub-${{ runner.os }}-${{ hashFiles('pubspec.lock') }}
          restore-keys: pub-${{ runner.os }}-

      - name: Install dependencies
        run: flutter pub get

      - name: Run build_runner (if codegen is in use)
        run: |
          if grep -q "build_runner" pubspec.yaml; then
            dart run build_runner build --delete-conflicting-outputs
          fi

      - name: Build APK (debug — compile check only)
        run: flutter build apk --debug
```
