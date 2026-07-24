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
    apiKey: 'PLACEHOLDER_WEB_API_KEY',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'your-firebase-project',
    authDomain: 'your-firebase-project.firebaseapp.com',
    storageBucket: 'your-firebase-project.appspot.com',
    measurementId: 'G-0000000000',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyABVGRZvoln47vOJ35q7u0pLwCruio_Zw4',
    appId: '1:208874315324:android:6b9255220996a8692aad39',
    messagingSenderId: '208874315324',
    projectId: 'flutter-template-e45d8',
    storageBucket: 'flutter-template-e45d8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBf2CH2XfVUVS8xv5douspFCpUpK4czf-U',
    appId: '1:208874315324:ios:af6e2475740a6faf2aad39',
    messagingSenderId: '208874315324',
    projectId: 'flutter-template-e45d8',
    storageBucket: 'flutter-template-e45d8.firebasestorage.app',
    iosBundleId: 'com.aktechvn.quangvn',
  );
}
