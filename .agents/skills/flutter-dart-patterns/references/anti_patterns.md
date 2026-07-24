# Anti-Patterns — Dart 3 Patterns

| Anti-pattern | Fix |
|---|---|
| Custom 2-field result class for a use case return | Named record typedef |
| `if (state is X) { ... } else if (state is Y)` | Sealed class + `switch` expression |
| Static utility function file (`utils.dart`) | Extension on the relevant type |
| Abstract class used only for mixins | `mixin` with `on` constraint |
| Wildcard `_` silently swallows new sealed variants | Name each variant explicitly — compiler enforces |
| Raw `String` function type in callbacks | `typedef OnCallback = void Function(X)` |
| `Map<String, dynamic>` repeated in every method | `typedef JsonMap = Map<String, dynamic>` |
| Deeply nested `?. ?? ??` chains | Pattern matching with `if-case` or `switch` |
