# Connectivity Service

Wraps `connectivity_plus` behind an app-owned interface. Only `connectivity_service_impl.dart` imports the third-party package.

## pubspec.yaml additions

```yaml
dependencies:
  connectivity_plus: 6.1.0
```

`drift` is assumed already present from [template-storage.md](template-storage.md).

## Folder structure

```text
lib/src/core/
  connectivity/
    connectivity_service.dart           <- App-owned connectivity interface
    connectivity_service_impl.dart      <- Wraps connectivity_plus (only import)
    connectivity_status.dart            <- App-owned enum (online, offline)
```

## `lib/src/core/connectivity/connectivity_status.dart`

```dart
enum ConnectivityStatus { online, offline }
```

## `lib/src/core/connectivity/connectivity_service.dart`

```dart
import 'connectivity_status.dart';

abstract interface class ConnectivityService {
  ConnectivityStatus get currentStatus;
  Stream<ConnectivityStatus> get onStatusChanged;
  Future<bool> checkConnectivity();
  void dispose();
}
```

## `lib/src/core/connectivity/connectivity_service_impl.dart`

Only file importing `connectivity_plus`.

```dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'connectivity_service.dart';
import 'connectivity_status.dart';

class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity() {
    _subscription = _connectivity.onConnectivityChanged.listen(_onResult);
  }

  final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityStatus _currentStatus = ConnectivityStatus.online;
  final _controller = StreamController<ConnectivityStatus>.broadcast();

  @override
  ConnectivityStatus get currentStatus => _currentStatus;

  @override
  Stream<ConnectivityStatus> get onStatusChanged => _controller.stream;

  @override
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    final status = _mapResults(results);
    _updateStatus(status);
    return status == ConnectivityStatus.online;
  }

  void _onResult(List<ConnectivityResult> results) {
    final status = _mapResults(results);
    _updateStatus(status);
  }

  void _updateStatus(ConnectivityStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _controller.add(status);
    }
  }

  static ConnectivityStatus _mapResults(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      return ConnectivityStatus.offline;
    }
    return ConnectivityStatus.online;
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.close();
  }
}
```
