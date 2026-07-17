# Bug log

Journal of non-trivial bugs: what it looked like, what actually caused it, and
what we learned. Newest entry first under `## Bugs`. Grep this file before
debugging strange behavior — the bug may already be documented. After fixing a
non-trivial bug (anything whose root cause wasn't obvious from the first stack
trace), prepend an entry.

Template:

```markdown
### BUG-NNNN — <short title>
- **Date:** YYYY-MM-DD
- **Symptom:** what was observed (error message, wrong behavior, platform)
- **Root cause:** the actual defect, not the surface trigger
- **Fix:** what changed
- **Files:** paths touched
- **Verify:** how the fix was proven (test name, e2e flow, manual step)
- **Lesson:** the reusable takeaway (what to check first next time)
```

## Bugs

### BUG-0002 — Rename never showed on the stamp detail screen (SM-022 AC-06)
- **Date:** 2026-07-17
- **Symptom:** Renaming a stamp from its detail screen updated the Album list, but the detail screen itself kept showing the old name until you backed out and reopened it.
- **Root cause:** `AlbumScreen._openDetail` passed the `Stamp` captured in the list's `onTap` closure. That value is a snapshot: `AlbumCubit.rename` emits a new state with a new `Stamp`, but the pushed route still held the stale object. The list looked correct only because it rebuilt from the new state.
- **Fix:** the detail route now rebuilds from the cubit — `BlocBuilder` + `state.stamps.firstWhere(id)` — so it reads the current stamp rather than the captured one.
- **Files:** `packages/features/album/lib/src/presentation/screens/album_screen.dart`
- **Verify:** `packages/features/album/test/presentation/album_offline_test.dart` (rename reflects on the detail); the test was confirmed to fail against the pre-fix code, not pass vacuously.
- **Lesson:** pushing a route with a value read from a bloc's state hands it a snapshot. If the pushed screen must reflect later emissions, rebuild it from the bloc (`BlocProvider.value` + `BlocBuilder` + look the entity up by id) instead of passing the object.

### BUG-0001 — "A TextEditingController was used after being disposed" on the rename dialog
- **Date:** 2026-07-17
- **Symptom:** Assertion thrown after confirming/cancelling the stamp rename dialog (SM-022 BR-08): `A TextEditingController was used after being disposed`. Only surfaced once a test pumped the dialog to settle — manual use often dismissed fast enough to hide it.
- **Root cause:** `_promptRename` created the `TextEditingController` locally and called `controller.dispose()` right after `await showDialog(...)` returned. The dialog's exit animation is still running at that point and keeps rebuilding the `TextField`, which touches the now-disposed controller.
- **Fix:** moved the controller into a `_RenameDialog` `StatefulWidget` that owns it, so its lifetime matches the dialog route and `dispose()` runs only when the route is gone.
- **Files:** `packages/features/album/lib/src/presentation/screens/stamp_detail_screen.dart`
- **Verify:** `packages/features/album` widget tests pump the dialog and settle without the assertion.
- **Lesson:** never dispose a controller right after `await showDialog(...)` — the route outlives the await by one exit animation. Give the controller to a StatefulWidget inside the dialog. A widget test that calls `pumpAndSettle()` after dismissing is what exposes this class of bug.
