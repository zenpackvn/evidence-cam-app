# Release Checklist

## Pre-release

```markdown
- [ ] Version bumped in `pubspec.yaml` (`./scripts/bump_version.sh patch|minor|major`)
- [ ] CHANGELOG.md updated with release notes
- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` — all passing
- [ ] Golden tests regenerated if UI changed
- [ ] Manual QA on physical Android + iOS devices
- [ ] Deep links tested (adb/xcrun — see template-routing.md)
- [ ] Performance profiled in `--profile` mode
- [ ] Accessibility checked (TalkBack/VoiceOver)
- [ ] Crashlytics/Sentry debug symbols ready for upload
- [ ] Feature flags set correctly for this release
- [ ] API backward compatibility verified
```

## Android release

```markdown
- [ ] `key.properties` has correct signing config
- [ ] `flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info`
- [ ] AAB tested via `bundletool` or internal test track
- [ ] Debug symbols uploaded to crash reporting
- [ ] Play Store listing updated (if needed)
- [ ] Upload to Play Store (internal → closed → open → production)
- [ ] Staged rollout percentage set (10% → 25% → 50% → 100%)
```

## iOS release

```markdown
- [ ] Certificates and provisioning profiles valid (check expiry)
- [ ] `flutter build ipa --release --obfuscate --split-debug-info=build/debug-info`
- [ ] IPA tested via TestFlight
- [ ] Debug symbols uploaded to crash reporting
- [ ] App Store Connect listing updated (if needed)
- [ ] Submit for review
- [ ] Phased release enabled (7-day rollout)
```

## Post-release

```markdown
- [ ] Git tag created: `git tag -a v1.2.3 -m "Release 1.2.3"` && `git push --tags`
- [ ] Monitor crash reports (first 24h)
- [ ] Monitor analytics for anomalies
- [ ] Verify Shorebird patches work (if using code push)
- [ ] Communicate release to stakeholders
```

---

## Play Store track promotion

```text
Internal testing  →  Closed testing  →  Open testing  →  Production
    (team)           (select testers)    (anyone can join)   (public)
```

- **Internal**: Up to 100 testers, no review needed
- **Closed**: Invite-only, no review needed
- **Open**: Public join link, review needed
- **Production**: Staged rollout recommended (10% → 100%)

## App Store release flow

```text
TestFlight (internal)  →  TestFlight (external)  →  App Store Review  →  Release
   (auto-approved)          (review needed)           (1-3 days)         (phased)
```

- **Internal TestFlight**: Up to 100 internal testers, auto-approved
- **External TestFlight**: Up to 10,000 testers, needs beta review
- **App Store Review**: 1-3 days typical
- **Phased release**: 1%→2%→5%→10%→20%→50%→100% over 7 days

## Anti-patterns

| DON'T | DO |
|---|---|
| Commit keystores or secrets | Store in CI secrets, decode at build time |
| Skip `--obfuscate` in release builds | Always use `--obfuscate --split-debug-info=build/debug-info` |
| Release to 100% immediately | Use staged rollout (Play Store) / phased release (App Store) |
| Manually upload builds | Automate with Fastlane |
| Skip debug symbol upload | Upload `build/debug-info/` to Sentry/Crashlytics |
