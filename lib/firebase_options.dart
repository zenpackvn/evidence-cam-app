// PLACEHOLDER Firebase configuration — committed so the template compiles and
// runs the test suite out of the box. The values are NOT real.
//
// Replace this file with your own project's config by running the FlutterFire
// CLI before building for a device:
//
//     dart pub global activate flutterfire_cli
//     flutterfire configure
//
// That also generates the native config (google-services.json /
// GoogleService-Info.plist), which remain git-ignored and are required for
// real device/emulator builds.
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCmj-Sq_ICf7svfxPZ0W4ShqiVXhXRpLXM',
    appId: '1:725681265816:web:02f40cd8964e31b17744ed',
    messagingSenderId: '725681265816',
    projectId: 'stampmail-dev',
    authDomain: 'stampmail-dev.firebaseapp.com',
    storageBucket: 'stampmail-dev.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCq_c28PLxAj8m4eUYzePX9hxngtwQ6Lxg',
    appId: '1:725681265816:android:acfe7fdbc49de57d7744ed',
    messagingSenderId: '725681265816',
    projectId: 'stampmail-dev',
    storageBucket: 'stampmail-dev.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCD4B1YUn6jxdQ7Xi6Vbslr7BQZnd-yUC0',
    appId: '1:725681265816:ios:b371646277a097e77744ed',
    messagingSenderId: '725681265816',
    projectId: 'stampmail-dev',
    storageBucket: 'stampmail-dev.firebasestorage.app',
    iosClientId:
        '725681265816-tqi5kapfbrp48ht51gdg48bp4h244cf1.apps.googleusercontent.com',
    iosBundleId: 'com.aktechvn.stampmail',
  );
}
