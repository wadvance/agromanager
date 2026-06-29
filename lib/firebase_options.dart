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
    apiKey: 'AIzaSyA0Hw4lVgVMKHu8joOIUYJUDa8AvT4w17g',
    authDomain: 'agromanager-11ad3.firebaseapp.com',
    projectId: 'agromanager-11ad3',
    storageBucket: 'agromanager-11ad3.firebasestorage.app',
    messagingSenderId: '599265023705',
    appId: '1:599265023705:web:c6d47b50df1c3b0ef4d0c8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA0Hw4lVgVMKHu8joOIUYJUDa8AvT4w17g',
    appId: '1:599265023705:android:placeholder',
    messagingSenderId: '599265023705',
    projectId: 'agromanager-11ad3',
    storageBucket: 'agromanager-11ad3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA0Hw4lVgVMKHu8joOIUYJUDa8AvT4w17g',
    appId: '1:599265023705:ios:placeholder',
    messagingSenderId: '599265023705',
    projectId: 'agromanager-11ad3',
    storageBucket: 'agromanager-11ad3.firebasestorage.app',
    iosBundleId: 'com.agromanager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA0Hw4lVgVMKHu8joOIUYJUDa8AvT4w17g',
    appId: '1:599265023705:ios:placeholder',
    messagingSenderId: '599265023705',
    projectId: 'agromanager-11ad3',
    storageBucket: 'agromanager-11ad3.firebasestorage.app',
    iosBundleId: 'com.agromanager',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA0Hw4lVgVMKHu8joOIUYJUDa8AvT4w17g',
    appId: '1:599265023705:web:c6d47b50df1c3b0ef4d0c8',
    messagingSenderId: '599265023705',
    projectId: 'agromanager-11ad3',
    storageBucket: 'agromanager-11ad3.firebasestorage.app',
    authDomain: 'agromanager-11ad3.firebaseapp.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyA0Hw4lVgVMKHu8joOIUYJUDa8AvT4w17g',
    appId: '1:599265023705:web:c6d47b50df1c3b0ef4d0c8',
    messagingSenderId: '599265023705',
    projectId: 'agromanager-11ad3',
    storageBucket: 'agromanager-11ad3.firebasestorage.app',
    authDomain: 'agromanager-11ad3.firebaseapp.com',
  );
}
