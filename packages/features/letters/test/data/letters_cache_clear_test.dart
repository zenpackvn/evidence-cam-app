import 'package:feature_letters/src/data/datasources/letters_remote_data_source.dart';
import 'package:feature_letters/src/data/repositories/letters_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';
import 'package:uuid/uuid.dart';

/// The remote is never touched by [LettersRepositoryImpl.clearLocalCache]; this
/// stub just satisfies the constructor.
class _FakeRemote implements LettersRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'clearLocalCache erases the sent-links list and per-letter content, but '
    'leaves device-level preferences (theme, notif toggles, last_synced_uid) '
    'untouched',
    () async {
      SharedPreferences.setMockInitialValues({
        'sm_sent_links': '[]',
        'sm_letter_content_ltr-a': '{"c":"hello","s":[]}',
        'sm_letter_content_ltr-b': '{"c":"world","s":[]}',
        'app.theme_mode': 'light',
        'notif_enabled_kind_letter_opened': true,
        'last_synced_uid': 'uid-1',
      });

      final repo = LettersRepositoryImpl(_FakeRemote(), const Uuid());
      await repo.clearLocalCache();

      final prefs = await SharedPreferences.getInstance();
      // Account-scoped letter caches are gone.
      expect(prefs.containsKey('sm_sent_links'), isFalse);
      expect(prefs.containsKey('sm_letter_content_ltr-a'), isFalse);
      expect(prefs.containsKey('sm_letter_content_ltr-b'), isFalse);
      // Device-level preferences are preserved.
      expect(prefs.getString('app.theme_mode'), 'light');
      expect(prefs.getBool('notif_enabled_kind_letter_opened'), isTrue);
      // The account-switch sentinel is the app shell's to clear, not the repo's.
      expect(prefs.getString('last_synced_uid'), 'uid-1');
    },
  );
}
