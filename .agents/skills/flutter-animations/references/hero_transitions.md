# Hero Transitions & Route Animations

Hero transitions use Flutter SDK — no wrapping needed. Use with GoRouter for route-level animations. Cross-reference [template-routing.md](template-routing.md) for the full GoRouter setup.

## Basic Hero

```dart
// Source page — wrap the tappable image.
Hero(
  tag: 'product-${product.id}',
  child: AppCachedImage(url: product.imageUrl, width: 80, height: 80),
)

// Destination page — same tag, full-size image.
Hero(
  tag: 'product-${product.id}',
  child: AppCachedImage(url: product.imageUrl, width: double.infinity),
)
```

## Hero with custom flight shuttle

```dart
Hero(
  tag: 'product-${product.id}',
  flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {
    return Material(
      color: Colors.transparent,
      child: toContext.widget,
    );
  },
  child: AppCachedImage(url: product.imageUrl),
)
```

## Hero-compatible route transition (GoRouter)

```dart
GoRoute(
  path: '/product/:id',
  pageBuilder: (context, state) => CustomTransitionPage(
    child: ProductDetailPage(id: state.pathParameters['id']!),
    transitionDuration: AppAnimations.durationPage,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
)
```

---

## Route transitions with AppAnimations

Use `AppAnimations` constants in `CustomTransitionPage` for consistent route transitions.

### Fade transition

```dart
CustomTransitionPage(
  child: const SettingsPage(),
  transitionDuration: AppAnimations.durationPage,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(opacity: animation, child: child);
  },
)
```

### Slide from right

```dart
CustomTransitionPage(
  child: const DetailPage(),
  transitionDuration: AppAnimations.durationPage,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppAnimations.curveStandard,
      )),
      child: child,
    );
  },
)
```

### Shared axis (vertical)

```dart
CustomTransitionPage(
  child: const NextPage(),
  transitionDuration: AppAnimations.durationPage,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: const Interval(0.3, 1.0)),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppAnimations.curveSharp,
        )),
        child: child,
      ),
    );
  },
)
```

---

## Rules

- **Hero tag uniqueness** — Hero tags must be globally unique. Use format `'type-id'` (e.g., `'product-${product.id}'`).
- **Use `RepaintBoundary`** — Wrap frequently animating widgets to avoid repainting siblings. See [template-performance.md](template-performance.md).
- **Always use `AppAnimations` constants** for `transitionDuration` — never inline `Duration` values.
