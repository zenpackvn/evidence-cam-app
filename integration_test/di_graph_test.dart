// DI graph resolution guard.
//
// injectable generates `gh.factory<FooBloc>(() => FooBloc(gh<BarRepo>()))` for
// every `@injectable` type without verifying that `BarRepo` is actually
// registered by some module. A missing/misordered registration therefore
// compiles and analyzes cleanly and only throws at runtime, the first time
// that factory is resolved, on whatever screen happens to construct FooBloc.
//
// `E2eApp.bootstrap()` already forces every eager `@singleton` / `@preResolve`
// module to resolve, so those are covered. `@lazySingleton` + `@factory`
// registrations (the feature BLoCs/Cubits screens build on demand) are not,
// except incidentally when `e2e_test.dart`'s single happy-path journey happens
// to navigate to their screen. This test closes that gap deterministically:
// it boots the real DI, then resolves every screen-level BLoC/Cubit and
// reports all resolution failures at once, independent of navigation, the
// backend, or e2e flakiness.
//
// get_it 9.x exposes no way to enumerate registrations or resolve by a runtime
// `Type`, so the roots below are listed by hand. When you add a new
// screen-level BLoC/Cubit, add it here. Anything it depends on transitively is
// covered for free by resolving it.
//
// Runs on-device (needs the ObjectBox/secure-storage native plugins that
// `bootstrap()` opens), so it lives under integration_test/, not test/.

import 'package:feature_album/src/presentation/bloc/album_cubit.dart';
import 'package:feature_album/src/presentation/bloc/sample_stamps_cubit.dart';
import 'package:feature_auth/src/presentation/bloc/auth_bloc.dart';
import 'package:feature_auth/src/presentation/bloc/change_password_cubit.dart';
import 'package:feature_auth/src/presentation/bloc/delete_account_cubit.dart';
import 'package:feature_bookmarks/src/presentation/bloc/bookmark_detail/bookmark_detail_bloc.dart';
import 'package:feature_bookmarks/src/presentation/bloc/bookmark_form/bookmark_form_bloc.dart';
import 'package:feature_bookmarks/src/presentation/bloc/bookmarks_list/bookmarks_list_bloc.dart';
import 'package:feature_collections/src/presentation/bloc/add_to_collection/add_to_collection_cubit.dart';
import 'package:feature_collections/src/presentation/bloc/collection_detail/collection_detail_cubit.dart';
import 'package:feature_collections/src/presentation/bloc/collection_form/collection_form_cubit.dart';
import 'package:feature_collections/src/presentation/bloc/collections_list/collections_list_bloc.dart';
import 'package:feature_home/src/presentation/bloc/home_bloc.dart';
import 'package:feature_letters/src/presentation/bloc/sent_letters_cubit.dart';
import 'package:feature_notifications/src/presentation/bloc/notifications_bloc.dart';
import 'package:feature_profile/src/presentation/bloc/edit_profile_cubit.dart';
import 'package:feature_profile/src/presentation/bloc/profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_template/app/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:theme/src/theme_bloc.dart';

import 'support/e2e_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(E2eApp.bootstrap);

  test('every screen-level BLoC/Cubit resolves from the DI graph', () async {
    // Each entry constructs one DI root; a missing transitive dependency throws
    // here instead of on the screen that would have built it in production.
    final roots = <String, BlocBase<Object?> Function()>{
      'HomeBloc': getIt.get<HomeBloc>,
      'SentLettersCubit': getIt.get<SentLettersCubit>,
      'AuthBloc': getIt.get<AuthBloc>,
      'DeleteAccountCubit': getIt.get<DeleteAccountCubit>,
      'ChangePasswordCubit': getIt.get<ChangePasswordCubit>,
      'ThemeBloc': getIt.get<ThemeBloc>,
      'BookmarkDetailBloc': getIt.get<BookmarkDetailBloc>,
      'BookmarksListBloc': getIt.get<BookmarksListBloc>,
      'BookmarkFormBloc': getIt.get<BookmarkFormBloc>,
      'CollectionFormCubit': getIt.get<CollectionFormCubit>,
      'AddToCollectionCubit': getIt.get<AddToCollectionCubit>,
      'CollectionsListBloc': getIt.get<CollectionsListBloc>,
      'CollectionDetailCubit': getIt.get<CollectionDetailCubit>,
      'ProfileBloc': getIt.get<ProfileBloc>,
      'EditProfileCubit': getIt.get<EditProfileCubit>,
      'SampleStampsCubit': getIt.get<SampleStampsCubit>,
      'AlbumCubit': getIt.get<AlbumCubit>,
      'NotificationsBloc': getIt.get<NotificationsBloc>,
    };

    final failures = <String>[];
    for (final MapEntry(key: name, value: resolve) in roots.entries) {
      try {
        // Close eagerly so factory-registered BLoCs don't leak their streams
        // across the loop. lazySingletons return the shared instance; closing
        // it is fine because the test process exits right after.
        await resolve().close();
      } on Object catch (error, stack) {
        failures.add('$name -> $error\n$stack');
      }
    }

    expect(
      failures,
      isEmpty,
      reason:
          'These DI roots failed to resolve. A registration they depend on is '
          'missing or ordered after them in lib/app/di/injection.dart:\n\n'
          '${failures.join('\n\n')}',
    );
  });
}
