# Connectivity-Aware UI

Shows a material banner when offline and a snack bar when connectivity is restored.

## `ConnectivityCubit`

### `lib/src/core/connectivity/connectivity_cubit.dart`

```dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_service.dart';
import 'connectivity_status.dart';

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  ConnectivityCubit(this._service) : super(_service.currentStatus) {
    _subscription = _service.onStatusChanged.listen(emit);
  }

  final ConnectivityService _service;
  late final StreamSubscription<ConnectivityStatus> _subscription;

  Future<void> check() async {
    await _service.checkConnectivity();
    emit(_service.currentStatus);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
```

## `ConnectivityBanner` widget

Wrap at the top of the widget tree (e.g., inside `App` or the top-level shell):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/connectivity/connectivity_cubit.dart';
import '../core/connectivity/connectivity_status.dart';
import '../core/di/service_locator.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConnectivityCubit>(),
      child: BlocListener<ConnectivityCubit, ConnectivityStatus>(
        listener: (context, status) {
          if (status == ConnectivityStatus.offline) {
            ScaffoldMessenger.of(context).showMaterialBanner(
              MaterialBanner(
                content: const Text(
                  'You are offline. Changes will sync when connected.',
                ),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                leading: Icon(
                  Icons.cloud_off,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                          .hideCurrentMaterialBanner();
                    },
                    child: const Text('DISMISS'),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Back online. Syncing changes...'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: child,
      ),
    );
  }
}
```

Usage in `app.dart`:

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp.router(
    routerConfig: _router,
    builder: (context, child) => ConnectivityBanner(child: child!),
  );
}
```
