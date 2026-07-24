# Clean Architecture — Layer Overview & Folder Structure

## Layer Diagram

```text
┌─────────────────────────────────────────────────────┐
│  Presentation                                       │
│  ┌───────────┐  ┌───────────┐  ┌────────────────┐  │
│  │   Page    │→ │  Cubit /  │→ │   Use Case     │  │
│  │ (widget)  │  │   BLoC    │  │  (required)    │  │
│  └───────────┘  └───────────┘  └────────────────┘  │
│        ↑ state        ↑ depends on domain only      │
├─────────────────────────────────────────────────────┤
│  Domain                                             │
│  ┌───────────┐  ┌───────────────────────────────┐   │
│  │  Entity   │  │  Repository (abstract)        │   │
│  └───────────┘  └───────────────────────────────┘   │
│        ↑ no imports from data or presentation       │
├─────────────────────────────────────────────────────┤
│  Data                                               │
│  ┌──────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   DTO    │→ │  Data Source  │→ │  Repository  │  │
│  │  (model) │  │  (remote /   │  │    Impl      │  │
│  │  .g.dart │  │   local)     │  │              │  │
│  └──────────┘  └──────────────┘  └──────────────┘  │
│        ↑ raw exceptions → FailureException here     │
└─────────────────────────────────────────────────────┘
```

## Import Rules

| Layer | May import | May NOT import |
|---|---|---|
| Domain | `equatable` only | `data/`, `presentation/`, any third-party |
| Data | `domain/` (contracts + entities) | `presentation/` |
| Presentation | `domain/` (entities, use cases) | `data/` (DTOs, sources, `*_impl`) |
| DI module | Everything | — (it's the composition root) |

## Folder Structure

Two features sharing the same domain and data layer — a **post list** (paginated) and a **post detail** page.

```text
lib/src/features/post/
  di/
    post_module.dart              ← Feature DI module
  presentation/
    pages/
      post_list_page.dart         ← List page with SuperListView
      post_detail_page.dart       ← Detail page
    widgets/
      post_list_tile.dart
      post_detail_content.dart
      post_comment_tile.dart
    cubit/
      post_list_cubit.dart
      post_list_state.dart
      post_detail_cubit.dart
      post_detail_state.dart
  domain/
    entities/
      post.dart
      comment.dart
    repositories/
      post_repository.dart        ← Abstract contract
    usecases/
      get_post_detail_usecase.dart
  data/
    models/
      post_dto.dart
      post_dto.g.dart             ← Generated
      comment_dto.dart
      comment_dto.g.dart          ← Generated
    sources/
      post_remote_source.dart
    post_repository_impl.dart
```
