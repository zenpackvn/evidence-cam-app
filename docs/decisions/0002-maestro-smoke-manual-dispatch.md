# 0002. Maestro smoke runs on manual dispatch, against the hosted dev backend

Date: 2026-07-13
Status: accepted

## Context

The StampMail Maestro flows (`maestro/stampmail/`) exercise login → home
against the hosted dev backend (`https://stampmails.sabeel.app`) with real
Firebase Auth and a seeded test account. We want them runnable in CI, but:
the repo is private (every Actions minute is billed, and org billing has
already lapsed once), an emulator job takes ~15–20 min, and a hosted-backend
dependency makes per-PR gating flaky — a backend blip would redden unrelated
PRs.

## Decision

`maestro-smoke.yml` runs the smoke flow (`stampmail/01_login.yaml`) on an
Android emulator (Ubuntu runner, KVM) via `workflow_dispatch` only — triggered
deliberately before releases or after auth/backend-touching changes. No
`schedule`, no PR trigger. The debug APK is built with `env/dev.json` defines
and the same placeholder `google-services.json` as build-android (Firebase
initializes from Dart `firebase_options.dart` at runtime).

## Consequences

E2E signal is available on demand without burning minutes nightly or blocking
PRs on external infra. Nobody runs it automatically — promote to a schedule or
a release-branch trigger once billing is stable and the flow proves reliable.
