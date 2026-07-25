import 'package:flutter/material.dart';

import 'data/ec_env.dart';
import 'ec_app.dart';

/// EvidenceCam entry point — the pixel-perfect shell.
///
/// Sample data + fake auth by default; pass the deployed Worker URL to use the
/// live backend:
///   `fvm flutter run -t lib/main_ec.dart --dart-define=EC_API_URL=https://…`
///
/// To go fully live once the Firebase config files (project `zenpack-e42d1`)
/// are added, swap this for:
/// ```dart
/// import 'package:firebase_core/firebase_core.dart';
/// import 'firebase_options.dart';           // flutterfire configure output
/// import 'data/ec_auth_firebase.dart';
///
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
///   runApp(EcApp(auth: FirebaseEcAuth(), repo: buildRepository()));
/// }
/// ```
void main() => runApp(EcApp(repo: buildRepository()));
