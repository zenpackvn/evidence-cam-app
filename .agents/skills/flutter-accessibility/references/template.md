# Template — Accessibility

Accessibility patterns, semantic widgets, tap targets, focus management, color contrast, and screen reader testing. Pure Flutter — no third-party packages required.

## Reference Files

Load only the file(s) relevant to the task.

| Topic | File |
|---|---|
| `Semantics`, `ExcludeSemantics`, `MergeSemantics`, custom interactive widget semantics | [semantic_widgets.md](semantic_widgets.md) |
| Minimum 48×48 tap targets, `ConstrainedBox` pattern, anti-patterns | [tap_targets.md](tap_targets.md) |
| `FocusTraversalGroup`, focus order, autofocus, returning focus after dialog | [focus_management.md](focus_management.md) |
| WCAG AA contrast, color + icon rule, `AppColors` tokens, text scaling up to 2.0x | [color_contrast_text_scaling.md](color_contrast_text_scaling.md) |
| Widget tests for semantics, tap size assertions, `showSemanticsDebugger`, screen reader checklist | [accessibility_testing.md](accessibility_testing.md) |

---

## ⚠️ Common Mistakes

> These are the most frequent accessibility bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Icon button with no semantic label** | Screen reader announces "button" with no context; fails WCAG SC 4.1.2 | Wrap with `Semantics(button: true, label: 'Add to favorites', child: IconButton(...))` or use the widget's built-in `tooltip` property |
| 2 | **`ExcludeSemantics` on an interactive widget** | Screen reader skips the element entirely; users cannot activate it | Use `ExcludeSemantics` only on decorative images or purely visual dividers; never on tappable or focusable widgets |
| 3 | **Tap target smaller than 48×48 dp** | Users with motor impairments miss taps; fails Material/WCAG guideline | Wrap with `ConstrainedBox(constraints: BoxConstraints(minWidth: AppSpacing.huge, minHeight: AppSpacing.huge))`; visual size can remain smaller |
| 4 | **Color as the only status signal** | Color-blind users cannot distinguish success from error; fails WCAG SC 1.4.1 | Always pair color with an icon and a text label (e.g., `StatusChip` uses `AppColors.error` + `Icons.error` + the label string) |
| 5 | **Fixed `height` on a text container** | Text overflows or clips when device text scale is set to 2.0×; widget test with `TextScaler.linear(2.0)` fails | Replace `SizedBox(height: x)` with `ConstrainedBox(constraints: BoxConstraints(minHeight: x))` so the container grows with the text |
| 6 | **Raw `Color(0xFF...)` instead of `AppColors` token** | Color may not meet WCAG AA contrast ratio (4.5:1 normal text, 3:1 large text); review comment | Use pre-validated `AppColors` semantic tokens (`AppColors.textPrimary`, `AppColors.error`, etc.) instead of raw hex values |
| 7 | **No `FocusTraversalGroup` for a form or dialog** | Focus order jumps unpredictably when the user navigates with keyboard or switch control | Wrap each logical group (form, dialog buttons) in `FocusTraversalGroup` and set `autofocus` on the primary action widget |
| 8 | **No semantic label assertion in widget tests** | Accessibility regressions ship silently; CI passes even when a label is removed | Tag tests with `@Tags(['accessibility'])` and assert `tester.getSemantics(find.byType(X)).label` equals the expected string; assert tap target size via `tester.getSize` |

---

## Quick Summary

- **Semantics on every interactive element** — all buttons, links, and tappable areas must have a `label`. Use `Semantics(label:)` or the widget's built-in `semanticLabel` / `tooltip` property.
- **48×48 minimum tap targets** — use `ConstrainedBox(constraints: BoxConstraints(minWidth: AppSpacing.huge, minHeight: AppSpacing.huge))`. Visual size can be smaller.
- **`ExcludeSemantics` only for decorative elements** — never on interactive widgets.
- **Color is never the only signal** — every status or error indicator must include an icon or text label in addition to color. WCAG AA: 4.5:1 normal text, 3:1 large text.
- **Flexible text containers** — use `minHeight` constraints, never fixed `height`, so text scales to 2.0× without overflow.
- **Focus management** — `FocusTraversalGroup` for logical order, `autofocus` for primary actions, return focus after dialog dismissal.
- **Test in CI** — tag accessibility widget tests with `@Tags(['accessibility'])` and assert semantic labels + tap target sizes.
- **Use `AppColors` tokens** — pre-validated for contrast; never use raw `Color(0xFF...)` in widgets.

## Cross-references

- [flutter-common-widgets](../../flutter-common-widgets/references/template.md) — app widgets (buttons, fields, chips) must meet a11y tap-target and semantic-label requirements
- [flutter-tests](../../flutter-tests/references/template.md) — widget test patterns for asserting semantic labels, tap target sizes, and `@Tags(['accessibility'])` test setup
- [flutter-design-system](../../flutter-design-system/references/template.md) — `AppColors` tokens are validated for WCAG AA contrast ratios at the design-token level
- [flutter-theme](../../flutter-theme/references/template.md) — `AppColors` and `AppSpacing` constants referenced for contrast checks and 48×48 tap-target sizing
