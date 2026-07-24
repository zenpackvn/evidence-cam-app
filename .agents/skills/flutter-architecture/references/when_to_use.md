# When To Use Full Architecture vs Simple Feature

## Decision Guide

| Signal | Full architecture (this template) | Simple feature ([template-feature-example](template-feature-example.md)) |
|---|---|---|
| Multiple data sources (remote + local cache) | Yes | No |
| Business rules beyond fetch-and-display | Yes | No |
| Use case shared across multiple cubits | Yes | No |
| Domain entities differ significantly from API DTOs | Yes | No |
| Feature has 3+ screens or flows | Yes | No |
| Simple CRUD with one screen | No | Yes |
| Prototype or MVP feature | No | Yes |

---

## Feature Blueprint

Use this outline before implementing a medium or large feature. Answer each point briefly before writing any code.

- **User Goal** — What should the user be able to do when the feature ships?
- **Entry Points** — Which screen, route, or component starts the flow? Deep linking needed?
- **UI States** — Loading, success, empty, error, offline/retry.
- **State And Logic** — What state is local vs shared? What async operations? Forms/validation/debounce?
- **Data Boundaries** — Which APIs, repositories, storage layers? Models/adapters needed? Caching/sync/offline?
- **Localization** — New user-visible strings? Plurals, formatting, RTL support?
- **Observability** — Logs, analytics events, crash-reporting breadcrumbs? Sensitive data to exclude?
- **Environment Impact** — Flavor/dart-define dependencies? Per-environment endpoints or config?
- **Dependencies** — Existing packages to reuse? New dependency truly necessary?
- **Files To Change** — Minimum files needed for the slice.
- **Tests** — Unit tests for logic, widget tests for critical UI, edge cases.
- **Native Impact** — Permissions, build config, platform channels.
- **Done When** — 2–5 concrete outcomes that prove the feature is complete.
