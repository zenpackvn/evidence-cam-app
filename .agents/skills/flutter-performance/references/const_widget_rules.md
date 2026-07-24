# Const Widget Rules

Mark constructors `const` when all fields are final and have no mutable state. Propagate `const` through widget trees to prevent unnecessary rebuilds. The framework skips `build()` entirely for `const` widget subtrees because their identity never changes.

## CORRECT

```dart
class AppTag extends StatelessWidget {
  const AppTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSpacing.radiusSm),
        ),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

// Usage — the const propagates; framework skips rebuild when parent rebuilds.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        AppTag(label: 'Active'),
        SizedBox(height: AppSpacing.xs),
        Icon(Icons.verified, size: AppSpacing.iconMd),
      ],
    );
  }
}
```

## WRONG

```dart
// BAD: Constructor is not const even though all fields are final.
class AppTag extends StatelessWidget {
  AppTag({super.key, required this.label}); // missing const

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric( // missing const
        horizontal: 8,              // magic number
        vertical: 4,                // magic number
      ),
      child: Text(label),
    );
  }
}
```
