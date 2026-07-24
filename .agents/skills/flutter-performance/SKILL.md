---
name: flutter-performance
description: Use this skill when optimizing Flutter app performance — const widgets, unnecessary rebuilds, ListView performance, large lists, RepaintBoundary, isolates, compute(), image optimization, cached images, widget key usage, build() optimizations, jank, frame drops, performance profiling, memory leaks, or reducing widget rebuild scope.
---

# Flutter Performance

Full reference: [`template.md`](references/template.md)

## Key rules

### Const everything possible
- Mark widgets, constructors, lists, and maps `const` wherever valid — eliminates rebuild.
- Use `const` in `itemBuilder` callbacks for static children.

### Minimize rebuild scope
- Extract frequently-rebuilding children into separate `StatelessWidget`s.
- Use `BlocSelector` instead of `BlocBuilder` when only a subset of state is needed.
- `RepaintBoundary` around independently-animating subtrees (maps, charts, video).

### List performance
- `ListView.builder` + `ListView.separated` for large lists — never `ListView(children: [])`.
- Set `itemExtent` or `prototypeItem` on `ListView.builder` when all items have the same height (skips layout).
- `CachedNetworkImage` for all remote images — `AppCachedImage` wrapper.

### Isolates
- Offload JSON decoding > 1 MB with `compute(jsonDecode, rawString)`.
- Offload sorting/filtering large lists with `compute()`.
- Never do heavy computation on the main isolate.

### Image optimization
- Use `width`/`height` on `AppCachedImage` to constrain decode size.
- Use `memCacheWidth`/`memCacheHeight` for thumbnails.
- Prefer WebP over PNG for large assets.

### Anti-patterns
- `setState` in `build()` — always causes infinite rebuild.
- `MediaQuery.of(context)` deep in the tree — cache at page level.
- Creating `TextEditingController` / `AnimationController` in `build()` — use `State`.
- `Opacity(opacity: 0)` to hide — use `Visibility` or `Offstage`.

## Co-load with

- `flutter-common-widgets` — App widgets are already optimized
- `flutter-animations` — animations must not drop frames
