# Color Contrast & Text Scaling

## Color Contrast

Follow WCAG AA minimums: 4.5:1 for normal text, 3:1 for large text (18sp+ or 14sp+ bold). Use `AppColors` semantic tokens that already meet contrast requirements. Never convey information by color alone — always add an icon or text label.

### Status chip with color AND icon

```dart
enum StatusType { success, warning, error }

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.type, required this.label});

  final StatusType type;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (type) {
      StatusType.success => (AppColors.success, Icons.check_circle),
      StatusType.warning => (AppColors.warning, Icons.warning),
      StatusType.error   => (AppColors.error, Icons.error),
    };

    // Both color AND icon communicate state — accessible to color-blind users.
    return Semantics(
      label: '${type.name}: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: const BorderRadius.all(
            Radius.circular(AppSpacing.radiusSm),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSpacing.iconSm, color: color),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Anti-patterns

```dart
// BAD: Only color distinguishes success from error.
Container(
  color: isSuccess ? Colors.green : Colors.red,
  child: Text(message),
);

// GOOD: Color + icon + semantic label.
Row(
  children: [
    Icon(
      isSuccess ? Icons.check_circle : Icons.error,
      color: isSuccess ? AppColors.success : AppColors.error,
    ),
    const SizedBox(width: AppSpacing.xxs),
    Text(message),
  ],
);
```

---

## Text Scaling

Support `textScaleFactor` up to 2.0. Never use fixed heights for text containers — use min/max constraints so text can expand. Test by overriding the text scaler in `MediaQuery`.

### CORRECT — flexible container

```dart
class AnnouncementBanner extends StatelessWidget {
  const AnnouncementBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      // minHeight, not fixed height — text can expand when scaled.
      constraints: const BoxConstraints(minHeight: AppSpacing.huge),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      color: AppColors.info,
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textOnPrimary,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
```

### WRONG — fixed height clips scaled text

```dart
// BAD: Fixed height — text overflows when scaled.
SizedBox(
  height: 48, // At 2.0x text scale, the text will overflow or clip.
  child: Center(child: Text(message)),
);

// BAD: Fixed container clips scaled text.
SizedBox(
  height: 20,
  child: Text('Status', style: TextStyle(fontSize: 14)),
);

// GOOD: Flexible container, theme-based style.
ConstrainedBox(
  constraints: const BoxConstraints(minHeight: 20),
  child: Text('Status', style: Theme.of(context).textTheme.bodySmall),
);
```

### Testing text scaling in widget tests

```dart
testWidgets('banner accommodates 2.0x text scale', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: const Scaffold(
          body: AnnouncementBanner(message: 'System maintenance at 2 AM'),
        ),
      ),
    ),
  );

  // Verify no overflow — tester reports overflow errors as test failures.
  expect(tester.takeException(), isNull);
  expect(find.text('System maintenance at 2 AM'), findsOneWidget);
});
```

---

## Rules

- **Use `AppColors` tokens** — Semantic color tokens in `AppColors` are pre-validated for contrast. Do not use raw `Color(0xFF...)` values in widgets.
- **Color is never the only signal** — Every status, error, or state indicator must include an icon, text label, or pattern in addition to color. WCAG AA: 4.5:1 normal text, 3:1 large text.
- **Flexible text containers** — Use `minHeight` constraints instead of fixed `height` on text containers so text scaling up to 2.0x does not cause overflow.
