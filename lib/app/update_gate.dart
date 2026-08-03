import 'dart:async';
import 'dart:io' show Platform;

import 'package:config/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:localization/localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:storage/storage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'di/injection.dart';

/// Longest the gate waits for the first Remote Config fetch before giving up
/// for this launch. Offline users must not stare at a blank screen.
const _fetchWait = Duration(seconds: 5);

const _dismissedAtKey = 'app_update.dismissed_at';
const _postponedVersionKey = 'app_update.postponed_version';

/// Shows the server-driven update prompt over [child] once, at startup.
///
/// A forced prompt cannot be dismissed: the dialog is barrier-less and
/// `PopScope` blocks the back gesture, so the only way forward is the store.
/// A soft prompt is dismissible and then stays quiet for the config's remind
/// window (persisted in [KeyValueStore], see [checkAppUpdate]).
class UpdateGate extends StatefulWidget {
  const UpdateGate({required this.child, super.key});

  final Widget child;

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  AppUpdatePrompt? _prompt;

  @override
  void initState() {
    super.initState();
    unawaited(_check());
  }

  Future<void> _check() async {
    if (!getIt.isRegistered<RemoteConfigService>()) return;
    final service = getIt<RemoteConfigService>();
    // Values read before the fetch lands are the compile-time defaults, which
    // would silently mean "no update" on every cold start.
    await service.fetched.timeout(_fetchWait, onTimeout: () {});

    final prompt = checkAppUpdate(
      config: AppUpdateConfig.parse(
        service.getString(appUpdateKey),
        platform: Platform.isIOS ? 'ios' : 'android',
      ),
      currentVersion: (await PackageInfo.fromPlatform()).version,
      now: DateTime.now(),
      lastDismissedAt: _dismissedAt(),
      postponedVersion: _store()?.getString(_postponedVersionKey),
    );
    if (prompt != null && mounted) setState(() => _prompt = prompt);
  }

  KeyValueStore? _store() =>
      getIt.isRegistered<KeyValueStore>() ? getIt<KeyValueStore>() : null;

  DateTime? _dismissedAt() {
    final millis = _store()?.getInt(_dismissedAtKey);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> _openStore(AppUpdatePrompt prompt) async {
    try {
      await launchUrl(
        Uri.parse(prompt.storeUrl),
        mode: LaunchMode.externalApplication,
      );
    } on Object {
      // A store that refuses to open must not trap the user in a dead dialog;
      // a forced prompt simply stays up so they can retry.
    }
    if (!prompt.isForced) _dismiss(prompt);
  }

  void _dismiss(AppUpdatePrompt prompt) {
    final store = _store();
    unawaited(
      store?.setInt(_dismissedAtKey, DateTime.now().millisecondsSinceEpoch),
    );
    unawaited(store?.setString(_postponedVersionKey, prompt.latestVersion));
    if (mounted) setState(() => _prompt = null);
  }

  @override
  Widget build(BuildContext context) {
    final prompt = _prompt;
    if (prompt == null) return widget.child;

    final l10n = context.l10n;
    // Drawn as an overlay rather than pushed with showCupertinoDialog: the gate
    // sits above the Navigator (it wraps the router's child), so there is no
    // route to push onto. The barrier is inert on purpose — dismissal happens
    // through the actions only, which is what makes a forced prompt blocking.
    return Stack(
      children: [
        widget.child,
        const ModalBarrier(color: Color(0x8C000000), dismissible: false),
        Center(
          child: CupertinoAlertDialog(
            title: Text(
              prompt.title.isEmpty ? l10n.appUpdateTitle : prompt.title,
            ),
            content: Text(
              prompt.message.isEmpty ? l10n.appUpdateMessage : prompt.message,
            ),
            actions: [
              if (!prompt.isForced)
                CupertinoDialogAction(
                  onPressed: () => _dismiss(prompt),
                  child: Text(l10n.appUpdateLater),
                ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => unawaited(_openStore(prompt)),
                child: Text(l10n.appUpdateNow),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
