import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Provides Firebase configuration for each supported platform.
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  /// Returns the [FirebaseOptions] for the current platform if available.
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    return null;
  }

  /// Firebase configuration used by the Flutter web build.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCbI0QF1xmDZK9XUFq-0FZjYTMH8x5VF2Y',
    appId: '1:406570908743:web:765d7fe9c4eed33c5e8562',
    messagingSenderId: '406570908743',
    projectId: 'bankrulek-95bb5',
    authDomain: 'bankrulek-95bb5.firebaseapp.com',
    storageBucket: 'bankrulek-95bb5.appspot.com',
    measurementId: 'G-WFDPJQM010',
  );
}
