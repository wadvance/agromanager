import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: '@FIREBASE_API_KEY@',
    authDomain: '@FIREBASE_AUTH_DOMAIN@',
    projectId: '@FIREBASE_PROJECT_ID@',
    storageBucket: '@FIREBASE_STORAGE_BUCKET@',
    messagingSenderId: '@FIREBASE_SENDER_ID@',
    appId: '@FIREBASE_APP_ID_WEB@',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '@FIREBASE_API_KEY@',
    appId: '@FIREBASE_APP_ID_ANDROID@',
    messagingSenderId: '@FIREBASE_SENDER_ID@',
    projectId: '@FIREBASE_PROJECT_ID@',
    storageBucket: '@FIREBASE_STORAGE_BUCKET@',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '@FIREBASE_API_KEY@',
    appId: '@FIREBASE_APP_ID_IOS@',
    messagingSenderId: '@FIREBASE_SENDER_ID@',
    projectId: '@FIREBASE_PROJECT_ID@',
    storageBucket: '@FIREBASE_STORAGE_BUCKET@',
    iosBundleId: 'com.agromanager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: '@FIREBASE_API_KEY@',
    appId: '@FIREBASE_APP_ID_IOS@',
    messagingSenderId: '@FIREBASE_SENDER_ID@',
    projectId: '@FIREBASE_PROJECT_ID@',
    storageBucket: '@FIREBASE_STORAGE_BUCKET@',
    iosBundleId: 'com.agromanager',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: '@FIREBASE_API_KEY@',
    appId: '@FIREBASE_APP_ID_WEB@',
    messagingSenderId: '@FIREBASE_SENDER_ID@',
    projectId: '@FIREBASE_PROJECT_ID@',
    storageBucket: '@FIREBASE_STORAGE_BUCKET@',
    authDomain: '@FIREBASE_AUTH_DOMAIN@',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: '@FIREBASE_API_KEY@',
    appId: '@FIREBASE_APP_ID_WEB@',
    messagingSenderId: '@FIREBASE_SENDER_ID@',
    projectId: '@FIREBASE_PROJECT_ID@',
    storageBucket: '@FIREBASE_STORAGE_BUCKET@',
    authDomain: '@FIREBASE_AUTH_DOMAIN@',
  );
}
