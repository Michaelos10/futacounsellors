// File generated by FlutterFire CLI.
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
        return windows;
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
    apiKey: 'AIzaSyDFX_520ywR21A9wbId6Q-SnsED5abSEsg',
    appId: '1:453691380803:web:fcde5e604a3f7ab40030f6',
    messagingSenderId: '453691380803',
    projectId: 'my-chat-eec17',
    authDomain: 'my-chat-eec17.firebaseapp.com',
    storageBucket: 'my-chat-eec17.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1IjgAuG3ZSbfuBh1pAye7IHXI4vePpBQ',
    appId: '1:453691380803:android:f98bd2929e46ab8c0030f6',
    messagingSenderId: '453691380803',
    projectId: 'my-chat-eec17',
    storageBucket: 'my-chat-eec17.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDuzkctQH_sBOTdFvbMHezr7zwroMIb7B8',
    appId: '1:453691380803:ios:c86126a8debc26ab0030f6',
    messagingSenderId: '453691380803',
    projectId: 'my-chat-eec17',
    storageBucket: 'my-chat-eec17.appspot.com',
    iosBundleId: 'com.example.counsel',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDFX_520ywR21A9wbId6Q-SnsED5abSEsg',
    appId: '1:453691380803:web:fa7a16e3ea315ced0030f6',
    messagingSenderId: '453691380803',
    projectId: 'my-chat-eec17',
    authDomain: 'my-chat-eec17.firebaseapp.com',
    storageBucket: 'my-chat-eec17.appspot.com',
  );

}