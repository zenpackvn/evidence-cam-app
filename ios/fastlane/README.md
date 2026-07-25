fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build a flavor and upload it to TestFlight.

Usage: bundle exec fastlane beta flavor:prod (flavor: dev|staging|prod)

### ios distribute

```sh
[bundle exec] fastlane ios distribute
```

Distribute an ALREADY-uploaded build to external testers — no rebuild.

Usage: bundle exec fastlane distribute version:1.7.0 build:480

### ios firebase

```sh
[bundle exec] fastlane ios firebase
```

Build a flavor's IPA (ad-hoc signed) and distribute it via Firebase App Distribution.

Usage: bundle exec fastlane firebase flavor:dev (flavor: dev|staging|prod)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
