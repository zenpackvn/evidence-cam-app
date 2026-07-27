import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';

class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data.remove(key);
}

void main() {
  late _FakeSecureStorage storage;
  late CredentialStore store;

  setUp(() {
    storage = _FakeSecureStorage();
    store = CredentialStore(storage);
  });

  test('read returns null before anything is saved', () async {
    expect(await store.read(), isNull);
  });

  test('save then read round-trips email and password', () async {
    await store.save(email: 'a@b.com', password: 'matkhau123');

    final saved = await store.read();
    expect(saved?.email, 'a@b.com');
    expect(saved?.password, 'matkhau123');
  });

  test('clear forgets saved credentials', () async {
    await store.save(email: 'a@b.com', password: 'matkhau123');

    await store.clear();

    expect(await store.read(), isNull);
  });
}
