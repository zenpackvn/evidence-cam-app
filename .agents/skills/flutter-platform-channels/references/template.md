# Template — Platform Channels

Platform channel communication (MethodChannel, EventChannel, BasicMessageChannel) wrapped behind app-owned interfaces. Only `*_impl.dart` files import `package:flutter/services.dart`; cubits, repositories, and pages depend exclusively on app-owned interfaces.

## Topic Index

| Topic | File |
|---|---|
| MethodChannel wrapper, failure type, channel name constants | [method_channel_wrapper.md](method_channel_wrapper.md) |
| EventChannel wrapper and sensor stream feature example | [event_channel_wrapper.md](event_channel_wrapper.md) |
| BasicMessageChannel for structured messaging | [basic_message_channel.md](basic_message_channel.md) |
| DI registration, named instances, battery feature example | [di_and_feature_usage.md](di_and_feature_usage.md) |
| Native side — Kotlin (Android) handlers and registration | [native_kotlin_android.md](native_kotlin_android.md) |
| Native side — Swift (iOS) handlers and registration | [native_swift_ios.md](native_swift_ios.md) |
| Unit, widget, and bloc tests for platform channels | [testing.md](testing.md) |

## ⚠️ Common Mistakes

> These are the most frequent platform-channel bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Importing `package:flutter/services.dart` outside an `*_impl.dart` file** | Wrapper rule violated; cubits and repositories couple directly to platform channel internals | Only `platform_channel_service_impl.dart` and `event_channel_service_impl.dart` may import `package:flutter/services.dart` |
| 2 | **`PlatformException` leaking into cubit or repository** | Cubit catches a raw `PlatformException`; error type is not part of the app's `Failure` hierarchy | Catch `PlatformException` and `MissingPluginException` in the impl and rethrow as `PlatformChannelFailure`; cubits only see typed failures |
| 3 | **Channel name hardcoded as a string literal in Dart, Kotlin, and Swift** | Name mismatch causes silent `MissingPluginException` when Dart and native sides differ | Define all names in `channel_names.dart` as `ChannelNames` constants; reference the same constant on the native side |
| 4 | **Mocking `MethodChannel` directly in unit tests** | Tests become coupled to internal channel mechanics; break when the impl changes | Mock the app-owned `PlatformChannelService` interface using `MockPlatformChannelService` from mocktail; use `setMockMethodCallHandler` only in widget/integration tests |
| 5 | **Native handler not unregistered in `cleanUpFlutterEngine`** | Native listener leak on Android when the engine is detached and re-attached | Call `handler.unregister()` (sets handler to null, releases `MethodChannel`) inside `cleanUpFlutterEngine` in `MainActivity.kt` |
| 6 | **`EventChannel` stream subscription not cancelled in cubit `close()`** | Native sensor or event stream keeps running after the cubit is disposed; battery drain and data loss | Store the `StreamSubscription` returned by `receiveEvents()`, cancel it in the cubit's `close()` override |
| 7 | **Multiple channel registrations scattered across the codebase** | Two channels registered with the same name causes a conflict; no single source of truth for channel lifetime | Centralise all registrations in `core/di/platform_module.dart`; use `instanceName` when multiple channels of the same type exist |
| 8 | **Asymmetric Kotlin and Swift handlers** | Feature works on one platform and silently fails on the other; review finds mismatched method names or return shapes | Both `AppMethodChannelHandler.kt` and `AppMethodChannelHandler.swift` must handle the same method names and return identical data shapes |

## Quick Summary

- **Wrapper rule** — only `*_impl.dart` files import `package:flutter/services.dart`. Cubits and repositories depend on `PlatformChannelService` / `EventChannelService` interfaces.
- **Typed failures** — catch `PlatformException` and `MissingPluginException` in the impl; rethrow as `PlatformChannelFailure`. Cubits never see raw platform exceptions.
- **Channel name constants** — define all channel names in `channel_names.dart` (single source of truth). No hardcoded strings in Dart, Kotlin, or Swift.
- **Composition-root rule** — all channel registrations in `core/di/platform_module.dart`. Use `instanceName` when multiple channels exist.
- **Symmetry** — Kotlin and Swift handlers must handle the same methods and return the same data shapes.
- **Cleanup** — always unregister handlers in `cleanUpFlutterEngine` (Android); keep references nullable to avoid native listener leaks.
- **Testing** — mock the app-owned interface (`PlatformChannelService`), not `MethodChannel` directly. Use `setMockMethodCallHandler` only in widget/integration tests.
- **Thread safety** — native handlers run on the platform thread; offload heavy work to background threads and reply on the main thread.

## Cross-references

- [flutter-di](../../../flutter-di/references/template.md) — register `PlatformChannelService` and `EventChannelService` as lazySingletons in the composition root
- [flutter-network](../../../flutter-network/references/template.md) — `PlatformChannelFailure` maps into the app's `Failure` hierarchy via `FailureException(UnknownFailure(...))`
