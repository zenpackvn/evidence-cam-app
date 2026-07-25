// Firebase configuration for project `zenpack-e42d1`.
// android/ios are the real values (kept in sync with google-services.json /
// GoogleService-Info.plist). `web` is still a placeholder — no web app is
// registered in the Firebase project; register one and rerun `flutterfire
// configure` if a web build is ever needed.
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
    apiKey: 'AIzaSyDC9tWiVw_Qc_NdRAGFYnkcsxfrdXONyYE',
    appId: '1:725879677565:android:f384298ae30a98546ac714',
    messagingSenderId: '725879677565',
    projectId: 'zenpack-e42d1',
    storageBucket: 'zenpack-e42d1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCdMYkH-FR2yYZ0R2o6sIUUH5jDaC2wNfc',
    appId: '1:725879677565:ios:3ca7ec20e9779c3f6ac714',
    messagingSenderId: '725879677565',
    projectId: 'zenpack-e42d1',
    storageBucket: 'zenpack-e42d1.firebasestorage.app',
    iosBundleId: 'com.aktechvn.zenpack',
  );
}
