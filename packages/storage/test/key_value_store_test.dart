import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferencesKeyValueStore', () {
    late SharedPreferencesKeyValueStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'seeded': 'yes'});
      store = SharedPreferencesKeyValueStore(
        await SharedPreferences.getInstance(),
      );
    });

    test('reads a seeded value and reports missing keys as null', () {
      expect(store.getString('seeded'), 'yes');
      expect(store.getString('missing'), isNull);
      expect(store.getBool('missing'), isNull);
      expect(store.containsKey('seeded'), isTrue);
      expect(store.containsKey('missing'), isFalse);
    });

    test('round-trips each typed value', () async {
      await store.setString('s', 'hello');
      await store.setBool('b', true);
      await store.setInt('i', 7);
      await store.setDouble('d', 1.5);

      expect(store.getString('s'), 'hello');
      expect(store.getBool('b'), isTrue);
      expect(store.getInt('i'), 7);
      expect(store.getDouble('d'), 1.5);
    });

    test('remove deletes a single key; clear empties the store', () async {
      await store.setString('a', '1');
      await store.remove('a');
      expect(store.containsKey('a'), isFalse);

      await store.clear();
      expect(store.containsKey('seeded'), isFalse);
    });
  });
}
