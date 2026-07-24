import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_store.dart';

/// Binds [KeyValueStore] to the shared-preferences-backed implementation,
/// consuming the `@preResolve`d [SharedPreferences] from
/// `SharedPreferencesModule`. Depend on [KeyValueStore], not `SharedPreferences`.
@module
abstract class KeyValueStoreModule {
  @lazySingleton
  KeyValueStore provideKeyValueStore(SharedPreferences prefs) =>
      SharedPreferencesKeyValueStore(prefs);
}
