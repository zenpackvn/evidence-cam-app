import 'package:config/config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Compares two dotted version strings (e.g. `"1.7.0"`).
///
/// Returns a negative number if [a] is older than [b], zero if equal, positive
/// if newer. Missing or non-numeric segments are treated as 0, and trailing
/// zero segments don't matter (`"1.7"` == `"1.7.0"`). Build/pre-release
/// suffixes (`"1.7.0+12"`, `"1.7.0-beta"`) are ignored — only the numeric core
/// gates the update.
int compareVersions(String a, String b) {
  List<int> parts(String v) => v
      .split(RegExp('[+-]'))
      .first
      .split('.')
      .map((s) => int.tryParse(s.trim()) ?? 0)
      .toList();

  final pa = parts(a);
  final pb = parts(b);
  final length = pa.length > pb.length ? pa.length : pb.length;
  for (var i = 0; i < length; i++) {
    final x = i < pa.length ? pa[i] : 0;
    final y = i < pb.length ? pb[i] : 0;
    if (x != y) return x - y;
  }
  return 0;
}

/// Blocks the app when the running version is below the server-required
/// minimum (`min_supported_version` in Remote Config), forcing an upgrade.
///
/// The check is best-effort and non-blocking: it reads the current version
/// once after the first frame and compares it to the remote minimum. Any error
/// (or an empty/absent minimum) leaves the app fully usable — a force-update
/// gate must never lock users out because a check failed.
class ForceUpdateGate extends StatefulWidget {
  const ForceUpdateGate({
    required this.child,
    this.remoteConfig,
    this.currentVersionOverride,
    super.key,
  });

  final Widget child;

  /// Injectable for tests; defaults to the DI-provided service at the call site.
  final RemoteConfigService? remoteConfig;

  /// Test seam: skip the `package_info_plus` lookup with a fixed version.
  final String? currentVersionOverride;

  @override
  State<ForceUpdateGate> createState() => _ForceUpdateGateState();
}

class _ForceUpdateGateState extends State<ForceUpdateGate> {
  bool _updateRequired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    final config = widget.remoteConfig;
    if (config == null) return;
    final minVersion = config.getString(minSupportedVersionKey).trim();
    if (minVersion.isEmpty) return;

    final current =
        widget.currentVersionOverride ??
        (await PackageInfo.fromPlatform()).version;

    if (compareVersions(current, minVersion) < 0 && mounted) {
      setState(() => _updateRequired = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_updateRequired) const _UpdateRequiredBarrier(),
      ],
    );
  }
}

/// Opaque, dismiss-proof overlay shown when an upgrade is mandatory.
class _UpdateRequiredBarrier extends StatelessWidget {
  const _UpdateRequiredBarrier();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      // Swallow all input to the app below while the gate is up.
      child: PopScope(
        canPop: false,
        child: ColoredBox(
          color: theme.colorScheme.surface,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.system_update,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Update required',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A newer version of the app is required to continue. '
                    'Please update from the store.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
