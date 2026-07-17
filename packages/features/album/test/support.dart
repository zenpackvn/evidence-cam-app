import 'dart:async';

import 'package:rev_sync/rev_sync.dart';

/// A controllable [ConnectivitySource] for the Album presentation tests
/// (hand-rolled, no mock framework, per repo convention).
class FakeConnectivity implements ConnectivitySource {
  FakeConnectivity({this.online = true});

  bool online;
  final _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> isOnline() async => online;

  @override
  Stream<bool> get onOnlineChanged => _controller.stream;

  /// Drives a connectivity transition, as the platform adapter would.
  void goOffline() => _emit(isOnline: false);

  void goOnline() => _emit(isOnline: true);

  void _emit({required bool isOnline}) {
    online = isOnline;
    _controller.add(isOnline);
  }

  Future<void> dispose() => _controller.close();
}
