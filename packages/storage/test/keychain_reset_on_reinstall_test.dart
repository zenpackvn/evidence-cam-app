import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';
import 'package:test_utils/test_utils.dart';

void main() {
  const installedFlagKey = 'app.installed';

  late MockKeyValueStore store;
  late MockFlutterSecureStorage secureStorage;
  late KeychainResetOnReinstall reset;

  setUp(() {
    store = MockKeyValueStore();
    secureStorage = MockFlutterSecureStorage();
    reset = KeychainResetOnReinstall(store, secureStorage);
  });

  group('KeychainResetOnReinstall', () {
    test('wipes secure storage and sets the flag on first run', () async {
      when(() => store.getBool(installedFlagKey)).thenReturn(null);
      when(secureStorage.deleteAll).thenAnswer((_) async {});
      when(
        () => store.setBool(installedFlagKey, true),
      ).thenAnswer((_) async {});

      await reset.run();

      verify(secureStorage.deleteAll).called(1);
      verify(() => store.setBool(installedFlagKey, true)).called(1);
    });

    /// Bên gọi dựa vào giá trị trả về để biết có phải đăng xuất Firebase hay
    /// không — Firebase cất phiên ở mục Keychain riêng mà `deleteAll` ở đây
    /// không với tới. Trả sai là app cài lại vẫn mở ra ở phiên cũ.
    test(
      'trả true ở lần chạy đầu sau khi cài, false ở những lần sau',
      () async {
        when(() => store.getBool(installedFlagKey)).thenReturn(null);
        when(secureStorage.deleteAll).thenAnswer((_) async {});
        when(
          () => store.setBool(installedFlagKey, true),
        ).thenAnswer((_) async {});

        expect(await reset.run(), isTrue);

        when(() => store.getBool(installedFlagKey)).thenReturn(true);
        expect(await reset.run(), isFalse);
      },
    );

    test('does nothing when the flag is already set', () async {
      when(() => store.getBool(installedFlagKey)).thenReturn(true);

      await reset.run();

      verifyNever(secureStorage.deleteAll);
      verifyNever(() => store.setBool(any(), any()));
    });

    test('leaves the flag unset if the wipe fails, so it retries', () async {
      when(() => store.getBool(installedFlagKey)).thenReturn(null);
      when(secureStorage.deleteAll).thenThrow(Exception('keychain error'));

      await expectLater(reset.run(), throwsException);

      verifyNever(() => store.setBool(any(), any()));
    });
  });
}
