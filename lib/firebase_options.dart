// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return macos;
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
    apiKey: 'AIzaSyAznD3cT8F-0ZGE-nl33Zd5zCD8WX-OOT0',
    appId: '1:975404504136:web:349e2d3ab3251365fef47d',
    messagingSenderId: '975404504136',
    projectId: 'e-petshop-cff2e',
    authDomain: 'e-petshop-cff2e.firebaseapp.com',
    storageBucket: 'e-petshop-cff2e.appspot.com',
    measurementId: 'G-VYP5JJSLX5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJM1Vqa23q0wZquUYYXROi6IUA5_Ra6Ag',
    appId: '1:975404504136:android:98b44c52077aeef2fef47d',
    messagingSenderId: '975404504136',
    projectId: 'e-petshop-cff2e',
    storageBucket: 'e-petshop-cff2e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC7x9tXqfDzQKLnO36KXaM3u8hUuCSRj-c',
    appId: '1:975404504136:ios:3dc30e28a3f6686afef47d',
    messagingSenderId: '975404504136',
    projectId: 'e-petshop-cff2e',
    storageBucket: 'e-petshop-cff2e.appspot.com',
    iosBundleId: 'com.example.ePetshop',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC7x9tXqfDzQKLnO36KXaM3u8hUuCSRj-c',
    appId: '1:975404504136:ios:b441476f38b3cf6cfef47d',
    messagingSenderId: '975404504136',
    projectId: 'e-petshop-cff2e',
    storageBucket: 'e-petshop-cff2e.appspot.com',
    iosBundleId: 'com.example.ePetshop.RunnerTests',
  );
}
