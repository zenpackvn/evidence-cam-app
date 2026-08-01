/// connectivity_plus adapter for the sync engine's `ConnectivitySource` port.
library;

// Re-export như app_platform re-export permission_handler: ai cần đọc *loại*
// liên kết (không chỉ online/offline) vẫn đi qua đúng một cửa, thay vì mọc ra
// một chỗ thứ hai import thẳng connectivity_plus.
export 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;
export 'src/connectivity_plus_source.dart';
export 'src/di.module.dart' show SyncConnectivityPlusPackageModule;
