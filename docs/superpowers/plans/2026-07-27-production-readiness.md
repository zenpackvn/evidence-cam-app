# ZenPack production readiness

Date: 2026-07-27

## Goal

Remove runtime hardcoded business data from the Flutter app and backend, connect the app to the real API flow, and verify the end-to-end paths that can be tested locally.

## Scope

- Backend API behavior for role visibility, dossier permissions, evidence deletion, reporting/export, and account deletion.
- Flutter app runtime data loading for shop, order, dossier, and upload flows.
- API base URL consistency: `https://evidencecam-api.thuannguyen7438.workers.dev`.
- Tests and static checks for both projects.

## Steps

1. Fix backend test/auth setup so route tests exercise the API consistently.
2. Implement backend missing production endpoints and permission rules:
   - Staff sees only their own evidence.
   - Staff cannot create dossier links.
   - Evidence can be deleted by owner/manager when no dossier is open.
   - Dashboard and CSV export endpoints are available.
   - Account deletion removes owned shop metadata and R2 objects.
3. Update Flutter repository/API contracts so runtime screens do not depend on sample entities.
4. Replace upload queue legacy endpoint with the real presign/PUT/complete flow.
5. Remove runtime sample fallbacks from the app flow and show explicit empty/error states instead.
6. Run backend typecheck/tests and Flutter analyze/tests.
7. Build/install a dev iOS build if verification reaches a clean enough state.

## Validation

- `npm run typecheck`
- `npm test`
- `fvm flutter analyze`
- Focused Flutter tests for app bootstrap, orientation, repository/uploader, and flow regressions.
- Full Flutter test run if golden/font assets allow it.
