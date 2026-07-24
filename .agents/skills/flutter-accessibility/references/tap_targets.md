# Tap Targets

All interactive elements must have a minimum size of 48×48 dp (`AppSpacing.huge`). If the visual element is smaller, add invisible padding to expand the hit area.

## CORRECT — minimum 48×48 hit area

```dart
class SmallIconButton extends StatelessWidget {
  const SmallIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSpacing.radiusFull),
        ),
        // Minimum 48x48 hit area even though the icon is 24x24.
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppSpacing.huge,   // 48
            minHeight: AppSpacing.huge,  // 48
          ),
          child: Center(
            child: Icon(icon, size: AppSpacing.iconMd),
          ),
        ),
      ),
    );
  }
}
```

## WRONG — tap target too small

```dart
// BAD: 24x24 tap target — too small for accessibility.
class SmallIconButton extends StatelessWidget {
  const SmallIconButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(Icons.close, size: 24), // No semantic label either.
    );
  }
}
```

---

## Quick reference anti-patterns

```dart
// BAD
SizedBox(
  width: 24,
  height: 24,
  child: GestureDetector(onTap: onTap, child: const Icon(Icons.close)),
);

// GOOD
ConstrainedBox(
  constraints: const BoxConstraints(
    minWidth: AppSpacing.huge,
    minHeight: AppSpacing.huge,
  ),
  child: InkWell(onTap: onTap, child: const Icon(Icons.close)),
);
```

---

## Rule

- **48×48 minimum** — Use `ConstrainedBox` with `minWidth: AppSpacing.huge, minHeight: AppSpacing.huge`. Visual size can be smaller than the hit area.
