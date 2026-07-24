---
name: flutter-accessibility
description: Use this skill when working on Flutter accessibility — Semantics widget, semantic labels, screen reader support (TalkBack, VoiceOver), focus management, FocusNode, text scaling, large font support, minimum tap target size, color contrast, WCAG compliance, accessible forms, accessible navigation, or any a11y improvement.
---

# Flutter Accessibility

Full reference: [`template.md`](references/template.md)

## Key rules

- Minimum tap target: **48×48 dp** (Material spec). Use `SizedBox` / `InkWell` constraints if the visual size is smaller.
- `Semantics` widget: add `label`, `hint`, `button: true`, `onTap` for custom interactive widgets that aren't self-describing.
- Icons without adjacent labels must have `Semantics(label: 'Close', child: Icon(Icons.close))`.
- Text must scale: never hardcode text container height — let it grow. Test at 200% text scale.
- Color contrast: WCAG AA requires 4.5:1 for body text, 3:1 for large text. Check `AppColors` tokens against light and dark backgrounds.
- Focus order must match visual reading order. Set `FocusTraversalOrder` or `FocusNode.nextFocus` when automatic order is wrong.
- Form fields: `labelText` and `errorText` must be set so screen readers can announce field state.
- Image semantics: `Image(semanticLabel: '...')` or `ExcludeSemantics()` for purely decorative images.
- Test checklist: run `flutter test --accessibility-checks`, enable TalkBack/VoiceOver, navigate with keyboard only.

## Co-load with

- `flutter-common-widgets` — App widgets must meet a11y requirements
- `flutter-tests` — accessibility checks in widget tests
- `flutter-design-system` — contrast verified at design-token level
