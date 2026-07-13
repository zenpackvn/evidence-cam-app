# 0001. Golden tests run on macOS CI runners

Date: 2026-07-13 (backfills a decision already implemented in ci.yml)
Status: accepted

## Context

Flutter golden (pixel-comparison) baselines are not stable across operating
systems: font rasterization and anti-aliasing differ, so baselines generated
on developer Macs fail when compared on the Ubuntu runners that execute the
main test job. Alternatives considered: maintain a second Linux-generated
baseline set (two sets to keep in sync, needs Docker locally), or a tolerant
comparator (hides small real regressions).

## Decision

Golden tests are tagged `golden`, excluded from the Ubuntu test job, and run
in a dedicated `golden-tests` CI job on `macos-15` — the same OS family the
committed baselines were generated on. On failure the job uploads the
`failures/` diff PNGs as an artifact.

## Consequences

One baseline set, no Docker requirement, diffs reviewable from CI artifacts.
Cost: macOS minutes are billed at 10x on private repos — the job stays small
(app_ui only, no codegen). Revisit (Linux baselines in a container) if golden
suites grow beyond a few packages or macOS minutes become a budget problem.
